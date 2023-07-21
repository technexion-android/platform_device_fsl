#!/bin/bash

# hardcode this one again in this shell script
CONFIG_REPO_PATH=device/nxp

# import other paths in the file "common/imx_path/ImxPathConfig.mk" of this
# repository

while read -r line
do
	if [ "$(echo ${line} | grep "=")" != "" ]; then
		env_arg=`echo ${line} | cut -d "=" -f1`
		env_arg=${env_arg%:}
		env_arg=`eval echo ${env_arg}`

		env_arg_value=`echo ${line} | cut -d "=" -f2`
		env_arg_value=`eval echo ${env_arg_value}`

		eval ${env_arg}=${env_arg_value}
	fi
done < ${CONFIG_REPO_PATH}/common/imx_path/ImxPathConfig.mk

if [ "${AARCH64_GCC_CROSS_COMPILE}" != "" ]; then
	ATF_CROSS_COMPILE=`eval echo ${AARCH64_GCC_CROSS_COMPILE}`
else
	echo ERROR: \*\*\* env AARCH64_GCC_CROSS_COMPILE is not set
	exit 1
fi

build_m4_image()
{
	echo "android build without building MCU image"
}

_error_exit() {
	echo "ERROR: ${1}"
	false
	exit 1
}

_do_cmd() {
	#echo "CMD: '${1}'"
	eval "${1}"
	return $?
}

build_imx_uboot()
{
	#local _soc_type=$(tr '[:upper:]' '[:lower:]' <<< ${BOARD_SOC_TYPE})
	local _soc_type="imx8mm"
	local _uboot_dtb="${_soc_type}-edm-g_android.dtb"
	local _opt="-v"

	echo Building i.MX U-Boot with firmware
	cp ${_opt} ${UBOOT_OUT}/u-boot-nodtb.$1 ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/
	cp ${_opt} ${UBOOT_OUT}/spl/u-boot-spl.bin  ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/
	cp ${_opt} ${UBOOT_OUT}/tools/mkimage  ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/mkimage_uboot
	#cp ${UBOOT_OUT}/arch/arm/dts/imx8mm-evk.dtb ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/
	_do_cmd "cp ${_opt} -f ${UBOOT_OUT}/arch/arm/dts/${_uboot_dtb} ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/${_soc_type}-evk.dtb" || _error_exit "Copy ${_uboot_dtb} to ${_soc_type}-evk.dtb fail"
	cp ${_opt} ${FSL_PROPRIETARY_PATH}/linux-firmware-imx/firmware/ddr/synopsys/lpddr4_pmu_train* ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/

	# build ATF based on whether tee is involved
	_do_cmd "make -C ${IMX_PATH}/arm-trusted-firmware/ PLAT=`echo $2 | cut -d '-' -f1` clean"
	local _mkcmd="make -C ${IMX_PATH}/arm-trusted-firmware/ CROSS_COMPILE=${ATF_CROSS_COMPILE} PLAT=$(echo $2 | cut -d '-' -f1) bl31 -B LPA=${POWERSAVE_STATE} IMX_ANDROID_BUILD=true"
	if [ "`echo $2 | cut -d '-' -f2`" = "trusty" ]; then
		cp ${_opt} ${FSL_PROPRIETARY_PATH}/fsl-proprietary/uboot-firmware/imx8m/tee-imx8mm.bin ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/tee.bin
		_mkcmd="${_mkcmd} SPD=trusty"
	else
		if [ -f ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/tee.bin ] ; then
			rm -rf ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/tee.bin
		fi
		if [ -f ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/tee.bin.lz4 ] ; then
			rm -rf ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/tee.bin.lz4
		fi
		#_do_cmd "make -C ${IMX_PATH}/arm-trusted-firmware/ CROSS_COMPILE="${ATF_CROSS_COMPILE}" PLAT=`echo $2 | cut -d '-' -f1` bl31 -B LPA=${POWERSAVE_STATE} IMX_ANDROID_BUILD=true 1>/dev/null" || exit 1
	fi

	[[ ${_opt} =~ '-v' ]] || _addon="1>/dev/null"
	_do_cmd "${_mkcmd} ${_addon}" || exit 1

	cp ${IMX_PATH}/arm-trusted-firmware/build/`echo $2 | cut -d '-' -f1`/release/bl31.bin ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/bl31.bin

	_do_cmd "make -C ${IMX_MKIMAGE_PATH}/imx-mkimage/ clean"
	if [ `echo $2 | cut -d '-' -f2` = "ddr4" ]; then
		make -C ${IMX_MKIMAGE_PATH}/imx-mkimage/ SOC=iMX8MM  flash_ddr4_evk || exit 1
		make -C ${IMX_MKIMAGE_PATH}/imx-mkimage/ SOC=iMX8MM print_fit_hab_ddr4 || exit 1
	elif [ `echo $2 | cut -d '-' -f2` = "4g" ] || [ "`echo $2 | cut -d '-' -f3`" = "4g" ] || [ `echo $2 | rev | cut -d '-' -f1` = "uuu" ]; then
		make -C ${IMX_MKIMAGE_PATH}/imx-mkimage/ SOC=iMX8MM TEE_LOAD_ADDR=0xfe000000 flash_spl_uboot || exit 1
		make -C ${IMX_MKIMAGE_PATH}/imx-mkimage/ SOC=iMX8MM print_fit_hab || exit 1
	elif [ `echo $2 | rev | cut -d '-' -f1 | rev` != "dual" ]; then
		make -C ${IMX_MKIMAGE_PATH}/imx-mkimage/ SOC=iMX8MM flash_spl_uboot || exit 1
		make -C ${IMX_MKIMAGE_PATH}/imx-mkimage/ SOC=iMX8MM print_fit_hab || exit 1
	else
		make -C ${IMX_MKIMAGE_PATH}/imx-mkimage/ SOC=iMX8MM flash_evk_no_hdmi_dual_bootloader || exit 1
		make -C ${IMX_MKIMAGE_PATH}/imx-mkimage/ SOC=iMX8MM PRINT_FIT_HAB_OFFSET=0x0 print_fit_hab || exit 1
	fi

	local _mkcmd="make -C ${IMX_MKIMAGE_PATH}/imx-mkimage/ SOC=iMX8MP"
	if [ `echo $2 | rev | cut -d '-' -f1 | rev` != "dual" ]; then
		cp ${_opt} ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/flash.bin ${UBOOT_COLLECTION}/u-boot-$2.imx
	else
		_do_cmd "${_mkcmd} flash_evk_no_hdmi_dual_bootloader" || _error_exit "make flash_evk_no_hdmi_dual_bootloader fail"
		_do_cmd "${_mkcmd} PRINT_FIT_HAB_OFFSET=0x0 print_fit_hab" || _error_exit "print_fit_hab fail"
		cp ${_opt} ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/flash.bin ${UBOOT_COLLECTION}/spl-$2.bin
		cp ${_opt} ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/u-boot-ivt.itb ${UBOOT_COLLECTION}/bootloader-$2.img
	fi

	unset _mkcmd _opt _addon _soc_type _uboot_dtb
}

