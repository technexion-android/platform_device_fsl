# This is a FSL Android Reference Design platform based on i.MX6Q ARD board
# It will inherit from FSL core product which in turn inherit from Google generic
-include device/fsl/common/imx_path/ImxPathConfig.mk
$(call inherit-product, device/fsl/imx6/imx6.mk)
$(call inherit-product-if-exists,vendor/google/products/gms.mk)

ifneq ($(wildcard device/fsl/edm1cf_pmic_6dq/fstab_nand.freescale),)
$(shell touch device/fsl/edm1cf_pmic_6dq/fstab_nand.freescale)
endif

ifneq ($(wildcard device/fsl/edm1cf_pmic_6dq/fstab.freescale),)
$(shell touch device/fsl/edm1cf_pmic_6dq/fstab.freescale)
endif

# Device does not have firmware by default
BOARD_HAS_BLUETOOTH_FIRMWARE := false

# Overrides
PRODUCT_NAME := edm1cf_pmic_6dq
PRODUCT_DEVICE := edm1cf_pmic_6dq

PRODUCT_COPY_FILES += \
	device/fsl/edm1cf_pmic_6dq/init.rc:root/init.freescale.rc \
	device/fsl/edm1cf_pmic_6dq/init.imx6q.rc:root/init.freescale.imx6q.rc \
	device/fsl/edm1cf_pmic_6dq/init.imx6dl.rc:root/init.freescale.imx6dl.rc \
	device/fsl/edm1cf_pmic_6dq/init.imx6qp.rc:root/init.freescale.imx6qp.rc \

PRODUCT_COPY_FILES += device/fsl/edm1cf_pmic_6dq/init.freescale.emmc.rc:root/init.freescale.emmc.rc
PRODUCT_COPY_FILES += device/fsl/edm1cf_pmic_6dq/init.freescale.sd.rc:root/init.freescale.sd.rc

# ethernet files
PRODUCT_COPY_FILES += \
	device/fsl/edm1cf_pmic_6dq/ethernet/eth_updown:system/bin/eth_updown

# Audio
#	device/fsl/edm1cf_pmic_6dq/audio_policy_hdmi.conf:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy.conf \
USE_XML_AUDIO_POLICY_CONF := 1
PRODUCT_COPY_FILES += \
	device/fsl/edm1cf_pmic_6dq/audio_effects.conf:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.conf \
	device/fsl/edm1cf_pmic_6dq/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
	frameworks/av/services/audiopolicy/config/a2dp_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/a2dp_audio_policy_configuration.xml \
	frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration.xml \
	frameworks/av/services/audiopolicy/config/usb_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/usb_audio_policy_configuration.xml \
	frameworks/av/services/audiopolicy/config/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables.xml \
	frameworks/av/services/audiopolicy/config/audio_policy_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes.xml

PRODUCT_COPY_FILES +=	\
	$(LINUX_FIRMWARE_IMX_PATH)/linux-firmware-imx/firmware/vpu/vpu_fw_imx6d.bin:system/lib/firmware/vpu/vpu_fw_imx6d.bin 	\
	$(LINUX_FIRMWARE_IMX_PATH)/linux-firmware-imx/firmware/vpu/vpu_fw_imx6q.bin:system/lib/firmware/vpu/vpu_fw_imx6q.bin

# setup dm-verity configs.
 PRODUCT_SYSTEM_VERITY_PARTITION := /dev/block/platform/soc0/soc/2100000.aips-bus/2198000.usdhc/by-name/system
 $(call inherit-product, build/target/product/verity.mk)

# GPU files

DEVICE_PACKAGE_OVERLAYS := device/fsl/edm1cf_pmic_6dq/overlay

PRODUCT_CHARACTERISTICS := tablet

PRODUCT_AAPT_CONFIG += xlarge large tvdpi hdpi xhdpi

PRODUCT_COPY_FILES += \
	device/fsl/edm1cf_pmic_6dq/tablet_core_hardware.xml:system/etc/permissions/tablet_core_hardware.xml \
	frameworks/native/data/etc/android.hardware.camera.xml:system/etc/permissions/android.hardware.camera.xml \
	frameworks/native/data/etc/android.hardware.camera.front.xml:system/etc/permissions/android.hardware.camera.front.xml \
	frameworks/native/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
	frameworks/native/data/etc/android.hardware.wifi.direct.xml:system/etc/permissions/android.hardware.wifi.direct.xml \
	frameworks/native/data/etc/android.hardware.sensor.light.xml:system/etc/permissions/android.hardware.sensor.light.xml \
	frameworks/native/data/etc/android.hardware.faketouch.xml:system/etc/permissions/android.hardware.faketouch.xml \
	frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml \
	frameworks/native/data/etc/android.hardware.usb.host.xml:system/etc/permissions/android.hardware.usb.host.xml \
	frameworks/native/data/etc/android.hardware.usb.accessory.xml:system/etc/permissions/android.hardware.usb.accessory.xml \
	frameworks/native/data/etc/android.hardware.bluetooth_le.xml:system/etc/permissions/android.hardware.bluetooth_le.xml \
	frameworks/native/data/etc/android.hardware.ethernet.xml:system/etc/permissions/android.hardware.ethernet.xml \
	device/fsl/edm1cf_pmic_6dq/required_hardware.xml:system/etc/permissions/required_hardware.xml

PRODUCT_COPY_FILES += \
    $(FSL_PROPRIETARY_PATH)/fsl-proprietary/gpu-viv/lib/egl/egl.cfg:system/lib/egl/egl.cfg

# Atheros wifi file
#	out/target/product/edm1cf_pmic_6dq/obj/KERNEL_OBJ/drivers/net/wireless/ath/ath.ko:system/lib/modules/ath.ko \
#	out/target/product/edm1cf_pmic_6dq/obj/KERNEL_OBJ/drivers/net/wireless/ath/ath10k/ath10k_core.ko:system/lib/modules/ath10k_core.ko \
#	out/target/product/edm1cf_pmic_6dq/obj/KERNEL_OBJ/drivers/net/wireless/ath/ath10k/ath10k_sdio.ko:system/lib/modules/ath10k_sdio.ko \
#	device/fsl/edm1cf_pmic_6dq/wifi-firmware/ath.ko:system/lib/modules/ath.ko \
#	device/fsl/edm1cf_pmic_6dq/wifi-firmware/ath10k_core.ko:system/lib/modules/ath10k_core.ko \
#	device/fsl/edm1cf_pmic_6dq/wifi-firmware/ath10k_sdio.ko:system/lib/modules/ath10k_sdio.ko \
#	device/fsl/edm1cf_pmic_6dq/bluetooth/bt_vendor.conf:system/etc/bluetooth/bt_vendor.conf	\

ifeq ($(BOARD_HAS_BLUETOOTH_FIRMWARE),true)
PRODUCT_COPY_FILES += \
	device/fsl/edm1cf_pmic_6dq/bluetooth/Type_ZP.hcd:$(TARGET_COPY_OUT_VENDOR)/etc/firmware/bcm/Type_ZP.hcd 	\
	device/fsl/edm1cf_pmic_6dq/bluetooth/bcm43438a0.hcd:$(TARGET_COPY_OUT_VENDOR)/etc/firmware/bcm/bcm43438a0.hcd 	\
	device/fsl/edm1cf_pmic_6dq/bluetooth/bcm4330.hcd:$(TARGET_COPY_OUT_VENDOR)/etc/firmware/bcm/bcm4330.hcd
endif

# QCA9377 Bluetooth Firmware
ifneq (,$(wildcard device/fsl/edm1cf_pmic_6dq/bluetooth/nvm_tlv_3.2.bin))
PRODUCT_COPY_FILES += \
	device/fsl/edm1cf_pmic_6dq/bluetooth/nvm_tlv_3.2.bin:$(TARGET_COPY_OUT_VENDOR)/firmware/qca/tfbtnv11.bin
endif
ifneq (,$(wildcard device/fsl/edm1cf_pmic_6dq/bluetooth/rampatch_tlv_3.2.tlv))
PRODUCT_COPY_FILES += \
	device/fsl/edm1cf_pmic_6dq/bluetooth/rampatch_tlv_3.2.tlv:$(TARGET_COPY_OUT_VENDOR)/firmware/qca/tfbtfw11.tlv
endif

BOARD_CUSTOM_BT_CONFIG := device/fsl/edm1cf_pmic_6dq/bluetooth/libbt_vnd.conf

# QCA9377 WiFi Firmware
ifneq (,$(wildcard device/fsl/edm1cf_pmic_6dq/wifi-firmware/QCA9377/wlan/cfg.dat))
PRODUCT_COPY_FILES += \
	device/fsl/edm1cf_pmic_6dq/wifi-firmware/QCA9377/wlan/cfg.dat:vendor/lib/firmware/wlan/cfg.dat
endif
ifneq (,$(wildcard device/fsl/edm1cf_pmic_6dq/wifi-firmware/QCA9377/wlan/qcom_cfg.ini))
PRODUCT_COPY_FILES += \
	device/fsl/edm1cf_pmic_6dq/wifi-firmware/QCA9377/wlan/qcom_cfg.ini:vendor/lib/firmware/wlan/qcom_cfg.ini
endif
ifneq (,$(wildcard device/fsl/edm1cf_pmic_6dq/wifi-firmware/QCA9377/bdwlan30.bin))
PRODUCT_COPY_FILES += \
	device/fsl/edm1cf_pmic_6dq/wifi-firmware/QCA9377/bdwlan30.bin:vendor/lib/firmware/bdwlan30.bin
endif
ifneq (,$(wildcard device/fsl/edm1cf_pmic_6dq/wifi-firmware/QCA9377/otp30.bin))
PRODUCT_COPY_FILES += \
	device/fsl/edm1cf_pmic_6dq/wifi-firmware/QCA9377/otp30.bin:vendor/lib/firmware/otp30.bin
endif
ifneq (,$(wildcard device/fsl/edm1cf_pmic_6dq/wifi-firmware/QCA9377/qwlan30.bin))
PRODUCT_COPY_FILES += \
	device/fsl/edm1cf_pmic_6dq/wifi-firmware/QCA9377/qwlan30.bin:vendor/lib/firmware/qwlan30.bin
endif
ifneq (,$(wildcard device/fsl/edm1cf_pmic_6dq/wifi-firmware/QCA9377/utf30.bin))
PRODUCT_COPY_FILES += \
	device/fsl/edm1cf_pmic_6dq/wifi-firmware/QCA9377/utf30.bin:vendor/lib/firmware/utf30.bin
endif

#PRODUCT_COPY_FILES += \
#	device/fsl/edm1cf_pmic_6dq/wifi-firmware/QCA9377/hw1.0/board.bin:vendor/lib/firmware/ath10k/QCA9377/hw1.0/board.bin \
#	device/fsl/edm1cf_pmic_6dq/wifi-firmware/QCA9377/hw1.0/board-2.bin:vendor/lib/firmware/ath10k/QCA9377/hw1.0/board-2.bin \
#	device/fsl/edm1cf_pmic_6dq/wifi-firmware/QCA9377/hw1.0/board-sdio.bin:vendor/lib/firmware/ath10k/QCA9377/hw1.0/board-sdio.bin \
#	device/fsl/edm1cf_pmic_6dq/wifi-firmware/QCA9377/hw1.0/firmware-sdio-5.bin:vendor/lib/firmware/ath10k/QCA9377/hw1.0/firmware-sdio-5.bin

# HWC2 HAL
PRODUCT_PACKAGES += \
    android.hardware.graphics.composer@2.1-impl

# Gralloc HAL
PRODUCT_PACKAGES += \
    android.hardware.graphics.mapper@2.0-impl \
    android.hardware.graphics.allocator@2.0-impl \
    android.hardware.graphics.allocator@2.0-service

# RenderScript HAL
PRODUCT_PACKAGES += \
    android.hardware.renderscript@1.0-impl

PRODUCT_PACKAGES += \
    android.hardware.audio@2.0-impl \
    android.hardware.audio@2.0-service \
    android.hardware.audio.effect@2.0-impl \
    android.hardware.sensors@1.0-impl \
    android.hardware.sensors@1.0-service \
    android.hardware.power@1.0-impl \
    android.hardware.power@1.0-service \
    android.hardware.light@2.0-impl \
    android.hardware.light@2.0-service

# imx6 sensor HAL libs.
PRODUCT_PACKAGES += \
       sensors.imx6

# Usb HAL
PRODUCT_PACKAGES += \
    android.hardware.usb@1.0-service

# Bluetooth HAL
PRODUCT_PACKAGES += \
    android.hardware.bluetooth@1.0-impl \
    android.hardware.bluetooth@1.0-service

# WiFi HAL
PRODUCT_PACKAGES += \
    android.hardware.wifi@1.0-service \
    wifilogd \
    wificond

# Keymaster HAL
PRODUCT_PACKAGES += \
    android.hardware.keymaster@3.0-impl

PRODUCT_PACKAGES += \
    libEGL_VIVANTE \
    libGLESv1_CM_VIVANTE \
    libGLESv2_VIVANTE \
    libGAL \
    libGLSLC \
    libVSC \
    libg2d \
    libgpuhelper

PRODUCT_PACKAGES += \
    Launcher3

PRODUCT_PROPERTY_OVERRIDES += \
    ro.internel.storage_size=/sys/block/bootdev_size

PRODUCT_PROPERTY_OVERRIDES += ro.frp.pst=/dev/block/platform/soc0/soc/2100000.aips-bus/2198000.usdhc/by-name/presistdata

#	AmazeFileManager
#	Chromium 
PRODUCT_PACKAGES += \
    EDM_GPIO \
    EDM_UART \
    EDM_CANBUS \
    Reboot

