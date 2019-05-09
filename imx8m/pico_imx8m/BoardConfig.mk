#
# SoC-specific compile-time definitions.
#

BOARD_SOC_TYPE := IMX8MQ
BOARD_HAVE_VPU := true
BOARD_VPU_TYPE := hantro
HAVE_FSL_IMX_GPU2D := false
HAVE_FSL_IMX_GPU3D := true
HAVE_FSL_IMX_IPU := false
HAVE_FSL_IMX_PXP := false
BOARD_KERNEL_BASE := 0x40400000
TARGET_GRALLOC_VERSION := v3
TARGET_HIGH_PERFORMANCE := true
TARGET_USES_HWC2 := true
TARGET_HWCOMPOSER_VERSION := v2.0
TARGET_HAVE_VIV_HWCOMPOSER = false
USE_OPENGL_RENDERER := true
TARGET_CPU_SMP := true
TARGET_HAVE_VULKAN := true
ENABLE_CFI=false

# enable opencl 2d.
TARGET_OPENCL_2D := true

#
# Product-specific compile-time definitions.
#

IMX_DEVICE_PATH := device/fsl/imx8m/pico_imx8m
ADDITION_DRIVERS_PATH := vendor/nxp-opensource/out-of-tree_drivers

include $(IMX_DEVICE_PATH)/build_id.mk
include device/fsl/imx8m/BoardConfigCommon.mk
ifeq ($(PREBUILT_FSL_IMX_CODEC),true)
-include $(FSL_CODEC_PATH)/fsl-codec/fsl-codec.mk
endif

BUILD_TARGET_FS ?= ext4
TARGET_USERIMAGES_USE_EXT4 := true

TARGET_RECOVERY_FSTAB = $(IMX_DEVICE_PATH)/fstab.freescale

# Support gpt
BOARD_BPT_INPUT_FILES += device/fsl/common/partition/device-partitions-13GB-ab.bpt
ADDITION_BPT_PARTITION = partition-table-7GB:device/fsl/common/partition/device-partitions-7GB-ab.bpt \
                         partition-table-28GB:device/fsl/common/partition/device-partitions-28GB-ab.bpt \
                         partition-table-13GB:device/fsl/common/partition/device-partitions-13GB-ab.bpt



# Vendor Interface manifest and compatibility
DEVICE_MANIFEST_FILE := $(IMX_DEVICE_PATH)/manifest.xml
DEVICE_MATRIX_FILE := $(IMX_DEVICE_PATH)/compatibility_matrix.xml

TARGET_BOOTLOADER_BOARD_NAME := PICO-IMX8M

PRODUCT_MODEL := PICO-IMX8M

TARGET_BOOTLOADER_POSTFIX := bin

USE_OPENGL_RENDERER := true
TARGET_CPU_SMP := true

BOARD_WLAN_DEVICE_UNITE      := UNITE
WPA_SUPPLICANT_VERSION       := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER  := NL80211
BOARD_HOSTAPD_DRIVER         := NL80211

# In UNITE mode,Use default macro for bcmdhd and use unite macro for qcom
ifeq ($(BOARD_WLAN_DEVICE_UNITE), UNITE)
BOARD_WLAN_DEVICE            := bcmdhd
BOARD_HOSTAPD_PRIVATE_LIB_QCA           := lib_driver_cmd_qcwcn
BOARD_WPA_SUPPLICANT_PRIVATE_LIB_QCA    := lib_driver_cmd_qcwcn
BOARD_HOSTAPD_PRIVATE_LIB_BCM           := lib_driver_cmd_bcmdhd
BOARD_WPA_SUPPLICANT_PRIVATE_LIB_BCM    := lib_driver_cmd_bcmdhd
endif

WIFI_DRIVER_FW_PATH_PARAM := "/sys/module/brcmfmac/parameters/alternative_fw_path"

WIFI_HIDL_FEATURE_DUAL_INTERFACE := true

# QCA qcacld wifi driver module
BOARD_VENDOR_KERNEL_MODULES += \
    $(KERNEL_OUT)/drivers/net/wireless/qcacld-2.0/wlan.ko

BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(IMX_DEVICE_PATH)/bluetooth

# Qcom 1CQ(QCA6174) BT
BOARD_HAVE_BLUETOOTH_QCOM := true
BOARD_HAS_QCA_BT_ROME := true
BOARD_SUPPORTS_BLE_VND : true
BOARD_HAVE_BLUETOOTH_BLUEZ := false

BOARD_USE_SENSOR_FUSION := true

# for recovery service
TARGET_SELECT_KEY := 28
# we don't support sparse image.
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := false

UBOOT_POST_PROCESS := true

# camera hal v3
IMX_CAMERA_HAL_V3 := true

BOARD_HAVE_USB_CAMERA := true

# whether to accelerate camera service with openCL
# it will make camera service load the opencl lib in vendor
# and break the full treble rule
#OPENCL_2D_IN_CAMERA := true

USE_ION_ALLOCATOR := true
USE_GPU_ALLOCATOR := false

BOARD_AVB_ENABLE := true
TARGET_USES_MKE2FS := true

# define frame buffer count
NUM_FRAMEBUFFER_SURFACE_BUFFERS := 3

ifeq ($(DRAM_SIZE_1G),true)
CMASIZE=400M
else
CMASIZE=900M
endif

KERNEL_NAME := Image

ifeq ($(DISPLAY_TARGET),DISP_HDMI)
BOARD_KERNEL_CMDLINE := init=/init androidboot.hwrotation=0 androidboot.gui_resolution=1080p androidboot.console=ttymxc0 androidboot.hardware=freescale androidboot.fbTileSupport=enable cma=$(CMASIZE) androidboot.primary_display=imx-drm firmware_class.path=/vendor/firmware transparent_hugepage=never
else ifeq ($(DISPLAY_TARGET),DISP_MIPI_ILI9881C)
BOARD_KERNEL_CMDLINE := init=/init androidboot.hwrotation=90 androidboot.console=ttymxc0 androidboot.hardware=freescale androidboot.fbTileSupport=enable cma=$(CMASIZE) androidboot.primary_display=imx-drm firmware_class.path=/vendor/firmware transparent_hugepage=never
endif

# Default wificountrycode
BOARD_KERNEL_CMDLINE += androidboot.wificountrycode=TW

# Defaultly pico_imx8m use BCM 1CX BCM4356 wifi module, if use QCOM qca9377 module, set androidboot.wifivendor=qca
BOARD_KERNEL_CMDLINE += androidboot.wifivendor=qca

ifeq ($(TARGET_USERIMAGES_USE_UBIFS),true)
ifeq ($(TARGET_USERIMAGES_USE_EXT4),true)
$(error "TARGET_USERIMAGES_USE_UBIFS and TARGET_USERIMAGES_USE_EXT4 config open in same time, please only choose one target file system image")
endif
endif

BOARD_PREBUILT_DTBOIMAGE := out/target/product/pico_imx8m/dtbo-imx8mq.img

# display with dtb
ifeq ($(DISPLAY_TARGET),DISP_HDMI)

ifeq ($(AUDIOHAT_ACTIVE),true)
TARGET_BOARD_DTS_CONFIG := imx8mq:imx8mq-pico-pi-voicehat.dtb
else
TARGET_BOARD_DTS_CONFIG := imx8mq:imx8mq-pico-pi.dtb
endif

else ifeq ($(DISPLAY_TARGET),DISP_MIPI_ILI9881C)

ifeq ($(AUDIOHAT_ACTIVE),true)
TARGET_BOARD_DTS_CONFIG := imx8mq:imx8mq-pico-pi-dcss-ili9881c-voicehat.dtb
else
TARGET_BOARD_DTS_CONFIG := imx8mq:imx8mq-pico-pi-dcss-ili9881c.dtb
endif

endif

ifeq ($(AUDIOHAT_ACTIVE),true)
ifneq (,$(wildcard $(ADDITION_DRIVERS_PATH)/tfa98xx/snd-soc-tfa98xx.ko))
BOARD_VENDOR_KERNEL_MODULES += \
  $(ADDITION_DRIVERS_PATH)/tfa98xx/snd-soc-tfa98xx.ko
endif
endif


TARGET_BOOTLOADER_CONFIG := imx8mq:pico-imx8m_android_defconfig

TARGET_KERNEL_DEFCONFIG := tn_imx8_android_defconfig
TARGET_KERNEL_ADDITION_DEFCONF ?= android_addition_defconfig

BOARD_SEPOLICY_DIRS := \
       device/fsl/imx8m/sepolicy \
       $(IMX_DEVICE_PATH)/sepolicy

ifeq ($(PRODUCT_IMX_DRM),true)
BOARD_SEPOLICY_DIRS += \
       $(IMX_DEVICE_PATH)/sepolicy_drm
endif

TARGET_BOARD_KERNEL_HEADERS := device/fsl/common/kernel-headers
