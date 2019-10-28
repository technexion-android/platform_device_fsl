#
# Product-specific compile-time definitions.
#

IMX_DEVICE_PATH := device/fsl/imx6dq/edm1_imx6

include $(IMX_DEVICE_PATH)/build_id.mk
include device/fsl/imx6dq/BoardConfigCommon.mk
ifeq ($(PREBUILT_FSL_IMX_CODEC),true)
-include $(FSL_CODEC_PATH)/fsl-codec/fsl-codec.mk
endif

TARGET_USES_64_BIT_BINDER := true

BUILD_TARGET_FS ?= ext4
TARGET_USERIMAGES_USE_EXT4 := true

TARGET_RECOVERY_FSTAB = $(IMX_DEVICE_PATH)/fstab.freescale

# Support gpt
BOARD_BPT_INPUT_FILES += device/fsl/common/partition/device-partitions-7GB.bpt
ADDITION_BPT_PARTITION = partition-table-14GB:device/fsl/common/partition/device-partitions-14GB.bpt \
                         partition-table-28GB:device/fsl/common/partition/device-partitions-28GB.bpt \
                         partition-table-3GB:device/fsl/common/partition/device-partitions-3GB.bpt \
                         partition-table-7GB:device/fsl/common/partition/device-partitions-7GB.bpt

# Vendor Interface manifest and compatibility
DEVICE_MANIFEST_FILE := $(IMX_DEVICE_PATH)/manifest.xml
DEVICE_MATRIX_FILE := $(IMX_DEVICE_PATH)/compatibility_matrix.xml

TARGET_BOOTLOADER_BOARD_NAME := EDM1-IMX6

PRODUCT_MODEL := EDM1-IMX6

TARGET_BOOTLOADER_POSTFIX := imx
TARGET_DTB_POSTFIX := -dtb

USE_OPENGL_RENDERER := true
TARGET_CPU_SMP := true

BOARD_WLAN_DEVICE            := qcwcn
WPA_SUPPLICANT_VERSION       := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER  := NL80211
BOARD_HOSTAPD_DRIVER         := NL80211

BOARD_HOSTAPD_PRIVATE_LIB               := lib_driver_cmd_qcwcn
BOARD_WPA_SUPPLICANT_PRIVATE_LIB        := lib_driver_cmd_qcwcn

# QCA qcacld wifi driver module
BOARD_VENDOR_KERNEL_MODULES += \
  $(KERNEL_OUT)/drivers/net/wireless/qcacld-2.0/wlan.ko


#for accelerator sensor, need to define sensor type here
BOARD_HAS_SENSOR := true
SENSOR_MMA8451 := false
BOARD_USE_SENSOR_PEDOMETER := false
BOARD_USE_LEGACY_SENSOR := true

# for recovery service
TARGET_SELECT_KEY := 28
# we don't support sparse image.
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := false

# camera hal v3
IMX_CAMERA_HAL_V3 := true

BOARD_HAVE_USB_CAMERA := true

# Qcom 1CQ(QCA6174) BT
BOARD_HAVE_BLUETOOTH_QCOM := true
BOARD_HAS_QCA_BT_ROME := true
BOARD_SUPPORTS_BLE_VND := true
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(IMX_DEVICE_PATH)/bluetooth

USE_ION_ALLOCATOR := true
USE_GPU_ALLOCATOR := false

# define frame buffer count
NUM_FRAMEBUFFER_SURFACE_BUFFERS := 3

KERNEL_NAME := zImage

ifeq ($(DISPLAY_TARGET),DISP_LCD_5INCH)
  BOARD_KERNEL_CMDLINE := console=ttymxc0,115200 init=/init video=mxcfb0:dev=lcd,800x480@60,if=RGB24,bpp=24 video=mxcfb1:off video=mxcfb2:off video=mxcfb3:off vmalloc=128M androidboot.console=ttymxc0 consoleblank=0 androidboot.hardware=freescale cma=320M galcore.contiguousSize=67108864 loop.max_part=7
else ifeq ($(DISPLAY_TARGET),DISP_HDMI)
  BOARD_KERNEL_CMDLINE := console=ttymxc0,115200 init=/init video=mxcfb0:dev=hdmi,1280x720M@60,if=RGB24 video=mxcfb1:off vmalloc=128M androidboot.console=ttymxc0 consoleblank=0 androidboot.hardware=freescale cma=320M galcore.contiguousSize=67108864 loop.max_part=7
else ifeq ($(DISPLAY_TARGET),DISP_LVDS_7INCH)
  BOARD_KERNEL_CMDLINE := console=ttymxc0,115200 init=/init video=mxcfb0:dev=ldb,1024x600@60,if=RGB24,bpp=24 video=mxcfb1:off vmalloc=128M androidboot.console=ttymxc0 consoleblank=0 androidboot.hardware=freescale cma=320M galcore.contiguousSize=67108864 loop.max_part=7
else ifeq ($(DISPLAY_TARGET),DISP_LVDS_10INCH)
  BOARD_KERNEL_CMDLINE := console=ttymxc0,115200 init=/init video=mxcfb0:dev=ldb,1280x800@60,if=RGB24,bpp=24 video=mxcfb1:off vmalloc=128M androidboot.console=ttymxc0 consoleblank=0 androidboot.hardware=freescale cma=320M galcore.contiguousSize=67108864 loop.max_part=7
endif

ifeq ($(GLOBAL_CPU_TYPE),IMX6Q)
  BOARD_PREBUILT_DTBOIMAGE := out/target/product/edm1_imx6/dtbo-imx6q.img
else ifeq ($(GLOBAL_CPU_TYPE),IMX6DL)
  BOARD_PREBUILT_DTBOIMAGE := out/target/product/edm1_imx6/dtbo-imx6dl.img
endif

ifeq ($(EXPORT_BASEBOARD_NAME),FAIRY)
  TARGET_BOARD_DTS_CONFIG := imx6q:imx6q-edm1-fairy-qca.dtb
  TARGET_BOARD_DTS_CONFIG += imx6dl:imx6dl-edm1-fairy-qca.dtb
  TARGET_BOARD_DTS_CONFIG += imx6qp:imx6qp-edm1-fairy-qca.dtb
else ifeq ($(EXPORT_BASEBOARD_NAME),TC0700)
  TARGET_BOARD_DTS_CONFIG := imx6q:imx6q-edm1-tc0700-qca.dtb
  TARGET_BOARD_DTS_CONFIG += imx6dl:imx6dl-edm1-tc0700-qca.dtb
  TARGET_BOARD_DTS_CONFIG += imx6qp:imx6qp-edm1-tc0700-qca.dtb
else ifeq ($(EXPORT_BASEBOARD_NAME),TC1000)
  TARGET_BOARD_DTS_CONFIG := imx6q:imx6q-edm1-tc1000-qca.dtb
  TARGET_BOARD_DTS_CONFIG += imx6dl:imx6dl-edm1-tc1000-qca.dtb
  TARGET_BOARD_DTS_CONFIG += imx6qp:imx6qp-edm1-tc1000-qca.dtb
endif

TARGET_BOOTLOADER_CONFIG := edm-imx6_android_spl_defconfig
TARGET_KERNEL_DEFCONFIG := tn_android_defconfig
TARGET_KERNEL_ADDITION_DEFCONF ?= android_addition_defconfig

BOARD_SEPOLICY_DIRS := \
       device/fsl/imx6dq/sepolicy \
       $(IMX_DEVICE_PATH)/sepolicy

TARGET_BOARD_KERNEL_HEADERS := device/fsl/common/kernel-headers

#Enable AVB
BOARD_AVB_ENABLE := true
TARGET_USES_MKE2FS := true
BOARD_INCLUDE_RECOVERY_DTBO := true
BOARD_USES_FULL_RECOVERY_IMAGE := true
