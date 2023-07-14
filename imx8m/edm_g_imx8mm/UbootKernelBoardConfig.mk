# from BoardConfig.mk
TARGET_BOOTLOADER_POSTFIX := bin
UBOOT_POST_PROCESS := true

# u-boot target
TARGET_BOOTLOADER_CONFIG := imx8mm:edm-g-imx8mm_android_defconfig
TARGET_BOOTLOADER_CONFIG += imx8mm-evk-uuu:edm-g-imx8mm_android_defconfig

# imx8mm kernel defconfig
ifeq ($(IMX8MM_USES_GKI),true)
TARGET_KERNEL_DEFCONFIG := gki_defconfig
TARGET_KERNEL_GKI_DEFCONF:= tn_imx8mm_gki.fragment
else
TARGET_KERNEL_DEFCONFIG := tn_imx8_android_defconfig
endif

TARGET_KERNEL_ADDITION_DEFCONF := android_addition_defconfig

# absolute path is used, not the same as relative path used in AOSP make
TARGET_DEVICE_DIR := $(patsubst %/, %, $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

# define bootloader rollback index
BOOTLOADER_RBINDEX ?= 0

