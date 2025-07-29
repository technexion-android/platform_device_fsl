#!/bin/bash

# help function, it display the usage of this script.
help() {
cat << EOF
    This script is executed after "source build/envsetup.sh" and "lunch".

    usage:
        `basename $0` <option>

        options:
           -h/--help               display this help info
           -j[<num>]               specify the number of parallel jobs when build the target, the number after -j should be greater than 0
           bootloader              bootloader will be compiled
           kernel                  kernel, include the kernel modules and device tree files will be compiled
           partition_imgs          generate partition table images
           galcore                 galcore.ko in GPU repo will be compiled
           vvcam                   vvcam.ko, the ISP driver will be compiled
           mxmwifi                 mlan.ko moal.ko, the MXMWifi driver will be compiled
           dtboimage               dtbo images will be built out
           bootimage               boot.img will be built out
           vendorbootimage         vendor_boot.img will be built out
           vendor_dlkmimage        vendor_dlkm.img will be built out
           abi_update_symbol_list  update GKI symbol list
           -c                      use clean build for kernel, not incremental build


    an example to build the whole system with maximum parallel jobs as below:
        `basename $0` -j


EOF

exit;
}

# handle special args, now it is used to handle the option for make parallel jobs option(-j).
# the number after "-j" is the jobs in parallel, if no number after -j, use the max jobs in parallel.
# kernel now can't be controlled from this script, so by default use the max jobs in parallel to compile.
handle_special_arg()
{
    # options other than -j are all illegal
    local jobs;
    if [ ${1:0:2} = "-j" ]; then
        jobs=${1:2};
        if [ -z ${jobs} ]; then                                                # just -j option provided
            parallel_option="-j";
        else
            if [[ ${jobs} =~ ^[0-9]+$ ]] && [ ${jobs} -gt 0 ]; then           # integer bigger than 0 after -j
                 parallel_option="-j${jobs}";
            else
                echo invalid -j parameter;
                exit;
            fi
        fi
    else
        echo Unknown option: ${1};
        help;
    fi
}

# check whether the build product and build mode is selected
if [ -z ${OUT} ] || [ -z ${TARGET_PRODUCT} ]; then
    help;
fi

# global variables
build_android_flag=0
build_whole_android_flag=0
build_bootloader=""
build_kernel=""
build_partition_imgs=""
build_kernel_modules=""
build_kernel_dts=""
build_kernel_oot_module_flag=0
build_galcore=""
build_vvcam=""
build_mxmwifi=""
build_bootimage=""
build_vendorbootimage=""
build_dtboimage=""
build_vendordlkmimage=""
build_abi_update_symbol_list=""
parallel_option=""
clean_build=0
skip_config_or_clean=0
enable_gki=${ENABLE_GKI:-1}
enable_bazel=${ENABLE_BAZEL:-0}

# process of the arguments
args=( "$@" )
for arg in ${args[*]} ; do
    case ${arg} in
        -h) help;;
        --help) help;;
        -c) clean_build=1;;
        bootloader) build_bootloader="bootloader";;
        kernel) build_kernel="${OUT}/kernel";
                    build_kernel_modules="KERNEL_MODULES";
                    build_kernel_dts="KERNEL_DTB";;
        partition_imgs) build_partition_imgs="partition_imgs";;
        galcore) build_kernel_oot_module_flag=1;
                    build_galcore="galcore";;
        vvcam) build_kernel_oot_module_flag=1
                    build_vvcam="vvcam";;
        mxmwifi) build_kernel_oot_module_flag=1
                    build_mxmwifi="mxmwifi";;
        bootimage) build_android_flag=1;
                    build_kernel="${OUT}/kernel";
                    build_bootimage="bootimage";;
        vendorbootimage) build_android_flag=1;
                    build_kernel_dts="KERNEL_DTB";
                    if [ "${enable_bazel}" -ne 1 ]; then
                        build_kernel_oot_module_flag=1;
                        build_kernel_modules="KERNEL_MODULES";
                    fi
                    build_vendorbootimage="vendorbootimage";;
        dtboimage) build_android_flag=1;
                    build_kernel_dts="KERNEL_DTB";
                    build_dtboimage="dtboimage";;
        vendor_dlkmimage) build_android_flag=1;
                    build_kernel_oot_module_flag=1;
                    build_kernel_modules="KERNEL_MODULES";
                    build_vendordlkmimage="vendor_dlkmimage";;
        abi_update_symbol_list) build_abi_update_symbol_list="abi_update_symbol_list";;
        *) handle_special_arg ${arg};;
    esac
done

# if bootloader and kernel not in arguments, all need to be made
if [ "${build_bootloader}" = "" ] && [ "${build_kernel}" = "" ] && \
        [ "${build_partition_imgs}" = "" ] && \
        [ "${build_kernel_modules}" = "" ] && [ "${build_kernel_dts}" = "" ] && \
        [ ${build_kernel_oot_module_flag} -eq 0 ] && [ ${build_android_flag} -eq 0 ]; then
    build_bootloader="bootloader";
    build_kernel="${OUT}/kernel";
    build_partition_imgs="partition_imgs"
    build_kernel_modules="KERNEL_MODULES";
    build_kernel_dts="KERNEL_DTB";
    build_whole_android_flag=1
fi

# Check if Bazel build is enabled
if [ "${enable_bazel}" -eq 1 ]; then
  # Set default parallel job count to 8 if not already defined
  jobs="${jobs:-8}"

  # Save the original working directory to return after build
  orig_dir=$(pwd)

  # Define Bazel workspace directory
  BAZEL_WORKSPACE_DIR="${BAZEL_WORKSPACE_DIR:-$HOME/android16-6.12}"

  # Verify that the Bazel workspace exists
  if [ ! -d "$BAZEL_WORKSPACE_DIR" ]; then
    echo "Workspace not found: $BAZEL_WORKSPACE_DIR"
    echo "Please set BAZEL_WORKSPACE_DIR environment variable to point to your Bazel workspace"
    echo "Example: export BAZEL_WORKSPACE_DIR=/path/to/your/android16-6.12"
    exit 1
  fi

  # Function to run a Bazel target and optionally copy its output file
  # Named Arguments:
  # --target=      Bazel target label (e.g., //kernel_imx:target_name) [required]
  # --output=      Path to the expected output file (relative to workspace) [optional]
  # --dest=        Destination directory to copy the output file [optional]
  # --label=       Label for logging purposes [optional]

  run_bazel_target() {
    local target=""
    local output_file=""
    local dest_dir=""
    local label=""

    # Parse named arguments
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --target=*) target="${1#*=}" ;;     # Bazel target label
        --output=*) output_file="${1#*=}" ;; # Output file path
        --dest=*)   dest_dir="${1#*=}" ;;    # Destination directory
        --label=*)  label="${1#*=}" ;;       # Logging label
        *) echo "Unknown option: $1"; return 1 ;;
      esac
      shift
    done

    # Validate required argument
    if [[ -z "$target" ]]; then
      echo "Error: --target is required"
      return 1
    fi

    # Set default label if not provided
    if [[ -z "$label" ]]; then
      label="Unnamed"
    fi

    echo ">>> ${label} Bazel build <<<"

    # Ensure required environment variables are set
    : "${BAZEL_WORKSPACE_DIR:?BAZEL_WORKSPACE_DIR not set}"
    : "${jobs:?jobs not set}"
    : "${orig_dir:?orig_dir not set}"

    # Change to Bazel workspace
    cd "$BAZEL_WORKSPACE_DIR" || {
      echo "Failed to cd into $BAZEL_WORKSPACE_DIR"
      return 1
    }

    # Run Bazel build
    tools/bazel run "$target" --local_resources=cpu="${jobs}" || {
      echo "Bazel build failed for ${label}"
      cd "$orig_dir"
      return 1
    }

    # If output_file and dest_dir are provided, copy the file
    if [[ -n "$output_file" && -n "$dest_dir" ]]; then
      if [[ -f "$output_file" ]]; then
        cp -fv "$output_file" "$dest_dir"
      else
        echo "${output_file##*/} not found"
        cd "$orig_dir"
        return 1
      fi
    else
      echo "Skipping copy step (output_file or dest_dir not provided)"
    fi

    # Return to original directory
    cd "$orig_dir"
  }

  # Build vendor boot image (ramdisk.lz4)
  if [ -n "${build_vendorbootimage}" ]; then
    run_bazel_target \
      --target="//kernel_imx:imx_${TARGET_PRODUCT}_aarch64_vendor_boot_dist" \
      --output="out/imx_${TARGET_PRODUCT}_aarch64/dist/ramdisk.lz4" \
      --dest="$orig_dir/vendor/nxp-opensource/imx-gki/" \
      --label="bazel_vendorbootimage" || {
      echo "error：vendor boot ramdisk.lz4 build fail"
      exit 1
      }
  fi

  # Build vendor DLKM image (vendor_dlkm.img)
  if [ -n "${build_vendordlkmimage}" ]; then
    run_bazel_target \
      --target="//kernel_imx:imx_${TARGET_PRODUCT}_aarch64_vendor_dlkm_dist" \
      --output="out/imx_${TARGET_PRODUCT}_aarch64/dist/vendor_dlkm.img" \
      --dest="$orig_dir/out/target/product/${TARGET_PRODUCT}/" \
      --label="bazel_vendordlkmimage" || {
      echo "error：vendor_dlkm image build fail"
      exit 1
      }

    # Exit after successful build
    exit 0
  fi

  # Update symbol list
  if [ -n "${build_abi_update_symbol_list}" ]; then
    run_bazel_target \
      --target="//kernel_imx:imx_modules_abi_update_symbol_list" \
      --label="bazel_abi_update_symbol_list"

    # Exit after successful build
    exit 0
  fi

  # Build complete vendor_boot.img when no specific target is specified
  if [ ${build_whole_android_flag} -eq 1 ]; then
    echo ">>> Building complete vendor_boot.img and vendor_dlkm.img with Bazel <<<"

    # First build ramdisk.lz4
    run_bazel_target \
      --target="//kernel_imx:imx_${TARGET_PRODUCT}_aarch64_vendor_boot_dist" \
      --output="out/imx_${TARGET_PRODUCT}_aarch64/dist/ramdisk.lz4" \
      --dest="$orig_dir/vendor/nxp-opensource/imx-gki/" \
      --label="bazel_vendorbootimage" || {
      echo "error：vendor boot ramdisk.lz4 build fail"
      exit 1
      }

   # Build vendor DLKM image (vendor_dlkm.img)
    run_bazel_target \
      --target="//kernel_imx:imx_${TARGET_PRODUCT}_aarch64_vendor_dlkm_dist" \
      --output="out/imx_${TARGET_PRODUCT}_aarch64/dist/vendor_dlkm.img" \
      --dest="$orig_dir/out/target/product/${TARGET_PRODUCT}/" \
      --label="bazel_vendordlkmimage" || {
      echo "error：vendor_dlkm image build fail"
      exit 1
      }

  fi
fi

# vvcam.ko need build with in-tree modules each time to make sure "insmod vvcam.ko" works
if [ -n "${build_kernel_modules}" ] && [ ${TARGET_PRODUCT} = "evk_8mp" ]; then
    build_vvcam="vvcam";
    build_kernel_oot_module_flag=1;
fi

# mlan.ko and moal.ko need build with in-tree modules each time to make sure "insmod mlan.ko" and "insmod moal.ko" works
if [ -n "${build_kernel_modules}" ]; then
    build_mxmwifi="mxmwifi";
    build_kernel_oot_module_flag=1;
fi

product_makefile=`pwd`/`find device/nxp -maxdepth 4 -name "${TARGET_PRODUCT}.mk"`;
product_path=${product_makefile%/*}
soc_path=${product_path%/*}
nxp_git_path=${soc_path%/*}

if [ -n "${build_kernel_modules}" ] && [ ${TARGET_PRODUCT} = "mek_8q" ]; then
    make -f ${nxp_git_path}/common/build/encrypt_and_sign_firmware.mk manifest build encrypt sign clean< /dev/null || exit
fi

if [ -n "${build_kernel}" ] && [ ${TARGET_PRODUCT} = "evk_95" ]; then
    make -f ${nxp_git_path}/common/build/encrypt_and_sign_firmware.mk manifest build encrypt sign clean< /dev/null || exit
fi

# if uboot is to be compiled, remove the UBOOT_COLLECTION directory
if [ -n "${build_bootloader}" ]; then
    rm -rf ${OUT}/obj/UBOOT_COLLECTION
fi

# redirect standard input to /dev/null to avoid manually input in kernel configuration stage
soc_path=${soc_path} product_path=${product_path} nxp_git_path=${nxp_git_path} clean_build=${clean_build} \
    make -C ./ -f ${nxp_git_path}/common/build/Makefile ${parallel_option} \
    ${build_bootloader} ${build_kernel} ${build_partition_imgs} </dev/null || exit
# in the execution of this script, if the kernel build env is cleaned or configured, do not trigger that again
if [ -n "${build_kernel}" ]; then
    skip_config_or_clean=1
fi


if [ -n "${build_kernel_modules}" ]; then
    soc_path=${soc_path} product_path=${product_path} nxp_git_path=${nxp_git_path} clean_build=${clean_build} \
        skip_config_or_clean=${skip_config_or_clean} make -C ./ -f ${nxp_git_path}/common/build/Makefile ${parallel_option} \
        ${build_kernel_modules} </dev/null || exit
    skip_config_or_clean=1
fi

if [ -n "${build_kernel_dts}" ]; then
    soc_path=${soc_path} product_path=${product_path} nxp_git_path=${nxp_git_path} clean_build=${clean_build} \
        skip_config_or_clean=${skip_config_or_clean} make -C ./ -f ${nxp_git_path}/common/build/Makefile ${parallel_option} \
        ${build_kernel_dts} </dev/null || exit
    skip_config_or_clean=1
fi

if [ ${build_kernel_oot_module_flag} -eq 1 ] || [ -n "${build_kernel_modules}" ]; then
    soc_path=${soc_path} product_path=${product_path} nxp_git_path=${nxp_git_path} clean_build=${clean_build} \
        skip_config_or_clean=${skip_config_or_clean} make -C ./ -f ${nxp_git_path}/common/build/Makefile ${parallel_option} \
        ${build_vvcam} ${build_galcore} ${build_mxmwifi} </dev/null || exit
fi

if [ ${build_android_flag} -eq 1 ] || [ ${build_whole_android_flag} -eq 1 ]; then
    # source envsetup.sh before building Android rootfs, the time spent on building uboot/kernel
    # before this does not count in the final result
    source build/envsetup.sh
    if [ -n "${build_bootimage}" ] || [ ${build_whole_android_flag} -eq 1 ]; then
        rm -rf ${OUT}/boot.img
    fi
    TARGET_IMX_KERNEL=true make ${parallel_option} ${build_bootimage} ${build_vendorbootimage} ${build_dtboimage} ${build_vendordlkmimage} || exit
    if [ -n "${build_bootimage}" ] || [ ${build_whole_android_flag} -eq 1 ]; then
        if [ ${TARGET_PRODUCT} = "evk_8mp" ] || [ ${TARGET_PRODUCT} = "evk_8mn" ] \
        || [ ${TARGET_PRODUCT} = "evk_8ulp" ] || [ ${TARGET_PRODUCT} = "mek_8q" ] \
        || [ ${TARGET_PRODUCT} = "evk_8mm" ] || [ ${TARGET_PRODUCT} = "evk_8mq" ] \
        || [ ${TARGET_PRODUCT} = "evk_95" ]; then
            if [ ${enable_gki} -eq 1 ]; then
                mv ${OUT}/boot.img ${OUT}/boot-imx.img
                make bootimage
            fi
        fi
    fi
fi

# copy the uboot output to ${OUT_DIR}
if [ -n "${build_bootloader}" ]; then
    cp -f ${OUT}/obj/UBOOT_COLLECTION/*\.* ${OUT}
fi

