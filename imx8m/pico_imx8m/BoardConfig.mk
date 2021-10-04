#
# SoC-specific compile-time definitions.
#

BOARD_SOC_TYPE := IMX8MQ
BOARD_TYPE := SOM
BOARD_HAVE_VPU := true
BOARD_VPU_TYPE := hantro
HAVE_FSL_IMX_GPU2D := false
HAVE_FSL_IMX_GPU3D := true
HAVE_FSL_IMX_IPU := false
HAVE_FSL_IMX_PXP := false
BOARD_KERNEL_BASE := 0x40400000
TARGET_GRALLOC_VERSION := v3
TARGET_USES_HWC2 := true
TARGET_HWCOMPOSER_VERSION := v2.0
USE_OPENGL_RENDERER := true
TARGET_HAVE_VULKAN := true
ENABLE_CFI=false

SOONG_CONFIG_IMXPLUGIN += \
                          BOARD_HAVE_VPU \
                          BOARD_VPU_TYPE

SOONG_CONFIG_IMXPLUGIN_BOARD_SOC_TYPE = IMX8MQ
SOONG_CONFIG_IMXPLUGIN_BOARD_HAVE_VPU = true
SOONG_CONFIG_IMXPLUGIN_BOARD_VPU_TYPE = hantro
SOONG_CONFIG_IMXPLUGIN_BOARD_VPU_ONLY = false

#
# Product-specific compile-time definitions.
#

IMX_DEVICE_PATH := device/nxp/imx8m/pico_imx8m

include device/nxp/imx8m/BoardConfigCommon.mk

BUILD_TARGET_FS ?= ext4
TARGET_USERIMAGES_USE_EXT4 := true

TARGET_RECOVERY_FSTAB = $(IMX_DEVICE_PATH)/fstab.nxp

# Support gpt
BOARD_BPT_INPUT_FILES += device/nxp/common/partition/device-partitions-13GB-ab_super.bpt
ADDITION_BPT_PARTITION = partition-table-28GB:device/nxp/common/partition/device-partitions-28GB-ab_super.bpt \
                         partition-table-13GB:device/nxp/common/partition/device-partitions-13GB-ab_super.bpt \
                         partition-table-9GB:device/nxp/common/partition/device-partitions-9GB-ab_super.bpt

# Vendor Interface manifest and compatibility
DEVICE_MANIFEST_FILE := $(IMX_DEVICE_PATH)/manifest.xml
DEVICE_MATRIX_FILE := $(IMX_DEVICE_PATH)/compatibility_matrix.xml
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := $(IMX_DEVICE_PATH)/device_framework_matrix.xml

TARGET_BOOTLOADER_BOARD_NAME := EVK

USE_OPENGL_RENDERER := true

# QCA qcacld wifi driver module
BOARD_VENDOR_KERNEL_MODULES += \
    $(KERNEL_OUT)/drivers/net/wireless/qcacld-2.0/wlan.ko

BOARD_WLAN_DEVICE            := qcwcn
WPA_SUPPLICANT_VERSION       := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER  := NL80211
BOARD_HOSTAPD_DRIVER         := NL80211
BOARD_HOSTAPD_PRIVATE_LIB           := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_PRIVATE_LIB    := lib_driver_cmd_$(BOARD_WLAN_DEVICE)

WIFI_HIDL_FEATURE_DUAL_INTERFACE := true

# QCA9377 BT
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(IMX_DEVICE_PATH)/bluetooth
BOARD_HAVE_BLUETOOTH_QCOM := true
BOARD_HAS_QCA_BT_ROME := true
BOARD_HAVE_BLUETOOTH_BLUEZ := false
QCOM_BT_USE_SIBS := true
ifeq ($(QCOM_BT_USE_SIBS), true)
  WCNSS_FILTER_USES_SIBS := true
endif

BOARD_USE_SENSOR_FUSION := false

# we don't support sparse image.
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := false

BOARD_HAVE_USB_CAMERA := true
BOARD_HAVE_USB_MJPEG_CAMERA := false

USE_ION_ALLOCATOR := true
USE_GPU_ALLOCATOR := false

BOARD_AVB_ENABLE := true
TARGET_USES_MKE2FS := true
BOARD_AVB_ALGORITHM := SHA256_RSA4096
# The testkey_rsa4096.pem is copied from external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_KEY_PATH := device/nxp/common/security/testkey_rsa4096.pem

BOARD_AVB_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_BOOT_ALGORITHM := SHA256_RSA2048
BOARD_AVB_BOOT_ROLLBACK_INDEX_LOCATION := 2

ifeq ($(TARGET_USERIMAGES_USE_UBIFS),true)
ifeq ($(TARGET_USERIMAGES_USE_EXT4),true)
$(error "TARGET_USERIMAGES_USE_UBIFS and TARGET_USERIMAGES_USE_EXT4 config open in same time, please only choose one target file system image")
endif
endif

BOARD_PREBUILT_DTBOIMAGE := out/target/product/pico_imx8m/dtbo-imx8mq.img

ifeq ($(EXPORT_BASEBOARD_NAME),PI)
  TARGET_BOARD_DTS_CONFIG := imx8mq:imx8mq-pico-pi.dtb

  TARGET_BOARD_DTBO_CONFIG := imx8mq:imx8mq-pico-pi-ili9881c.dtbo
  TARGET_BOARD_DTBO_CONFIG += imx8mq:imx8mq-pico-pi-tevi-ov5640.dtbo
  TARGET_BOARD_DTBO_CONFIG += imx8mq:imx8mq-pico-pi-ov5645.dtbo
  TARGET_BOARD_DTBO_CONFIG += imx8mq:imx8mq-pico-pi-voicehat.dtbo
  TARGET_BOARD_DTBO_CONFIG += imx8mq:imx8mq-pico-pi-clixnfc.dtbo
else ifeq ($(EXPORT_BASEBOARD_NAME),WIZARD)
  TARGET_BOARD_DTS_CONFIG := imx8mq:imx8mq-pico-wizard.dtb

  TARGET_BOARD_DTBO_CONFIG := imx8mq:imx8mq-pico-wizard-ili9881c.dtbo
  TARGET_BOARD_DTBO_CONFIG += imx8mq:imx8mq-pico-wizard-tevi-ov5640.dtbo
  TARGET_BOARD_DTBO_CONFIG += imx8mq:imx8mq-pico-wizard-ov5645.dtbo
  TARGET_BOARD_DTBO_CONFIG += imx8mq:imx8mq-pico-wizard-voicehat.dtbo
  TARGET_BOARD_DTBO_CONFIG += imx8mq:imx8mq-pico-wizard-clix1nfc.dtbo
  TARGET_BOARD_DTBO_CONFIG += imx8mq:imx8mq-pico-wizard-clix2nfc.dtbo
  TARGET_BOARD_DTBO_CONFIG += imx8mq:imx8mq-pico-wizard-g101uan02.dtbo
  TARGET_BOARD_DTBO_CONFIG += imx8mq:imx8mq-pico-wizard-mipi2hdmi-adv7535.dtbo
  TARGET_BOARD_DTBO_CONFIG += imx8mq:imx8mq-pico-wizard-sn65dsi84-vl10112880.dtbo
  TARGET_BOARD_DTBO_CONFIG += imx8mq:imx8mq-pico-wizard-sn65dsi84-vl15613676.dtbo
  TARGET_BOARD_DTBO_CONFIG += imx8mq:imx8mq-pico-wizard-sn65dsi84-vl215192108.dtbo
endif

BOARD_SEPOLICY_DIRS := \
       device/nxp/imx8m/sepolicy \
       $(IMX_DEVICE_PATH)/sepolicy

TARGET_BOARD_KERNEL_HEADERS := device/nxp/common/kernel-headers

ALL_DEFAULT_INSTALLED_MODULES += $(BOARD_VENDOR_KERNEL_MODULES)

BOARD_USES_METADATA_PARTITION := true
BOARD_ROOT_EXTRA_FOLDERS += metadata
