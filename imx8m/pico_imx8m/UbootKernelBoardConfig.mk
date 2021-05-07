TARGET_BOOTLOADER_POSTFIX := bin
UBOOT_POST_PROCESS := true

# u-boot target for imx8mq_evk
TARGET_BOOTLOADER_CONFIG := imx8mq:pico-imx8mq_android_defconfig

TARGET_KERNEL_DEFCONFIG := tn_android_defconfig
# TARGET_KERNEL_ADDITION_DEFCONF ?= android_addition_defconfig


# absolute path is used, not the same as relative path used in AOSP make
TARGET_DEVICE_DIR := $(patsubst %/, %, $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

# define bootloader rollback index
BOOTLOADER_RBINDEX ?= 0

