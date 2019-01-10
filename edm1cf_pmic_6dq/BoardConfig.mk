#
# Product-specific compile-time definitions.
#
include device/fsl/imx6/soc/edm1cf_pmic_6dq.mk
include device/fsl/edm1cf_pmic_6dq/build_id.mk
include device/fsl/imx6/BoardConfigCommon.mk
ifeq ($(PREBUILT_FSL_IMX_CODEC),true)
-include $(FSL_CODEC_PATH)/fsl-codec/fsl-codec.mk
endif

# edm1cf_pmic_6dq default target for EXT4
BUILD_TARGET_FS ?= ext4
include device/fsl/imx6/imx6_target_fs.mk

ifneq ($(BUILD_TARGET_FS),f2fs)
# build for ext4
ifeq ($(PRODUCT_IMX_CAR),true)
TARGET_RECOVERY_FSTAB = device/fsl/edm1cf_pmic_6dq/fstab.freescale.car
PRODUCT_COPY_FILES +=	\
	device/fsl/edm1cf_pmic_6dq/fstab.freescale.car:root/fstab.freescale
else
TARGET_RECOVERY_FSTAB = device/fsl/edm1cf_pmic_6dq/fstab.freescale
PRODUCT_COPY_FILES +=	\
	device/fsl/edm1cf_pmic_6dq/fstab.freescale:root/fstab.freescale
endif # PRODUCT_IMX_CAR
else
TARGET_RECOVERY_FSTAB = device/fsl/edm1cf_pmic_6dq/fstab-f2fs.freescale
# build for f2fs
PRODUCT_COPY_FILES +=	\
	device/fsl/edm1cf_pmic_6dq/fstab-f2fs.freescale:root/fstab.freescale
endif # BUILD_TARGET_FS

# Vendor Interface Manifest
ifeq ($(PRODUCT_IMX_CAR),true)
PRODUCT_COPY_FILES += \
    device/fsl/edm1cf_pmic_6dq/manifest_car.xml:vendor/manifest.xml
else
PRODUCT_COPY_FILES += \
    device/fsl/edm1cf_pmic_6dq/manifest.xml:vendor/manifest.xml
endif

TARGET_BOOTLOADER_BOARD_NAME := EDM1CF-PMIC
PRODUCT_MODEL := EDM1CF-PMIC-MX6DL

TARGET_BOOTLOADER_POSTFIX := imx
TARGET_DTB_POSTFIX := -dtb

TARGET_RELEASETOOLS_EXTENSIONS := device/fsl/imx6

# Qcom (QCA9377) WLAN
BOARD_HAS_QCOM_WLAN := true
BOARD_WLAN_DEVICE            := qcwcn
WPA_SUPPLICANT_VERSION       := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER  := NL80211
BOARD_HOSTAPD_DRIVER         := NL80211

BOARD_HOSTAPD_PRIVATE_LIB               := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_PRIVATE_LIB        := lib_driver_cmd_$(BOARD_WLAN_DEVICE)

BOARD_VENDOR_KERNEL_MODULES += \
                            device/fsl/edm1cf_pmic_6dq/wifi-firmware/wlan.ko

#for accelerator sensor, need to define sensor type here
BOARD_HAS_SENSOR := true
SENSOR_MMA8451 := true

# for recovery service
TARGET_SELECT_KEY := 28

# we don't support sparse image.
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := false
# uncomment below lins if use NAND
#TARGET_USERIMAGES_USE_UBIFS = true


ifeq ($(TARGET_USERIMAGES_USE_UBIFS),true)
UBI_ROOT_INI := device/fsl/edm1cf_pmic_6dq/ubi/ubinize.ini
TARGET_MKUBIFS_ARGS := -m 4096 -e 516096 -c 4096 -x none
TARGET_UBIRAW_ARGS := -m 4096 -p 512KiB $(UBI_ROOT_INI)
endif

ifeq ($(TARGET_USERIMAGES_USE_UBIFS),true)
ifeq ($(TARGET_USERIMAGES_USE_EXT4),true)
$(error "TARGET_USERIMAGES_USE_UBIFS and TARGET_USERIMAGES_USE_EXT4 config open in same time, please only choose one target file system image")
endif
endif

BOARD_KERNEL_CMDLINE := console=ttymxc0,115200 init=/init video=mxcfb0:dev=ldb,fbpix=RGB32,bpp=32 video=mxcfb1:off video=mxcfb2:off video=mxcfb3:off vmalloc=128M androidboot.console=ttymxc0 consoleblank=0 androidboot.hardware=freescale cma=448M galcore.contiguousSize=33554432

ifeq ($(TARGET_USERIMAGES_USE_UBIFS),true)
#UBI boot command line.
# Note: this NAND partition table must align with MFGTool's config.
BOARD_KERNEL_CMDLINE +=  mtdparts=gpmi-nand:16m(bootloader),16m(bootimg),128m(recovery),-(root) gpmi_debug_init ubi.mtd=3
endif


# Broadcom BCM4339 BT
BOARD_HAVE_BLUETOOTH_BCM := true
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := device/fsl/edm1cf_pmic_6dq/bluetooth

USE_ION_ALLOCATOR := true
USE_GPU_ALLOCATOR := false

# define frame buffer count
NUM_FRAMEBUFFER_SURFACE_BUFFERS := 3

PHONE_MODULE_INCLUDE := true
# camera hal v3
IMX_CAMERA_HAL_V3 := true


#define consumer IR HAL support
IMX6_CONSUMER_IR_HAL := false

TARGET_BOOTLOADER_CONFIG := edm-cf-imx6_defconfig
TARGET_BOARD_DTS_CONFIG :=	imx6dl-edm1_fairy.dtb imx6q-edm1_fairy.dtb imx6qp-edm1_fairy.dtb imx6dl-edm1_tc0700.dtb imx6q-edm1_tc0700.dtb imx6qp-edm1_tc0700.dtb \
							imx6dl-edm1_tc1000.dtb imx6q-edm1_tc1000.dtb imx6qp-edm1_tc1000.dtb

BOARD_SEPOLICY_DIRS := \
       device/fsl/imx6/sepolicy \
       device/fsl/edm1cf_pmic_6dq/sepolicy

ifeq ($(PRODUCT_IMX_CAR),true)
BOARD_SEPOLICY_DIRS += \
     packages/services/Car/car_product/sepolicy \
     device/generic/car/common/sepolicy
endif

PRODUCT_COPY_FILES +=	\
       device/fsl/edm1cf_pmic_6dq/ueventd.freescale.rc:root/ueventd.freescale.rc

# Support gpt
BOARD_BPT_INPUT_FILES += device/fsl/common/partition/device-partitions-4GB.bpt
ADDITION_BPT_PARTITION = partition-table-7GB:device/fsl/common/partition/device-partitions-7GB.bpt \
                         partition-table-14GB:device/fsl/common/partition/device-partitions-14GB.bpt \
                         partition-table-28GB:device/fsl/common/partition/device-partitions-28GB.bpt

# Vendor seccomp policy files for media components:
PRODUCT_COPY_FILES += \
       device/fsl/edm1cf_pmic_6dq/seccomp/mediacodec-seccomp.policy:vendor/etc/seccomp_policy/mediacodec.policy \
       device/fsl/edm1cf_pmic_6dq/seccomp/mediaextractor-seccomp.policy:vendor/etc/seccomp_policy/mediaextractor.policy

PRODUCT_COPY_FILES += \
       device/fsl/edm1cf_pmic_6dq/app_whitelist.xml:system/etc/sysconfig/app_whitelist.xml

TARGET_BOARD_KERNEL_HEADERS := device/fsl/common/kernel-headers
