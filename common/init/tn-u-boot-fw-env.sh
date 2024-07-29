#! /vendor/bin/sh

MMC_TAR=$(cat /proc/cmdline | grep -io "mmcblk[[:digit:]]")
QSPI_BOOT=$(cat /proc/cmdline  |grep -oi "qspi_boot=yes")
ARCH=$(uname -m)

if [ -z "$MMC_TAR" ]; then
	echo "Can not find MMC device path from kernel argument!"
	#exit 1
fi

if [[ -n ${QSPI_BOOT} ]];then
	BOOT_DEV='/dev/mtd0'
else
	BOOT_DEV='/dev/block/'${MMC_TAR} 
fi

if [ ${ARCH} == 'aarch64' ];then
	echo -e "${BOOT_DEV}\t0x400000\t0x4000" > /data/vendor/fw_env/fw_env.config
else
	echo -e "${BOOT_DEV}\t0xc0000\t0x2000" > /data/vendor/fw_env/fw_env.config
fi
