TARGET_BOOTLOADER_POSTFIX := bin
UBOOT_POST_PROCESS := true

# u-boot target for imx943_evk board
TARGET_BOOTLOADER_CONFIG := imx943:imx943_evk_android_defconfig
TARGET_BOOTLOADER_CONFIG += imx943-lpddr5:imx943_evk_android_defconfig
TARGET_BOOTLOADER_CONFIG += imx943-dual:imx943_evk_android_dual_defconfig
TARGET_BOOTLOADER_CONFIG += imx943-lpddr5-dual:imx943_evk_android_dual_defconfig
TARGET_BOOTLOADER_CONFIG += imx943-trusty-dual:imx943_evk_android_trusty_dual_defconfig
TARGET_BOOTLOADER_CONFIG += imx943-trusty-lpddr5-dual:imx943_evk_android_trusty_dual_defconfig
TARGET_BOOTLOADER_CONFIG += imx943-evk-uuu:imx943_evk_android_uuu_defconfig
TARGET_BOOTLOADER_CONFIG += imx943-lpddr5-evk-uuu:imx943_evk_android_uuu_defconfig

# imx943 kernel defconfig
TARGET_KERNEL_DEFCONFIG := gki_defconfig
ifeq ($(LOADABLE_KERNEL_MODULE),true)
TARGET_KERNEL_GKI_DEFCONF:= imx943_gki.fragment
else
TARGET_KERNEL_GKI_DEFCONF := imx_v8_android_defconfig
endif

# absolute path is used, not the same as relative path used in AOSP make
TARGET_DEVICE_DIR := $(patsubst %/, %, $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

# define bootloader rollback index
BOOTLOADER_RBINDEX ?= 0

