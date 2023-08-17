#!/bin/bash -e

help() {

bn=`basename $0`
cat << EOF

Version: 1.8
Last change: change the recommended uuu version as VID/PID values used in uboot are changed
currently suported platforms: evk_7ulp, evk_8mm, evk_8mq, evk_8mn, evk_8mp, mek_8q, mek_8q_car

eg: ./uuu_imx_android_flash.sh -f imx8mm -a -e -D ~/evk_8mm/ -t emmc -u trusty -d mipi-panel

Usage: $bn <option>

options:
  -h                displays this help message
  -f soc_name       flash android image file with soc_name
  -a                only flash image to slot_a
  -b                only flash image to slot_b
  -c card_size      optional setting: 13 / 28
                        If not set, use partition-table.img/partition-table-dual.img (default)
                        If set to 13, use partition-table-13GB.img for 16GB SD card
                        If set to 28, use partition-table-28GB.img/partition-table-28GB-dual.img for 32GB SD card
                    Make sure the corresponding file exist for your platform
  -m                flash mcu image
  -u uboot_feature  flash uboot or spl&bootloader image with "uboot_feature" in their names
                        For Standard Android:
                            If the parameter after "-u" option contains the string of "dual", then spl&bootloader image will be flashed,
                            otherwise uboot image will be flashed
                        For Android Automative:
                            only dual bootloader feature is supported, by default spl&bootloader image will be flashed
                        Below table lists the legal value supported now based on the soc_name provided:
                           ┌────────────────┬──────────────────────────────────────────────────────────────────────────────────────────────────────┐
                           │   soc_name     │  legal parameter after "-u"                                                                          │
                           ├────────────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────┤
                           │   imx8mm       │  dual trusty-dual 4g-evk-uuu 4g ddr4-evk-uuu ddr4 evk-uuu trusty-secure-unlock-dual                  │
                           ├────────────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────┤
                           │   imx8mn       │  dual trusty-dual evk-uuu trusty-secure-unlock-dual ddr4-evk-uuu ddr4                                │
                           ├────────────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────┤
                           │   imx8mq       │  dual trusty-dual evk-uuu trusty-secure-unlock-dual                                                  │
                           ├────────────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────┤
                           │   imx8mp       │  dual trusty-dual evk-uuu trusty-secure-unlock-dual powersave trusty-powersave-dual                  │
                           ├────────────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────┤
                           │   imx8ulp      │  dual trusty-dual evk-uuu trusty-secure-unlock-dual 9x9-evk-uuu 9x9 trusty-9x9-dual trusty-lpa-dual  │
                           ├────────────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────┤
                           │   imx8qxp      │  dual trusty-dual mek-uuu trusty-secure-unlock-dual secure-unlock c0 c0-dual                         │
                           │                │  trusty-c0-dual mek-c0-uuu                                                                           │
                           ├────────────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────┤
                           │   imx8qm       │  dual trusty-dual mek-uuu trusty-secure-unlock-dual secure-unlock md hdmi xen                        │
                           ├────────────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────┤
                           │   imx93        │  evk-uuu                                                                                             │
                           ├────────────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────┤
                           │   imx7ulp      │  evk-uuu                                                                                             │
                           └────────────────┴──────────────────────────────────────────────────────────────────────────────────────────────────────┘

  -d dtb_feature    flash dtbo, vbmeta and recovery image file with "dtb_feature" in their names
                        If not set, default dtbo, vbmeta and recovery image will be flashed
                        Below table lists the legal value supported now based on the soc_name provided:
                           ┌────────────────┬──────────────────────────────────────────────────────────────────────────────────────────────────────┐
                           │   soc_name     │  legal parameter after "-d"                                                                          │
                           ├────────────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────┤
                           │   imx8mm       │  ddr4 m4 mipi-panel mipi-panel-rm67191                                                               │
                           ├────────────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────┤
                           │   imx8mn       │  mipi-panel mipi-panel-rm67191 rpmsg ddr4 ddr4-mipi-panel mipi-panel-rm67191 ddr4-rpmsg              │
                           ├────────────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────┤
                           │   imx8mq       │  dual mipi-panel mipi-panel-rm67191                                                                  │
                           ├────────────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────┤
                           │   imx8mp       │  rpmsg lvds-panel lvds mipi-panel mipi-panel-rm67191 basler powersave powersave-non-rpmsg            │
                           │                │  basler-ov5640 ov5640.img sof dual-basler os08a20-ov5640 os08a20                                     │
                           ├────────────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────┤
                           │   imx8qxp      │  sof                                                                                                 │
                           ├────────────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────┤
                           │   imx8qm       │  hdmi mipi-panel mipi-panel-rm67191 md xen esai sof                                                  │
                           ├────────────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────┤
                           │   imx8ulp      │  hdmi epdc 9x9 9x9-hdmi sof lpa                                                                      │
                           ├────────────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────┤
                           │   imx93        │                                                                                                      │
                           ├────────────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────┤
                           │   imx7ulp      │  evk-mipi evk mipi                                                                                   │
                           └────────────────┴──────────────────────────────────────────────────────────────────────────────────────────────────────┘

  -e                erase user data after all image files being flashed
  -D directory      the directory of images
                        No need to use this option if images are in current working directory
  -t target_dev     emmc or sd, emmc is default target_dev, make sure target device exist
  -p board          specify board for imx6dl, imx6q, imx6qp and imx8mq, since more than one platform we maintain Android on use these chips
                        For imx6dl, imx6q, imx6qp, this is mandatory, it can be followed with sabresd or sabreauto
                        For imx8mq, this option is only used internally. No need for other users to use this option
                        For other chips, this option doesn't work
  -y yocto_image    flash yocto image together with imx8qm auto xen images. The parameter follows "-y" option should be a full path name
                        including the name of yocto sdcard image, this parameter could be a relative path or an absolute path
  -i                with this option used, after uboot for uuu loaded and executed to fastboot mode with target device chosen, this script will stop
                        This option is for users to manually flash the images to partitions they want to
  -daemon           after uuu script generated, uuu will be invoked with daemon mode. It is used for flash multi boards
  -dryrun           only generate the uuu script under /tmp direcbory but not flash images
  -usb usb_path     specify a usb path like 1:1 to monitor. It can be used multiple times to specify more than one path
EOF

}

# this function checks whether the value of first parameter is in the array value of second parameter
# pass the name of the (array)variable to this function. the first is potential element, the second one is array.
# make sure the first parameter is not empty
function whether_in_array
{
    local potential_element=`eval echo \$\{${1}\}`
    local array=(`eval echo \$\{${2}\[\*\]\}`)
    local array_length=${#array[*]}
    local last_element=${array[${array_length}-1]}

    for arg in ${array[*]}
    do
        if [ "${arg}" = "${potential_element}" ]; then
            result_value=0
            return 0
        fi
        if [ "${arg}" = "${last_element}" ]; then
            result_value=1
            return 0
        fi
    done
}

function uuu_load_uboot
{

    while [ -f /tmp/uuu.lst${randome_part} ]; do
        randome_part=$RANDOM
    done

    echo uuu_version 1.4.182 > /tmp/uuu.lst${randome_part}
    tmp_files_in_uuu+=(uuu.lst${randome_part})

    ln -sf ${sym_link_directory}${bootloader_used_by_uuu} /tmp/${bootloader_used_by_uuu}${randome_part}
    echo ${sdp}: boot -f ${bootloader_used_by_uuu}${randome_part} >> /tmp/uuu.lst${randome_part}
    tmp_files_in_uuu+=(${bootloader_used_by_uuu}${randome_part})
    # for uboot by uuu which enabled SPL
    if [[ ${soc_name#imx8m} != ${soc_name} ]]; then
        # for images need SDPU
        echo SDPU: delay 1000 >> /tmp/uuu.lst${randome_part}
        echo SDPU: write -f ${bootloader_used_by_uuu}${randome_part} -offset 0x57c00 >> /tmp/uuu.lst${randome_part}
        echo SDPU: jump >> /tmp/uuu.lst${randome_part}
        # for images need SDPV
        echo SDPV: delay 1000 >> /tmp/uuu.lst${randome_part}
        echo SDPV: write -f ${bootloader_used_by_uuu}${randome_part} -skipspl >> /tmp/uuu.lst${randome_part}
        echo SDPV: jump >> /tmp/uuu.lst${randome_part}
    fi
    echo FB: ucmd setenv fastboot_dev mmc >> /tmp/uuu.lst${randome_part}
    echo FB: ucmd setenv mmcdev ${target_num} >> /tmp/uuu.lst${randome_part}
    echo FB: ucmd mmc dev ${target_num} >> /tmp/uuu.lst${randome_part}

    # erase environment variables of uboot
    if [[ ${target_dev} = "emmc" ]]; then
        echo FB: ucmd mmc dev ${target_num} 0 >> /tmp/uuu.lst${randome_part}
    fi
    echo FB: ucmd mmc erase ${uboot_env_start} ${uboot_env_len} >> /tmp/uuu.lst${randome_part}

    if [[ ${target_dev} = "emmc" ]]; then
        echo FB: ucmd mmc partconf ${target_num} 1 1 1 >> /tmp/uuu.lst${randome_part}
    fi

    if [[ ${intervene} -eq 1 ]]; then
        echo FB: done >> /tmp/uuu.lst${randome_part}
        uuu ${usb_paths} /tmp/uuu.lst${randome_part}
        exit 0
    fi
}

function flash_partition
{
    if [ "$(echo ${1} | grep "bootloader_")" != "" ]; then
        img_name=${uboot_proper_to_be_flashed}
    elif [ ${support_vendor_boot} -eq 1 ] && [ "$(echo ${1} | grep "vendor_boot")" != "" ]; then
            img_name="vendor_boot.img"
    elif [ ${support_init_boot} -eq 1 ] && [ "$(echo ${1} | grep "init_boot")" != "" ]; then
            img_name="init_boot.img"
    elif [ "$(echo ${1} | grep "system_ext")" != "" ]; then
        img_name=${system_extimage_file}
    elif [ "$(echo ${1} | grep "system")" != "" ]; then
        img_name=${systemimage_file}
    elif [ "$(echo ${1} | grep "vendor")" != "" ]; then
        img_name=${vendor_file}
    elif [ "$(echo ${1} | grep "product")" != "" ]; then
        img_name=${product_file}
    elif [ "$(echo ${1} | grep "bootloader")" != "" ]; then
        img_name=${bootloader_flashed_to_board}

    elif [ ${support_dtbo} -eq 1 ] && [ "$(echo ${1} | grep "boot")" != "" ]; then
            img_name="boot.img"
    elif [ "$(echo ${1} | grep "mcu_os")" != "" ]; then
        img_name="${soc_name}_mcu_demo.img"
    elif [ "$(echo ${1} | grep -E "dtbo|vbmeta|recovery")" != "" -a "${dtb_feature}" != "" ]; then
        img_name="${1%_*}-${soc_name}-${dtb_feature}.img"
    elif [ "$(echo ${1} | grep "gpt")" != "" ]; then
        img_name=${partition_file}
    elif [ "$(echo ${1} | grep "super")" != "" ]; then
        img_name=${super_file}
    else
        img_name="${1%_*}-${soc_name}.img"
    fi

    echo -e generate lines to flash ${RED}${img_name}${STD} to the partition of ${RED}${1}${STD}
    ln -sf ${sym_link_directory}${img_name} /tmp/${img_name}${randome_part}
    tmp_files_in_uuu+=(${img_name}${randome_part})
    echo FB[-t 600000]: flash ${1} ${img_name}${randome_part} >> /tmp/uuu.lst${randome_part}
}

function flash_userpartitions
{
    if [ ${support_dual_bootloader} -eq 1 ]; then
        flash_partition ${dual_bootloader_partition}
    fi
    if [ ${support_dtbo} -eq 1 ]; then
        flash_partition ${dtbo_partition}
    fi

    flash_partition ${boot_partition}

    if [ ${support_vendor_boot} -eq 1 ]; then
        flash_partition ${vendor_boot_partition}
    fi

    if [ ${support_init_boot} -eq 1 ]; then
        flash_partition ${init_boot_partition}
    fi

    if [ ${support_recovery} -eq 1 ]; then
        flash_partition ${recovery_partition}
    fi

    if [ ${support_dynamic_partition} -eq 0 ]; then
        flash_partition ${system_partition}
        if [ ${has_system_ext_partition} -eq 1 ]; then
            flash_partition ${system_ext_partition}
        fi
        flash_partition ${vendor_partition}
        flash_partition ${product_partition}
    fi
    flash_partition ${vbmeta_partition}
}

function flash_partition_name
{
    boot_partition="boot"${1}
    recovery_partition="recovery"${1}
    system_partition="system"${1}
    system_ext_partition="system_ext"${1}
    vendor_partition="vendor"${1}
    product_partition="product"${1}
    vbmeta_partition="vbmeta"${1}
    dtbo_partition="dtbo"${1}
    vendor_boot_partition="vendor_boot"${1}
    init_boot_partition="init_boot"${1}
    if [ ${support_dual_bootloader} -eq 1 ]; then
        dual_bootloader_partition=bootloader${1}
    fi
}

function flash_android
{
    # if dual bootloader is supported, the name of the bootloader flashed to the board need to be updated
    if [ ${support_dual_bootloader} -eq 1 ]; then
        bootloader_flashed_to_board=spl-${soc_name}${uboot_feature}.bin
        uboot_proper_to_be_flashed=bootloader-${soc_name}${uboot_feature}.img
        # specially handle xen related condition
        if [[ "${soc_name}" = imx8qm ]] && [[ "${dtb_feature}" = xen ]]; then
            uboot_proper_to_be_flashed=bootloader-${soc_name}-${dtb_feature}.img
        fi
    fi

    # for xen, no need to flash spl
    if [[ "${dtb_feature}" != xen ]]; then
        if [ ${support_dualslot} -eq 1 ]; then
            flash_partition "bootloader0"
        else
            flash_partition "bootloader"
        fi
    fi

    flash_partition "gpt"
    # force to load the gpt just flashed, since for imx6 and imx7, we use uboot from BSP team,
    # so partition table is not automatically loaded after gpt partition is flashed.
    if [[ "${soc_name}" = "imx6"* ]] || [[ "${soc_name}" = "imx7"* ]]; then
        echo FB: ucmd setenv fastboot_dev sata >> /tmp/uuu.lst${randome_part}
        echo FB: ucmd setenv fastboot_dev mmc >> /tmp/uuu.lst${randome_part}
    fi

    # if a platform doesn't support dual slot but a slot is selected, ignore it.
    if [ ${support_dualslot} -eq 0 ] && [ "${slot}" != "" ]; then
        echo -e >&2 ${RED}ab slot feature not supported, the slot you specified will be ignored${STD}
        slot=""
    fi

    # since imx7ulp use uboot for uuu from BSP team,there is no hardcoded mcu_os partition. If m4 need to be flashed, flash it here.
    if [[ ${soc_name} == imx7ulp ]] && [[ ${flash_mcu} -eq 1 ]]; then
        # download m4 image to dram
        ln -sf ${sym_link_directory}${soc_name}_m4_demo.img /tmp/${soc_name}_m4_demo.img${randome_part}
        tmp_files_in_uuu+=(${soc_name}_m4_demo.img${randome_part})
        echo -e generate lines to flash ${RED}${soc_name}_m4_demo.img${STD} to the partition of ${RED}m4_os${STD}
        echo FB: ucmd setenv fastboot_buffer ${imx7ulp_stage_base_addr} >> /tmp/uuu.lst${randome_part}
        echo FB: download -f ${soc_name}_m4_demo.img${randome_part} >> /tmp/uuu.lst${randome_part}

        echo FB: ucmd sf probe >> /tmp/uuu.lst${randome_part}
        echo FB[-t 30000]: ucmd sf erase `echo "obase=16;$((${imx7ulp_evk_m4_sf_start}*${imx7ulp_evk_sf_blksz}))" | bc` \
                `echo "obase=16;$((${imx7ulp_evk_m4_sf_length}*${imx7ulp_evk_sf_blksz}))" | bc` >> /tmp/uuu.lst${randome_part}

        echo FB[-t 30000]: ucmd sf write ${imx7ulp_stage_base_addr} `echo "obase=16;$((${imx7ulp_evk_m4_sf_start}*${imx7ulp_evk_sf_blksz}))" | bc` \
                `echo "obase=16;$((${imx7ulp_evk_m4_sf_length}*${imx7ulp_evk_sf_blksz}))" | bc` >> /tmp/uuu.lst${randome_part}
    else
        if [[ ${flash_mcu} -eq 1 ]]; then
            flash_partition ${mcu_os_partition}
        fi
    fi

    if [ "${slot}" = "" ] && [ ${support_dualslot} -eq 1 ]; then
        #flash image to a and b slot
        flash_partition_name "_a"
        flash_userpartitions

        flash_partition_name "_b"
        flash_userpartitions
    else
        flash_partition_name ${slot}
        flash_userpartitions
    fi
    # super partition does not have a/b slot, handle it individually
    if [ ${support_dynamic_partition} -eq 1 ]; then
        flash_partition ${super_partition}
    fi
}

function clean_tmp_files
{
    if [ "${1}" = "0" ]; then
        for file in ${tmp_files_before_uuu[*]}
        do
            rm -rf /tmp/${file}
        done
    else
        for file in ${tmp_files_in_uuu[*]}
        do
            rm -rf /tmp/${file}
        done
    fi
}

# parse command line
soc_name=""
uboot_feature=""
dtb_feature=""
card_size=0
slot=""
systemimage_file="system.img"
system_extimage_file="system_ext.img"
vendor_file="vendor.img"
product_file="product.img"
partition_file="partition-table.img"
super_file="super.img"
support_dtbo=0
support_recovery=0
support_dualslot=0
support_mcu_os=0
support_trusty=0
support_dynamic_partition=0
support_vendor_boot=0
support_init_boot=0
boot_partition="boot"
recovery_partition="recovery"
system_partition="system"
system_ext_partition="system_ext"
has_system_ext_partition=0
vendor_partition="vendor"
product_partition="product"
vbmeta_partition="vbmeta"
dtbo_partition="dtbo"
vendor_boot_partition="vendor_boot"
init_boot_partition="init_boot"
mcu_os_partition="mcu_os"
super_partition="super"

flash_mcu=0
erase=0
image_directory=""
target_dev="emmc"
RED='\033[0;31m'
STD='\033[0;0m'
sdp="SDP"
uboot_env_start=0
uboot_env_len=0
board=""
imx7ulp_evk_m4_sf_start=0
imx7ulp_evk_m4_sf_length=256
imx7ulp_evk_sf_blksz=512
imx7ulp_stage_base_addr=0x60800000
imx8qm_stage_base_addr=0x98000000
bootloader_used_by_uuu=""
bootloader_flashed_to_board=""
yocto_image=""
intervene=0
support_dual_bootloader=0
dual_bootloader_partition=""
current_working_directory=""
sym_link_directory=""
yocto_image_sym_link=""
daemon_mode=0
dryrun=0
result_value=0
usb_paths=""
randome_part=0

# We want to detect illegal feature input to some extent. Here it's based on SoC names. Since an SoC may be on a
# board running different set of images(android and automative for a example), so misuse the features of one set of
# images when flash another set of images can not be detect early with this scenario.
imx8mm_uboot_feature=(dual trusty-dual 4g-evk-uuu 4g ddr4-evk-uuu ddr4 evk-uuu trusty-secure-unlock-dual)
imx8mn_uboot_feature=(dual trusty-dual evk-uuu trusty-secure-unlock-dual ddr4-evk-uuu ddr4)
imx8mq_uboot_feature=(dual trusty-dual evk-uuu trusty-secure-unlock-dual)
imx8mp_uboot_feature=(dual trusty-dual evk-uuu trusty-secure-unlock-dual powersave trusty-powersave-dual)
imx8ulp_uboot_feature=(dual trusty-dual evk-uuu trusty-secure-unlock-dual 9x9-evk-uuu 9x9 trusty-9x9-dual trusty-lpa-dual)
imx8qxp_uboot_feature=(dual trusty-dual mek-uuu trusty-secure-unlock-dual secure-unlock c0 c0-dual trusty-c0-dual mek-c0-uuu)
imx8qm_uboot_feature=(dual trusty-dual mek-uuu trusty-secure-unlock-dual secure-unlock md hdmi xen)
imx7ulp_uboot_feature=(evk-uuu)
imx93_uboot_feature=(dual evk-uuu)

imx8mm_dtb_feature=(ddr4 m4 mipi-panel mipi-panel-rm67191)
imx8mn_dtb_feature=(mipi-panel mipi-panel-rm67191 rpmsg ddr4 ddr4-mipi-panel ddr4-mipi-panel-rm67191 ddr4-rpmsg)
imx8mq_dtb_feature=(dual mipi-panel mipi-panel-rm67191 mipi)
imx8mp_dtb_feature=(rpmsg lvds-panel lvds mipi-panel mipi-panel-rm67191 basler powersave powersave-non-rpmsg basler-ov5640 ov5640 sof dual-basler os08a20-ov5640 os08a20)
imx8qxp_dtb_feature=(sof)
imx8qm_dtb_feature=(hdmi hdmi-rx mipi-panel mipi-panel-rm67191 md xen esai sof)
imx8ulp_dtb_feature=(hdmi epdc 9x9 9x9-hdmi sof lpa)
imx93_dtb_feature=()
imx7ulp_dtb_feature=(evk-mipi evk mipi)

tmp_files_before_uuu=()
tmp_files_in_uuu=()


echo -e This script is validated with ${RED}uuu 1.4.182${STD} version, it is recommended to align with this version.

if [ $# -eq 0 ]; then
    echo -e >&2 ${RED}please provide more information with command script options${STD}
    help
    exit
fi

while [ $# -gt 0 ]; do
    case $1 in
        -h) help; exit ;;
        -f) soc_name=$2; shift;;
        -c) card_size=$2; shift;;
        -u) uboot_feature=-$2; shift;;
        -d) dtb_feature=$2; shift;;
        -a) slot="_a" ;;
        -b) slot="_b" ;;
        -m) flash_mcu=1 ;;
        -e) erase=1 ;;
        -D) image_directory=$2; shift;;
        -t) target_dev=$2; shift;;
        -y) yocto_image=$2; shift;;
        -p) board=$2; shift;;
        -i) intervene=1 ;;
        -daemon) daemon_mode=1 ;;
        -dryrun) dryrun=1 ;;
        -usb) usb_paths="${usb_paths} -m $2"; shift;;
        *)  echo -e >&2 ${RED}the option \"${1}\"  you specified is not supported, please check it${STD}
            help; exit;;
    esac
    shift
done

# Process of the uboot_feature parameter
if [[ "${uboot_feature}" = *"trusty"* ]] || [[ "${uboot_feature}" = *"secure"* ]]; then
    support_trusty=1;
fi
if [[ "${uboot_feature}" = *"dual"* ]]; then
    support_dual_bootloader=1;
fi


# TrustyOS can't boot from SD card
if [ "${target_dev}" = "sd" ] && [ ${support_trusty} -eq 1 ]; then
    echo -e >&2 ${RED}can not boot up from SD with trusty enabled${STD};
    help; exit 1;
fi

# -i option should not be used together with -daemon
if [ ${intervene} -eq 1 ] && [ ${daemon_mode} -eq 1 ]; then
    echo -daemon mode will be igonred
fi

# for specified directory, make sure there is a slash at the end
if [[ "${image_directory}" != "" ]]; then
     image_directory="${image_directory%/}/";
fi

# for conditions that the path specified is current working directory or no path specified
if [[ "${image_directory}" == "" ]] || [[ "${image_directory}" == "./" ]]; then
    sym_link_directory=`pwd`;
    sym_link_directory="${sym_link_directory%/}/";
# for conditions that absolute path is specified
elif [[ "${image_directory#/}" != "${image_directory}" ]] || [[ "${image_directory#~}" != "${image_directory}" ]]; then
    sym_link_directory=${image_directory};
# for other relative path specified
else
    sym_link_directory=`pwd`;
    sym_link_directory="${sym_link_directory%/}/";
    sym_link_directory=${sym_link_directory}${image_directory}
fi

# if absolute path is used
if [[ "${yocto_image#/}" != "${yocto_image}" ]] || [[ "${yocto_image#~}" != "${yocto_image}" ]]; then
    yocto_image_sym_link=${yocto_image}
# if other relative path is used
else
    yocto_image_sym_link=`pwd`;
    yocto_image_sym_link="${yocto_image_sym_link%/}/";
    yocto_image_sym_link=${yocto_image_sym_link}${yocto_image}
fi


# if card_size is not correctly set, exit.
if [ ${card_size} -ne 0 ] && [ ${card_size} -ne 7 ] && [ ${card_size} -ne 13 ] && [ ${card_size} -ne 28 ]; then
    echo -e >&2 ${RED}card size ${card_size} is not legal${STD};
    help; exit 1;
fi

# dual bootloader support will use different gpt, this is for imx8m and imx8ulp
if [ ${support_dual_bootloader} -eq 1 ]; then
    if [ ${card_size} -gt 0 ]; then
        partition_file="partition-table-${card_size}GB-dual.img";
    else
        partition_file="partition-table-dual.img";
    fi
else
    if [ ${card_size} -gt 0 ]; then
        partition_file="partition-table-${card_size}GB.img";
    else
        partition_file="partition-table.img";
    fi
fi


randome_part=$RANDOM
while [ -f /tmp/partition-table_1.txt${randome_part} ]; do
    randome_part=$RANDOM
done

# dump the partition table image file into text file and check whether some partition names are in it
hexdump -C -v ${image_directory}${partition_file} > /tmp/partition-table_1.txt${randome_part}
tmp_files_before_uuu+=(partition-table_1.txt${randome_part})
# get the 2nd to 17th colunmns, it's hex value in text mode for partition table file
awk '{for(i=2;i<=17;i++) printf $i" "; print ""}' /tmp/partition-table_1.txt${randome_part} > /tmp/partition-table_2.txt${randome_part}
tmp_files_before_uuu+=(partition-table_2.txt${randome_part})
# put all the lines in a file into one line
sed ':a;N;$!ba;s/\n//g' /tmp/partition-table_2.txt${randome_part} > /tmp/partition-table_3.txt${randome_part}
tmp_files_before_uuu+=(partition-table_3.txt${randome_part})
# check whether there is "bootloader_b" in partition file
grep "62 00 6f 00 6f 00 74 00 6c 00 6f 00 61 00 64 00 65 00 72 00 5f 00 62 00" /tmp/partition-table_3.txt${randome_part} > /dev/null \
        && support_dual_bootloader=1 && echo dual bootloader is supported
# check whether there is "dtbo" in partition file
grep "64 00 74 00 62 00 6f 00" /tmp/partition-table_3.txt${randome_part} > /dev/null \
        && support_dtbo=1 && echo dtbo is supported
# check whether there is "recovery" in partition file
grep "72 00 65 00 63 00 6f 00 76 00 65 00 72 00 79 00" /tmp/partition-table_3.txt${randome_part} > /dev/null \
        && support_recovery=1 && echo recovery is supported
# check whether there is "boot_b" in partition file
grep "62 00 6f 00 6f 00 74 00 5f 00 61 00" /tmp/partition-table_3.txt${randome_part} > /dev/null \
        && support_dualslot=1 && echo dual slot is supported
# check whether there is "super" in partition table
grep "73 00 75 00 70 00 65 00 72 00" /tmp/partition-table_3.txt${randome_part} > /dev/null \
        && support_dynamic_partition=1 && echo dynamic parttition is supported

# check whether there is "vendor_boot" in partition table
grep "76 00 65 00 6e 00 64 00 6f 00 72 00 5f 00 62 00 6f 00 6f 00 74 00 5f 00" /tmp/partition-table_3.txt${randome_part} > /dev/null \
        && support_vendor_boot=1 && echo vendor_boot parttition is supported

# check whether there is "init_boot" in partition table
grep "69 00 6e 00 69 00 74 00 5f 00 62 00 6f 00 6f 00 74 00 5f 00" /tmp/partition-table_3.txt${randome_part} > /dev/null \
        && support_init_boot=1 && echo init_boot parttition is supported

grep "73 00 79 00 73 00 74 00 65 00 6d 00 5f 00 65 00 78 00 74 00" /tmp/partition-table_3.txt${randome_part} > /dev/null \
&& has_system_ext_partition=1 && echo has system_ext partition

clean_tmp_files "0"

# get device and board specific parameter
case ${soc_name%%-*} in
    imx8qm)
            vid=0x1fc9; pid=0x0129; chip=MX8QM;
            uboot_env_start=0x2000; uboot_env_len=0x10;
            emmc_num=0; sd_num=1;
            board=mek ;;
    imx8qxp)
            vid=0x1fc9; pid=0x012f; chip=MX8QXP;
            uboot_env_start=0x2000; uboot_env_len=0x10;
            emmc_num=0; sd_num=1;
            board=mek ;;
    imx8mq)
            vid=0x1fc9; pid=0x012b; chip=MX8MQ;
            uboot_env_start=0x2000; uboot_env_len=0x8;
            emmc_num=0; sd_num=1;
            if [ -z "$board" ]; then
                board=evk;
            fi ;;
    imx8mm)
            vid=0x1fc9; pid=0x0134; chip=MX8MM;
            uboot_env_start=0x2000; uboot_env_len=0x8;
            emmc_num=2; sd_num=1;
            board=evk ;;
    imx8mn)
            vid=0x1fc9; pid=0x0134; chip=MX8MN;
            uboot_env_start=0x2000; uboot_env_len=0x8;
            emmc_num=2; sd_num=1;
            board=evk ;;
    imx8mp)
            vid=0x1fc9; pid=0x0146; chip=MX8MP;
            uboot_env_start=0x2000; uboot_env_len=0x8;
            emmc_num=2; sd_num=1;
            board=evk ;;
    imx8ulp)
            vid=0x1fc9; pid=0x014a; chip=MX8ULP;
            uboot_env_start=0x2000; uboot_env_len=0x8;
            emmc_num=0; sd_num=2;
            board=evk ;;
    imx93)
            vid=0x1fc9; pid=0x0152; chip=MX93;
            uboot_env_start=0x2000; uboot_env_len=0x8;
            emmc_num=0; sd_num=1;
            board=evk ;;
    imx7ulp)
            vid=0x1fc9; pid=0x0126; chip=MX7ULP;
            uboot_env_start=0x700; uboot_env_len=0x10;
            sd_num=0;
            board=evk ;;
    imx7d)
            vid=0x15a2; pid=0x0076; chip=MX7D;
            uboot_env_start=0x700; uboot_env_len=0x10;
            sd_num=0;
            board=sabresd ;;
    imx6sx)
            vid=0x15a2; pid=0x0071; chip=MX6SX;
            uboot_env_start=0x700; uboot_env_len=0x10;
            sd_num=2;
            board=sabresd ;;
    imx6dl)
            vid=0x15a2; pid=0x0061; chip=MX6D;
            uboot_env_start=0x700; uboot_env_len=0x10;
            emmc_num=2; sd_num=1 ;;
    imx6q)
            vid=0x15a2; pid=0x0054; chip=MX6Q;
            uboot_env_start=0x700; uboot_env_len=0x10;
            emmc_num=2; sd_num=1 ;;
    imx6qp)
            vid=0x15a2; pid=0x0054; chip=MX6Q;
            uboot_env_start=0x700; uboot_env_len=0x10;
            emmc_num=2; sd_num=1 ;;
    *)

            echo -e >&2 ${RED}the soc_name you specified is not supported${STD};
            help; exit 1;
esac

# test whether board info is specified for imx6dl, imx6q and imx6qp
if [[ "${board}" == "" ]]; then
    if [[ "$(echo ${dtb_feature} | grep "ldo")" != "" ]]; then
            board=sabresd;

        else
            echo -e >&2 ${RED}board info need to be specified for imx6dl, imx6q and imx6qp with -p option, it can be sabresd or sabreauto${STD};
            help; exit 1;
        fi
fi

# test whether target device is supported
if [ ${soc_name#imx7} != ${soc_name} ] || [ ${soc_name#imx6} != ${soc_name} -a ${board} = "sabreauto" ] \
    || [ ${soc_name#imx6} != ${soc_name} -a ${soc_name} = "imx6sx" ]; then
    if [ ${target_dev} = "emmc" ]; then
        echo -e >&2 ${soc_name}-${board} does not support emmc as target device, \
                change target device automatically;
        target_dev=sd;
    fi
fi

# set target_num based on target_dev
if [[ ${target_dev} = "emmc" ]]; then
    target_num=${emmc_num};
else
    target_num=${sd_num};
fi

# check whether provided spl/bootloader/uboot feature is legal
if [ -n "${uboot_feature}" ]; then
    uboot_feature_no_pre_hyphen=${uboot_feature#-}
    whether_in_array uboot_feature_no_pre_hyphen ${soc_name}_uboot_feature
    if [ ${result_value} != 0 ]; then
        echo -e >&2 ${RED}illegal parameter \"${uboot_feature_no_pre_hyphen}\" for \"-u\" option${STD}
        help; exit 1;
    fi
fi

# check whether provided dtb feature is legal
if [ -n "${dtb_feature}" ]; then
    dtb_feature_no_pre_hyphen=${dtb_feature#-}
    whether_in_array dtb_feature_no_pre_hyphen ${soc_name}_dtb_feature
    if [ ${result_value} != 0 ]; then
        echo -e >&2 ${RED}illegal parameter \"${dtb_feature}\" for \"-d\" option${STD}
        help; exit 1;
    fi
fi

# set sdp command name based on soc_name
if [[ ${soc_name#imx8q} != ${soc_name} ]] || [[ ${soc_name} == "imx8mn" ]] || [[ ${soc_name} == "imx8mp" ]] || [[ ${soc_name} == "imx8ulp" ]] || [[ ${soc_name} == "imx93" ]]; then
    sdp="SDPS"
fi

# default bootloader image name
bootloader_used_by_uuu=u-boot-${soc_name}-${board}-uuu.imx
bootloader_flashed_to_board="u-boot-${soc_name}${uboot_feature}.imx"

# find the names of the bootloader used by uuu
if [ "${soc_name}" = imx8mm ] || [ "${soc_name}" = imx8mn ]; then
    if [[ "${uboot_feature}" = *"ddr4"* ]]; then
        bootloader_used_by_uuu=u-boot-${soc_name}-ddr4-${board}-uuu.imx
    elif [[ "${uboot_feature}" = *"4g"* ]]; then
        bootloader_used_by_uuu=u-boot-${soc_name}-4g-${board}-uuu.imx
    fi
fi

if [ "${soc_name}" = imx8qxp ]; then
    if [[ "${uboot_feature}" = *"c0"* ]]; then
        bootloader_used_by_uuu=u-boot-${soc_name}-${board}-c0-uuu.imx
    fi
fi

if [ "${soc_name}" = imx8ulp ]; then
    if [[ "${uboot_feature}" = *"9x9"* ]]; then
        bootloader_used_by_uuu=u-boot-${soc_name}-9x9-${board}-uuu.imx
    fi
fi


uuu_load_uboot

flash_android

# flash yocto image along with mek_8qm auto xen images
if [[ "${yocto_image}" != "" ]]; then
    if [ ${soc_name} != "imx8qm" ] || [ "${dtb_feature}" != "xen" ]; then
        echo -e >&2 ${RED}-y option only applies for imx8qm xen images${STD}
        help; exit 1;
    fi

    target_num=${sd_num}
    echo FB: ucmd setenv fastboot_dev mmc >> /tmp/uuu.lst${randome_part}
    echo FB: ucmd setenv mmcdev ${target_num} >> /tmp/uuu.lst${randome_part}
    echo FB: ucmd mmc dev ${target_num} >> /tmp/uuu.lst${randome_part}
    echo -e generate lines to flash ${RED}`basename ${yocto_image}`${STD} to the partition of ${RED}all${STD}
    ln -sf ${yocto_image_sym_link} /tmp/`basename ${yocto_image}`${randome_part}
    echo FB[-t 600000]: flash -raw2sparse all `basename ${yocto_image}`${randome_part} >> /tmp/uuu.lst${randome_part}
    # use "mmc part" to reload part info before "fatwrite"
    echo FB: ucmd mmc list >> /tmp/uuu.lst${randome_part}
    echo FB: ucmd mmc dev ${target_num} >> /tmp/uuu.lst${randome_part}
    echo FB: ucmd mmc part >> /tmp/uuu.lst${randome_part}

    # replace uboot from yocto team with the one from android team
    echo -e generate lines to flash ${RED}u-boot-imx8qm-xen-dom0.imx${STD} to the partition of ${RED}bootloader0${STD} on SD card
    ln -sf ${sym_link_directory}u-boot-imx8qm-xen-dom0.imx /tmp/u-boot-imx8qm-xen-dom0.imx${randome_part}
    echo FB: flash bootloader0 u-boot-imx8qm-xen-dom0.imx${randome_part} >> /tmp/uuu.lst${randome_part}

    xen_uboot_size_dec=`wc -c ${image_directory}spl-${soc_name}-${dtb_feature}.bin | cut -d ' ' -f1`
    xen_uboot_size_hex=`echo "obase=16;${xen_uboot_size_dec}" | bc`
    # write the xen spl from android team to FAT on SD card
    echo -e generate lines to write ${RED}spl-${soc_name}-${dtb_feature}.bin${STD} to ${RED}FAT${STD}
    ln -sf ${sym_link_directory}spl-${soc_name}-${dtb_feature}.bin /tmp/spl-${soc_name}-${dtb_feature}.bin${randome_part}
    echo FB: ucmd setenv fastboot_buffer ${imx8qm_stage_base_addr} >> /tmp/uuu.lst${randome_part}
    echo FB: download -f spl-${soc_name}-${dtb_feature}.bin${randome_part} >> /tmp/uuu.lst${randome_part}
    echo FB: ucmd fatwrite mmc ${sd_num} ${imx8qm_stage_base_addr} spl-${soc_name}-${dtb_feature}.bin${randome_part} 0x${xen_uboot_size_hex} >> /tmp/uuu.lst${randome_part}
    xen_firmware_size_dec=`wc -c ${image_directory}xen | cut -d ' ' -f1`
    xen_firmware_size_hex=`echo "obase=16;${xen_firmware_size_dec}" | bc`
    echo -e generate lines to replace the ${RED}xen firmware${STD} on ${RED}FAT${STD}$
    ln -sf  ${sym_link_directory}xen /tmp/xen${randome_part}
    echo FB: ucmd setenv fastboot_buffer ${imx8qm_stage_base_addr} >> /tmp/uuu.lst${randome_part}
    echo FB: download -f xen${randome_part} >> /tmp/uuu.lst${randome_part}
    echo FB: ucmd fatwrite mmc ${sd_num} ${imx8qm_stage_base_addr} xen${randome_part} 0x${xen_firmware_size_hex} >> /tmp/uuu.lst${randome_part}

    target_num=${emmc_num}
    echo FB: ucmd setenv fastboot_dev mmc >> /tmp/uuu.lst${randome_part}
    echo FB: ucmd setenv mmcdev ${target_num} >> /tmp/uuu.lst${randome_part}
    echo FB: ucmd mmc dev ${target_num} >> /tmp/uuu.lst${randome_part}
fi

echo FB[-t 600000]: erase misc >> /tmp/uuu.lst${randome_part}

# make sure device is locked for boards don't use tee
echo FB[-t 600000]: erase presistdata >> /tmp/uuu.lst${randome_part}
echo FB[-t 600000]: erase fbmisc >> /tmp/uuu.lst${randome_part}
echo FB[-t 600000]: erase metadata >> /tmp/uuu.lst${randome_part}

if [ "${slot}" != "" ] && [ ${support_dualslot} -eq 1 ]; then
    echo FB: set_active ${slot#_} >> /tmp/uuu.lst${randome_part}
fi

if [ ${erase} -eq 1 ]; then
    if [ ${support_recovery} -eq 1 ]; then
        echo FB[-t 600000]: erase cache >> /tmp/uuu.lst${randome_part}
    fi
    echo FB[-t 600000]: erase userdata >> /tmp/uuu.lst${randome_part}
fi

echo FB: done >> /tmp/uuu.lst${randome_part}

if [ ${dryrun} -eq 1 ]; then
    exit
fi

echo "uuu script generated, start to invoke uuu with the generated uuu script"
UUU=${UUU:-"./uuu"}
if [ ${daemon_mode} -eq 1 ]; then
    ${UUU} ${usb_paths} -d /tmp/uuu.lst${randome_part} || clean_tmp_files
    clean_tmp_files
else
    ${UUU} ${usb_paths} /tmp/uuu.lst${randome_part} || clean_tmp_files
    clean_tmp_files
fi

exit 0
