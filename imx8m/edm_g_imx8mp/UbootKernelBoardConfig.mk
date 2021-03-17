# from BoardConfig.mk
TARGET_BOOTLOADER_POSTFIX := bin
UBOOT_POST_PROCESS := true

# u-boot target
TARGET_BOOTLOADER_CONFIG := imx8mp:edm-g-imx8mp_android_defconfig

#ifneq ($(IMX8MP_USES_GKI),)
#TARGET_KERNEL_DEFCONFIG := gki_defconfig
#TARGET_KERNEL_GKI_DEFCONF:= android_gki_defconfig
#else
TARGET_KERNEL_DEFCONFIG := imx_v8_android_defconfig
#endif

TARGET_KERNEL_ADDITION_DEFCONF := android_addition_defconfig


# absolute path is used, not the same as relative path used in AOSP make
TARGET_DEVICE_DIR := $(patsubst %/, %, $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

# define bootloader rollback index
BOOTLOADER_RBINDEX ?= 0

