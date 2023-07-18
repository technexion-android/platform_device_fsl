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

BOARD_SOC_TYPE := ${SOC_MODEL}
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

SOONG_CONFIG_IMXPLUGIN_BOARD_SOC_TYPE = ${BOARD_SOC_TYPE}
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
ifeq ($(TARGET_USE_DYNAMIC_PARTITIONS),true)
  BOARD_BPT_INPUT_FILES += $(CONFIG_REPO_PATH)/common/partition/device-partitions-13GB-ab_super.bpt
  ADDITION_BPT_PARTITION = partition-table-28GB:$(CONFIG_REPO_PATH)/common/partition/device-partitions-28GB-ab_super.bpt \
                           partition-table-dual:$(CONFIG_REPO_PATH)/common/partition/device-partitions-13GB-ab-dual-bootloader_super.bpt \
                           partition-table-28GB-dual:$(CONFIG_REPO_PATH)/common/partition/device-partitions-28GB-ab-dual-bootloader_super.bpt
else
  ifeq ($(IMX_NO_PRODUCT_PARTITION),true)
    BOARD_BPT_INPUT_FILES += $(CONFIG_REPO_PATH)/common/partition/device-partitions-13GB-ab-no-product.bpt
    ADDITION_BPT_PARTITION = partition-table-28GB:$(CONFIG_REPO_PATH)/common/partition/device-partitions-28GB-ab-no-product.bpt \
                             partition-table-dual:$(CONFIG_REPO_PATH)/common/partition/device-partitions-13GB-ab-dual-bootloader-no-product.bpt \
                             partition-table-28GB-dual:$(CONFIG_REPO_PATH)/common/partition/device-partitions-28GB-ab-dual-bootloader-no-product.bpt
  else
    BOARD_BPT_INPUT_FILES += $(CONFIG_REPO_PATH)/common/partition/device-partitions-13GB-ab.bpt
    ADDITION_BPT_PARTITION = partition-table-28GB:$(CONFIG_REPO_PATH)/common/partition/device-partitions-28GB-ab.bpt \
                             partition-table-dual:$(CONFIG_REPO_PATH)/common/partition/device-partitions-13GB-ab-dual-bootloader.bpt \
                             partition-table-28GB-dual:$(CONFIG_REPO_PATH)/common/partition/device-partitions-28GB-ab-dual-bootloader.bpt
  endif
endif

BOARD_PREBUILT_DTBOIMAGE := $(OUT_DIR)/target/product/$(PRODUCT_DEVICE)/dtbo-${SOC_MODEL_LT}.img

BOARD_USES_METADATA_PARTITION := true
BOARD_ROOT_EXTRA_FOLDERS += metadata

AB_OTA_PARTITIONS += bootloader

# -------@block_security-------
ENABLE_CFI=false

BOARD_AVB_ENABLE := true
BOARD_AVB_ALGORITHM := SHA256_RSA4096
# The testkey_rsa4096.pem is copied from external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_KEY_PATH := $(CONFIG_REPO_PATH)/common/security/testkey_rsa4096.pem

BOARD_AVB_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_BOOT_ALGORITHM := SHA256_RSA4096
BOARD_AVB_BOOT_ROLLBACK_INDEX_LOCATION := 2

# Enable chained vbmeta for init_boot images
BOARD_AVB_INIT_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_INIT_BOOT_ALGORITHM := SHA256_RSA4096
BOARD_AVB_INIT_BOOT_ROLLBACK_INDEX_LOCATION := 3

# Use sha256 hashtree
BOARD_AVB_SYSTEM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_SYSTEM_EXT_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_PRODUCT_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_VENDOR_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_VENDOR_DLKM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256

# -------@block_treble-------
# Vendor Interface manifest and compatibility
DEVICE_MANIFEST_FILE := $(IMX_DEVICE_PATH)/manifest.xml
DEVICE_MATRIX_FILE := $(IMX_DEVICE_PATH)/compatibility_matrix.xml
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := $(IMX_DEVICE_PATH)/device_framework_matrix.xml


# -------@block_wifi-------
ifeq ($(WIFI_BT_DEV),QCA9377)
# qca9377 wifi
BOARD_WLAN_DEVICE := qcwcn
# QCA qcacld wifi driver module
BOARD_VENDOR_KERNEL_MODULES += $(KERNEL_OUT)/drivers/net/wireless/qcacld-2.0/wlan.ko
# Avoid Wifi reset on MAC Address change
#WIFI_AVOID_IFACE_RESET_MAC_CHANGE := true
else
# NXP 8987 wifi driver module
BOARD_WLAN_DEVICE := nxp
BOARD_VENDOR_KERNEL_MODULES += \
    $(TARGET_OUT_INTERMEDIATES)/MXMWIFI_OBJ/mlan.ko \
    $(TARGET_OUT_INTERMEDIATES)/MXMWIFI_OBJ/moal.ko
endif

WPA_SUPPLICANT_VERSION := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_HOSTAPD_DRIVER := NL80211
BOARD_HOSTAPD_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)

WIFI_HIDL_FEATURE_DUAL_INTERFACE := true


# -------@block_bluetooth-------
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(IMX_DEVICE_PATH)/bluetooth

ifeq ($(WIFI_BT_DEV),QCA9377)

# QCA9377 BT
BOARD_HAVE_BLUETOOTH_QCOM := true
BOARD_HAS_QCA_BT_ROME := true
BOARD_HAVE_BLUETOOTH_BLUEZ := false
QCOM_BT_USE_SIBS := true
WIFI_BT_STATUS_SYNC := false

else

# NXP 8997 BT
BOARD_HAVE_BLUETOOTH_NXP := true

endif

# -------@block_sensor-------
BOARD_USE_SENSOR_FUSION := false


# -------@block_kernel_bootimg-------
BOARD_KERNEL_BASE := 0x40400000

CMASIZE=800M

# NXP default config
BOARD_KERNEL_CMDLINE := init=/init firmware_class.path=/vendor/firmware loop.max_part=7 bootconfig
BOARD_BOOTCONFIG += androidboot.console=ttymxc1 androidboot.hardware=nxp

# memory config
BOARD_KERNEL_CMDLINE += transparent_hugepage=never

# display config
BOARD_BOOTCONFIG += androidboot.lcd_density=240 androidboot.primary_display=imx-drm

# wifi config
BOARD_BOOTCONFIG += androidboot.wificountrycode=TW

# low memory device build config
ifeq ($(LOW_MEMORY),true)
BOARD_KERNEL_CMDLINE += cma=320M@0x400M-0xb80M galcore.contiguousSize=33554432
BOARD_BOOTCONFIG += androidboot.displaymode=720p
else
BOARD_KERNEL_CMDLINE += cma=$(CMASIZE)@0x400M-0xb80M
endif

# Disable fw_devlink.strict
#BOARD_KERNEL_CMDLINE += fw_devlink.strict=0

ifneq (,$(filter userdebug eng,$(TARGET_BUILD_VARIANT)))
BOARD_BOOTCONFIG += androidboot.vendor.sysrq=1
endif

#
# Configurations of device tree and it's overlay
#
ifeq ($(EXPORT_BASEBOARD_NAME),WANDBOARD)
	BASEBOARD_TAG := wb
else ifeq ($(EXPORT_BASEBOARD_NAME),WIZARD)
	BASEBOARD_TAG := wizard
endif
TARGET_BOARD_DTS_CONFIG := imx8mm:imx8mm-edm-g-$(BASEBOARD_TAG)_android.dtb

WITH_EXT_DTBO ?= true
ifeq ($(WITH_EXT_DTBO),true)
	TARGET_BOARD_DTBO_CONFIG := imx8mm:imx8mm-edm-g-$(BASEBOARD_TAG)-sn65dsi84-vl10112880.dtbo
	TARGET_BOARD_DTBO_CONFIG += imx8mm:imx8mm-edm-g-$(BASEBOARD_TAG)-sn65dsi84-vl15613676.dtbo
	TARGET_BOARD_DTBO_CONFIG += imx8mm:imx8mm-edm-g-$(BASEBOARD_TAG)-sn65dsi84-vl215192108.dtbo
	TARGET_BOARD_DTBO_CONFIG += imx8mm:imx8mm-edm-g-$(BASEBOARD_TAG)-tevi-ov5640.dtbo
	TARGET_BOARD_DTBO_CONFIG += imx8mm:imx8mm-edm-g-$(BASEBOARD_TAG)-tevi-ap1302.dtbo
	TARGET_BOARD_DTBO_CONFIG += imx8mm:imx8mm-edm-g-$(BASEBOARD_TAG)-hdmi2mipi-tc358743.dtbo
	TARGET_BOARD_DTBO_CONFIG += imx8mm:imx8mm-edm-g-$(BASEBOARD_TAG)-vizionlink-tevi-ov5640.dtbo
	TARGET_BOARD_DTBO_CONFIG += imx8mm:imx8mm-edm-g-$(BASEBOARD_TAG)-vizionlink-tevi-ap1302.dtbo
endif

ALL_DEFAULT_INSTALLED_MODULES += $(BOARD_VENDOR_KERNEL_MODULES)


# -------@block_sepolicy-------
BOARD_SEPOLICY_DIRS := \
 $(CONFIG_REPO_PATH)/imx8m/sepolicy \
 $(IMX_DEVICE_PATH)/sepolicy

BOARD_SEPOLICY_DIRS += vendor/technexion/sepolicy/vendor vendor/technexion/sepolicy/$(SOC_MODEL_LT)
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += vendor/technexion/sepolicy/system


# -------@block_others-------
# PRODUCT_COPY_FILES directives.
# Install wcnss_filter need this
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true

BOARD_VENDOR_KERNEL_MODULES += $(KERNEL_OUT)/drivers/input/touchscreen/exc3000.ko
