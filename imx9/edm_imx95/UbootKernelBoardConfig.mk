# from BoardConfig.mk
TARGET_BOOTLOADER_POSTFIX := bin
UBOOT_POST_PROCESS := true

# u-boot target
TARGET_BOOTLOADER_BASE_CONFIG := edm-imx95_defconfig
TARGET_BOOTLOADER_CONFIG := imx95:edm-imx95_android_defconfig
TARGET_BOOTLOADER_CONFIG += imx95-evk-uuu:edm-imx95_android_defconfig

#TARGET_KERNEL_DEFCONFIG := gki_defconfig
#ifeq ($(LOADABLE_KERNEL_MODULE),true)
#TARGET_KERNEL_GKI_DEFCONF:= imx95_gki.fragment
#else
#TARGET_KERNEL_GKI_DEFCONF:= imx_v8_android_defconfig
#endif
TARGET_KERNEL_DEFCONFIG := tn_imx_v8_android_defconfig

# absolute path is used, not the same as relative path used in AOSP make
TARGET_DEVICE_DIR := $(patsubst %/, %, $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

# define bootloader rollback index
BOOTLOADER_RBINDEX ?= 0

