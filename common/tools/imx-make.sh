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
           kernel                  kernel, include related dts will be compiled
           galcore                 galcore.ko in GPU repo will be compiled
           vvcam                   vvcam.ko, the ISP driver will be compiled
           dtboimage               dtbo images will be built out
           bootimage               boot.img will be built out
           vendorimage             vendor.img will be built out
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
build_bootloader_kernel_flag=0
build_android_flag=0
build_bootloader=""
build_kernel=""
build_galcore=""
build_vvcam=""
build_bootimage=""
build_dtboimage=""
build_vendorimage=""
parallel_option=""
clean_build=0
TOP=`pwd`

# process of the arguments
args=( "$@" )
for arg in ${args[*]} ; do
    case ${arg} in
        -h) help;;
        --help) help;;
        -c) clean_build=1;;
        bootloader) build_bootloader_kernel_flag=1;
                    build_bootloader="bootloader";;
        kernel) build_bootloader_kernel_flag=1;
                    build_kernel="${OUT}/kernel";;
        galcore) build_bootloader_kernel_flag=1;
                    build_galcore="galcore";;
        vvcam) build_bootloader_kernel_flag=1;
                    build_vvcam="vvcam";;
        bootimage) build_bootloader_kernel_flag=1;
                    build_android_flag=1;
                    build_kernel="${OUT}/kernel";
                    build_bootimage="bootimage";;
        dtboimage) build_kernel_flag=1;
                    build_android_flag=1;
                    build_kernel="${OUT}/kernel";
                    build_dtboimage="dtboimage";;
        vendorimage) build_bootloader_kernel_flag=1;
                    build_android_flag=1;
                    build_kernel="${OUT}/kernel";
                    build_vendorimage="vendorimage";;
        *) handle_special_arg ${arg};;
    esac
done

# if bootloader and kernel not in arguments, all need to be made
if [ ${build_bootloader_kernel_flag} -eq 0 ] && [ ${build_android_flag} -eq 0 ]; then
    build_bootloader="bootloader";
    build_kernel="${OUT}/kernel";
    build_android_flag=1
fi

# vvcam.ko need build with kernel each time to make sure "insmod vvcam.ko" works
if [ -n "${build_kernel}" ] && [ ${TARGET_PRODUCT} = "evk_8mp" ]; then
    build_vvcam="vvcam";
fi

product_makefile=`pwd`/`find device/fsl -maxdepth 4 -name "${TARGET_PRODUCT}.mk"`;
product_path=${product_makefile%/*}
soc_path=${product_path%/*}
fsl_git_path=${soc_path%/*}

apply_patch()
{
    patch_dir=$TOP/vendor/nxp/fsl-proprietary/patches
    if [ -d "$patch_dir" ]; then
        cd $patch_dir
        for patch_name in `find . -name *.patch`
        do
            # remove "./" in the name
            patch_name=${patch_name#*/}
            patch_git=`dirname $patch_name`
            cd $TOP/$patch_git
            echo "apply patch to $patch_git: git am -3 -q $patch_dir/$patch_name"
            git am -3 -q $patch_dir/$patch_name
            if [ $? -ne 0 ]; then
                echo "`basename $0`: please fix conflicts when apply patch in $patch_git, then try again."
                exit 1;
            fi
        done
    fi
    cd $TOP
}

# redirect standard input to /dev/null to avoid manually input in kernel configuration stage
soc_path=${soc_path} product_path=${product_path} fsl_git_path=${fsl_git_path} clean_build=${clean_build} \
    make -C ./ -f ${fsl_git_path}/common/build/Makefile ${parallel_option} \
    ${build_bootloader} ${build_kernel} </dev/null || exit

soc_path=${soc_path} product_path=${product_path} fsl_git_path=${fsl_git_path} clean_build=${clean_build} \
    make -C ./ -f ${fsl_git_path}/common/build/Makefile ${parallel_option} \
    ${build_vvcam} ${build_galcore} </dev/null || exit

if [ ${build_android_flag} -eq 1 ]; then
    # source envsetup.sh before building Android rootfs, the time spent on building uboot/kernel
    # before this does not count in the final result
    source build/envsetup.sh
    make ${parallel_option} ${build_bootimage} ${build_dtboimage} ${build_vendorimage}
fi
