# -------@block_kernel_bootimg-------

KERNEL_NAME := Image.lz4
TARGET_KERNEL_ARCH := arm64

LOADABLE_KERNEL_MODULE ?= false

#neutron driver module
BOARD_VENDOR_KERNEL_MODULES += \
    $(KERNEL_OUT)/drivers/remoteproc/imx_neutron_rproc.ko \
    $(KERNEL_OUT)/drivers/staging/neutron/neutron.ko

# -------@block_memory-------
#Enable this to config low memory
LOW_MEMORY := false

# -------@block_security-------
#Enable this to include trusty support
PRODUCT_IMX_TRUSTY := true

# -------@block_storage-------
# the bootloader image used in dual-bootloader OTA
# TODO use the correct name for OTA
BOARD_OTA_BOOTLOADERIMAGE := bootloader-imx943-trusty-dual.img

#Enable this to use dynamic partitions for the readonly partitions not touched by bootloader
TARGET_USE_DYNAMIC_PARTITIONS ?= true

#Enable this to disable product partition build.
IMX_NO_PRODUCT_PARTITION := false

# -------@block_infrastructure-------
CONFIG_REPO_PATH := device/nxp

ifeq ($(SUPPORT_GBL),true)
# Enable this to include the dtb images into vendor_boot image.
TARGET_INCLUDE_DTB_TO_VENDOR_BOOT ?= true
endif
