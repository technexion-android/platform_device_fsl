# -------@block_kernel_bootimg-------

KERNEL_NAME := Image.lz4
TARGET_KERNEL_ARCH := arm64

IMX8MM_USES_GKI := false

BOARD_VENDOR_KERNEL_MODULES +=     \
    $(KERNEL_OUT)/drivers/net/wireless/qcacld-2.0/wlan.ko

# -------@block_memory-------
#Enable this to config 1GB ddr on evk_imx8mm
LOW_MEMORY := false

# -------@block_security-------
#Enable this to include trusty support
PRODUCT_IMX_TRUSTY := false
