#
# Product-specific compile-time definitions.
#

IMX_DEVICE_PATH := device/fsl/imx7d/tep1_imx7

include $(IMX_DEVICE_PATH)/build_id.mk
include device/fsl/imx7d/BoardConfigCommon.mk
ifeq ($(PREBUILT_FSL_IMX_CODEC),true)
-include $(FSL_CODEC_PATH)/fsl-codec/fsl-codec.mk
endif

TARGET_USES_64_BIT_BINDER := true

BUILD_TARGET_FS ?= ext4
TARGET_USERIMAGES_USE_EXT4 := true

TARGET_RECOVERY_FSTAB = $(IMX_DEVICE_PATH)/fstab.freescale

# Vendor Interface manifest and compatibility
DEVICE_MANIFEST_FILE := $(IMX_DEVICE_PATH)/manifest.xml
DEVICE_MATRIX_FILE := $(IMX_DEVICE_PATH)/compatibility_matrix.xml

TARGET_BOOTLOADER_BOARD_NAME := TEP1-IMX7
PRODUCT_MODEL := TEP1-IMX7

TARGET_BOOTLOADER_POSTFIX := imx
TARGET_DTB_POSTFIX := -dtb

# UNITE is a virtual device.
# BOARD_WLAN_DEVICE            := qcwcn
# WPA_SUPPLICANT_VERSION       := VER_0_8_X

# BOARD_WPA_SUPPLICANT_DRIVER  := NL80211
# BOARD_HOSTAPD_DRIVER         := NL80211

# BOARD_HOSTAPD_PRIVATE_LIB               := lib_driver_cmd_qcwcn
# BOARD_WPA_SUPPLICANT_PRIVATE_LIB        := lib_driver_cmd_qcwcn

# WIFI_DRIVER_FW_PATH_PARAM      := "/sys/module/brcmfmac/parameters/alternative_fw_path"

# BOARD_VENDOR_KERNEL_MODULES += \
#                            $(KERNEL_OUT)/drivers/net/wireless/qcacld-2.0/wlan.ko

#for accelerator sensor, need to define sensor type here
BOARD_USE_SENSOR_FUSION := true
#SENSOR_MMA8451 := true
BOARD_USE_SENSOR_PEDOMETER := false
BOARD_USE_LEGACY_SENSOR := true

# for recovery service
TARGET_SELECT_KEY := 28
# we don't support sparse image.
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := false

# Qcom 1CQ(QCA6174) BT
# BOARD_HAVE_BLUETOOTH_QCOM := true
# BOARD_HAS_QCA_BT_ROME := true
# BOARD_SUPPORTS_BLE_VND := true
# BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(IMX_DEVICE_PATH)/bluetooth

USE_ION_ALLOCATOR := true
USE_GPU_ALLOCATOR := false

# define frame buffer count
NUM_FRAMEBUFFER_SURFACE_BUFFERS := 3

# camera hal v1
IMX_CAMERA_HAL_V1 := true
TARGET_VSYNC_DIRECT_REFRESH := true

KERNEL_NAME := zImage
BOARD_KERNEL_CMDLINE := console=ttymxc2,115200 init=/init video=mxcfb0:dev=lcd,800x480@60,if=RGB24,bpp=24 video=mxcfb1:off androidboot.console=ttymxc2 consoleblank=0 androidboot.hardware=freescale cma=320M loop.max_part=7
# u-boot target for imx7d_sabresd with HDMI or LCD display
TARGET_BOOTLOADER_CONFIG := tep1-imx7d_android_spl_defconfig
# TARGET_BOARD_DTS_CONFIG := imx7d:imx7d-tep1.dtb
TARGET_BOARD_DTS_CONFIG := imx7d:imx7d-tep1-a2.dtb
TARGET_KERNEL_DEFCONFIG := tn_android_defconfig
TARGET_KERNEL_ADDITION_DEFCONF ?= android_addition_defconfig

BOARD_PREBUILT_DTBOIMAGE := out/target/product/tep1_imx7/dtbo-imx7d.img


BOARD_SEPOLICY_DIRS := \
       device/fsl/imx7d/sepolicy \
       $(IMX_DEVICE_PATH)/sepolicy

# Support gpt
BOARD_BPT_INPUT_FILES += device/fsl/common/partition/device-partitions-7GB.bpt
ADDITION_BPT_PARTITION = partition-table-14GB:device/fsl/common/partition/device-partitions-14GB.bpt \
                         partition-table-28GB:device/fsl/common/partition/device-partitions-28GB.bpt \
                         partition-table-3GB:device/fsl/common/partition/device-partitions-3GB.bpt \
                         partition-table-7GB:device/fsl/common/partition/device-partitions-7GB.bpt

TARGET_BOARD_KERNEL_HEADERS := device/fsl/common/kernel-headers

#Enable AVB
BOARD_AVB_ENABLE := true
TARGET_USES_MKE2FS := true
BOARD_INCLUDE_RECOVERY_DTBO := true
BOARD_USES_FULL_RECOVERY_IMAGE := true
