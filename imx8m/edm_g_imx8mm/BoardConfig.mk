# -------@block_infrastructure-------
#
# Product-specific compile-time definitions.
#

include $(CONFIG_REPO_PATH)/imx8m/BoardConfigCommon.mk

# -------@block_common_config-------
#
# SoC-specific compile-time definitions.
#

# value assigned in this part should be fixed for an SoC, right?

BOARD_SOC_TYPE := IMX8MM
BOARD_HAVE_VPU := true
BOARD_VPU_TYPE := hantro
FSL_VPU_OMX_ONLY := true
HAVE_FSL_IMX_GPU2D := true
HAVE_FSL_IMX_GPU3D := true
HAVE_FSL_IMX_PXP := false
TARGET_USES_HWC2 := true
TARGET_HAVE_VULKAN := true

SOONG_CONFIG_IMXPLUGIN += \
                          BOARD_VPU_TYPE

SOONG_CONFIG_IMXPLUGIN_BOARD_SOC_TYPE = IMX8MM
SOONG_CONFIG_IMXPLUGIN_BOARD_HAVE_VPU = true
SOONG_CONFIG_IMXPLUGIN_BOARD_VPU_TYPE = hantro
SOONG_CONFIG_IMXPLUGIN_BOARD_VPU_ONLY = false
SOONG_CONFIG_IMXPLUGIN_PREBUILT_FSL_IMX_CODEC = true
SOONG_CONFIG_IMXPLUGIN_POWERSAVE = false

# -------@block_memory-------
USE_ION_ALLOCATOR := true
USE_GPU_ALLOCATOR := false

# -------@block_storage-------
TARGET_USERIMAGES_USE_EXT4 := true

# use sparse image
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := false

# Support gpt
BOARD_BPT_INPUT_FILES += device/nxp/common/partition/device-partitions-13GB-ab_super.bpt
  ADDITION_BPT_PARTITION = partition-table-28GB:device/nxp/common/partition/device-partitions-28GB-ab_super.bpt \
                          partition-table-13GB:device/nxp/common/partition/device-partitions-13GB-ab_super.bpt

BOARD_PREBUILT_DTBOIMAGE := $(OUT_DIR)/target/product/$(PRODUCT_DEVICE)/dtbo-imx8mm.img

BOARD_USES_METADATA_PARTITION := true
BOARD_ROOT_EXTRA_FOLDERS += metadata

# -------@block_security-------
ENABLE_CFI=false

BOARD_AVB_ENABLE := true
BOARD_AVB_ALGORITHM := SHA256_RSA4096
# The testkey_rsa4096.pem is copied from external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_KEY_PATH := $(CONFIG_REPO_PATH)/common/security/testkey_rsa4096.pem

BOARD_AVB_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_BOOT_ALGORITHM := SHA256_RSA2048
BOARD_AVB_BOOT_ROLLBACK_INDEX_LOCATION := 2

# -------@block_treble-------
# Vendor Interface manifest and compatibility
DEVICE_MANIFEST_FILE := $(IMX_DEVICE_PATH)/manifest.xml
DEVICE_MATRIX_FILE := $(IMX_DEVICE_PATH)/compatibility_matrix.xml
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := $(IMX_DEVICE_PATH)/device_framework_matrix.xml


# -------@block_wifi-------
# 8mm LPDDR4 board use NXP 8987 wifi
BOARD_WLAN_DEVICE            := qcwcn
WPA_SUPPLICANT_VERSION       := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER  := NL80211
BOARD_HOSTAPD_DRIVER         := NL80211
BOARD_HOSTAPD_PRIVATE_LIB               := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_PRIVATE_LIB        := lib_driver_cmd_$(BOARD_WLAN_DEVICE)

WIFI_HIDL_FEATURE_DUAL_INTERFACE := true
# -------@block_bluetooth-------
# NXP 8997 BT
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(IMX_DEVICE_PATH)/bluetooth

BOARD_HAVE_BLUETOOTH_QCOM := true
BOARD_HAS_QCA_BT_ROME := true
BOARD_HAVE_BLUETOOTH_BLUEZ := false
QCOM_BT_USE_SIBS := true
ifeq ($(QCOM_BT_USE_SIBS), true)
  WCNSS_FILTER_USES_SIBS := true
endif

# -------@block_sensor-------
BOARD_USE_SENSOR_FUSION := true


# -------@block_kernel_bootimg-------
BOARD_KERNEL_BASE := 0x40400000

CMASIZE=800M

# NXP default config
BOARD_KERNEL_CMDLINE := console=ttymxc1,115200 init=/init firmware_class.path=/vendor/firmware loop.max_part=7 bootconfig
BOARD_BOOTCONFIG += androidboot.console=ttymxc1 androidboot.hardware=nxp androidboot.usb.debugging=1

# memory config
BOARD_KERNEL_CMDLINE += transparent_hugepage=never

# display config
BOARD_BOOTCONFIG += androidboot.lcd_density=240 androidboot.primary_display=imx-drm

# wifi config
BOARD_BOOTCONFIG += androidboot.wificountrycode=TW

BOARD_KERNEL_CMDLINE += cma=$(CMASIZE)@0x400M-0xb80M

ifneq (,$(filter userdebug eng,$(TARGET_BUILD_VARIANT)))
BOARD_BOOTCONFIG += androidboot.vendor.sysrq=1
endif

ifeq ($(EXPORT_BASEBOARD_NAME),WANDBOARD)
  TARGET_BOARD_DTS_CONFIG := imx8mm:imx8mm-edm-g-wb.dtb
  TARGET_BOARD_DTS_CONFIG += imx8mm-rpmsg:imx8mm-edm-g-wb-rpmsg.dtb
  TARGET_BOARD_DTBO_CONFIG := imx8mm:imx8mm-edm-g-wb-sn65dsi84-vl10112880.dtbo
  TARGET_BOARD_DTBO_CONFIG += imx8mm:imx8mm-edm-g-wb-sn65dsi84-vl215192108.dtbo
  TARGET_BOARD_DTBO_CONFIG += imx8mm:imx8mm-edm-g-wb-tevi-ov5640.dtbo
  TARGET_BOARD_DTBO_CONFIG += imx8mm:imx8mm-edm-g-wb-tevi-ap1302.dtbo
else ifeq ($(EXPORT_BASEBOARD_NAME),WIZARD)
  TARGET_BOARD_DTS_CONFIG := imx8mm:imx8mm-edm-g-wizard.dtb
  TARGET_BOARD_DTS_CONFIG += imx8mm-rpmsg:imx8mm-edm-g-wizard-rpmsg.dtb
  TARGET_BOARD_DTBO_CONFIG := imx8mm:imx8mm-edm-g-wizard-sn65dsi84-vl10112880.dtbo
  TARGET_BOARD_DTBO_CONFIG += imx8mm:imx8mm-edm-g-wizard-sn65dsi84-vl215192108.dtbo
  TARGET_BOARD_DTBO_CONFIG += imx8mm:imx8mm-edm-g-wizard-tevi-ov5640.dtbo
  TARGET_BOARD_DTBO_CONFIG += imx8mm:imx8mm-edm-g-wizard-tevi-ap1302.dtbo
endif

ALL_DEFAULT_INSTALLED_MODULES += $(BOARD_VENDOR_KERNEL_MODULES)

# -------@block_sepolicy-------
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += \
    $(CONFIG_REPO_PATH)/imx8m/system_ext_pri_sepolicy

BOARD_SEPOLICY_DIRS := \
       $(CONFIG_REPO_PATH)/imx8m/sepolicy \
       $(IMX_DEVICE_PATH)/sepolicy

# PRODUCT_COPY_FILES directives.
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
