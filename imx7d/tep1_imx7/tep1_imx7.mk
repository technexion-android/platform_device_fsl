# This is a FSL Android Reference Design platform based on i.MX6Q ARD board
# It will inherit from FSL core product which in turn inherit from Google generic

IMX_DEVICE_PATH := device/fsl/imx7d/tep1_imx7

-include device/fsl/common/imx_path/ImxPathConfig.mk
$(call inherit-product, device/fsl/imx7d/ProductConfigCommon.mk)
$(call inherit-product-if-exists,vendor/google/products/gms.mk)
$(call inherit-product, build/target/product/go_defaults.mk)

ifneq ($(wildcard $(IMX_DEVICE_PATH)/fstab_nand.freescale),)
$(shell touch $(IMX_DEVICE_PATH)/fstab_nand.freescale)
endif

ifneq ($(wildcard $(IMX_DEVICE_PATH)/fstab.freescale),)
$(shell touch $(IMX_DEVICE_PATH)/fstab.freescale)
endif

# Overrides
PRODUCT_NAME := tep1_imx7
PRODUCT_DEVICE := tep1_imx7

ifneq ($(EXPORT_BASEBOARD_NAME),NYMPH)
# Copy touch/keyboard related config file
PRODUCT_COPY_FILES +=	\
	device/fsl/common/input/Dell_Dell_USB_Keyboard.kl:system/usr/keylayout/Dell_Dell_USB_Keyboard.kl \
	device/fsl/common/input/Dell_Dell_USB_Keyboard.idc:system/usr/idc/Dell_Dell_USB_Keyboard.idc \
	device/fsl/common/input/Dell_Dell_USB_Entry_Keyboard.idc:system/usr/idc/Dell_Dell_USB_Entry_Keyboard.idc \
	device/fsl/common/input/eGalax_Touch_Screen.idc:system/usr/idc/eGalax_Touch_Screen.idc \
	device/fsl/common/input/eGalax_Touch_Screen.idc:system/usr/idc/HannStar_P1003_Touchscreen.idc \
	device/fsl/common/input/eGalax_Touch_Screen.idc:system/usr/idc/Novatek_NT11003_Touch_Screen.idc
endif

# Copy device related config and binary to board
PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/app_whitelist.xml:system/etc/sysconfig/app_whitelist.xml \
    $(IMX_DEVICE_PATH)/fstab.freescale:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.freescale \
    $(IMX_DEVICE_PATH)/init.freescale.emmc.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.freescale.emmc.rc \
    $(IMX_DEVICE_PATH)/init.freescale.emmc.rc:root/init.recovery.freescale.emmc.rc \
    $(IMX_DEVICE_PATH)/init.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.freescale.rc \
    $(IMX_DEVICE_PATH)/required_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/required_hardware.xml \
    $(IMX_DEVICE_PATH)/ueventd.freescale.rc:$(TARGET_COPY_OUT_VENDOR)/ueventd.rc \
    $(IMX_DEVICE_PATH)/early.init.cfg:$(TARGET_COPY_OUT_VENDOR)/etc/early.init.cfg \
    $(IMX_DEVICE_PATH)/privapp-permissions-imx.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp-permissions-imx.xml \
    $(LINUX_FIRMWARE_IMX_PATH)/linux-firmware-imx/firmware/sdma/sdma-imx7d.bin:$(TARGET_COPY_OUT_VENDOR)/firmware/imx/sdma/sdma-imx7d.bin \
    device/fsl/common/init/init.insmod.sh:$(TARGET_COPY_OUT_VENDOR)/bin/init.insmod.sh \
    device/fsl/common/input/imx-keypad.idc:$(TARGET_COPY_OUT_VENDOR)/usr/idc/imx-keypad.idc \
    device/fsl/common/input/imx-keypad.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/imx-keypad.kl \
    device/fsl/common/wifi/p2p_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/p2p_supplicant_overlay.conf \
    device/fsl/common/wifi/wpa_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant_overlay.conf \

# ONLY devices that meet the CDD's requirements may declare these features
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.audio.output.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.output.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.hardware.camera.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.xml \
    frameworks/native/data/etc/android.hardware.ethernet.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.ethernet.xml \
    frameworks/native/data/etc/android.hardware.screen.landscape.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.screen.landscape.xml \
    frameworks/native/data/etc/android.hardware.screen.portrait.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.screen.portrait.xml \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.ambient_temperature.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.ambient_temperature.xml \
    frameworks/native/data/etc/android.hardware.sensor.barometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.barometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.compass.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.compass.xml \
    frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.gyroscope.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.distinct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.distinct.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.xml \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.software.app_widgets.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.app_widgets.xml \
    frameworks/native/data/etc/android.software.backup.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.backup.xml \
    frameworks/native/data/etc/android.software.device_admin.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.device_admin.xml \
    frameworks/native/data/etc/android.software.print.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.print.xml \
    frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.sip.voip.xml \
    frameworks/native/data/etc/android.software.verified_boot.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.verified_boot.xml

# Vendor seccomp policy files for media components:
PRODUCT_COPY_FILES += \
	$(IMX_DEVICE_PATH)/seccomp/mediacodec-seccomp.policy:vendor/etc/seccomp_policy/mediacodec.policy \
	$(IMX_DEVICE_PATH)/seccomp/mediaextractor-seccomp.policy:vendor/etc/seccomp_policy/mediaextractor.policy

# Audio
USE_XML_AUDIO_POLICY_CONF := 1
PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml \
    $(IMX_DEVICE_PATH)/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/a2dp_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/a2dp_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/audio_policy_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes.xml \
    frameworks/av/services/audiopolicy/config/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables.xml \
    frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/usb_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/usb_audio_policy_configuration.xml

# fastboot_imx_flashall scripts, fsl-sdcard-partition script and uuu_imx_android_flash scripts
PRODUCT_COPY_FILES += \
    device/fsl/common/tools/fastboot_imx_flashall.bat:fastboot_imx_flashall.bat \
    device/fsl/common/tools/fastboot_imx_flashall.sh:fastboot_imx_flashall.sh \
    device/fsl/common/tools/fsl-sdcard-partition.sh:fsl-sdcard-partition.sh \
    device/fsl/common/tools/uuu_imx_android_flash.bat:uuu_imx_android_flash.bat \
    device/fsl/common/tools/uuu_imx_android_flash.sh:uuu_imx_android_flash.sh \
    device/fsl/common/tools/fsl-sdcard-partition-virtual-image.sh:fsl-sdcard-partition-virtual-image.sh

# tn-init file
PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/init/tn_init.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/tn_init.sh

DEVICE_PACKAGE_OVERLAYS := $(IMX_DEVICE_PATH)/overlay

PRODUCT_CHARACTERISTICS := tablet

PRODUCT_AAPT_CONFIG += xlarge large tvdpi hdpi xhdpi
PRODUCT_CUSTOM_RECOVERY_DENSITY := mdpi

PRODUCT_PACKAGES += \
    Launcher2

# HWC2 HAL
PRODUCT_PACKAGES += \
    android.hardware.graphics.composer@2.1-impl \
    android.hardware.graphics.composer@2.1-service

# Gralloc HAL
PRODUCT_PACKAGES += \
    android.hardware.graphics.mapper@2.0-impl \
    android.hardware.graphics.allocator@2.0-impl \
    android.hardware.graphics.allocator@2.0-service

# RenderScript HAL
PRODUCT_PACKAGES += \
    android.hardware.renderscript@1.0-impl

PRODUCT_PACKAGES += \
    libg2d \
    libEGL_swiftshader \
    libGLESv1_CM_swiftshader \
    libGLESv2_swiftshader \
    gatekeeper.imx7

PRODUCT_PACKAGES += \
    android.hardware.audio@4.0-impl \
    android.hardware.audio@2.0-service \
    android.hardware.audio.effect@4.0-impl \
    android.hardware.sensors@1.0-impl \
    android.hardware.sensors@1.0-service \
    android.hardware.power@1.0-impl \
    android.hardware.power@1.0-service \
    android.hardware.light@2.0-impl \
    android.hardware.light@2.0-service \
    android.hardware.configstore@1.1-service \
    configstore@1.1.policy

# imx7 sensor HAL libs.
PRODUCT_PACKAGES += \
        sensors.imx7

# Usb HAL
PRODUCT_PACKAGES += \
    android.hardware.usb@1.1-service.imx

# Bluetooth HAL
PRODUCT_PACKAGES += \
    android.hardware.bluetooth@1.0-impl \
    android.hardware.bluetooth@1.0-service

# WiFi HAL
PRODUCT_PACKAGES += \
    android.hardware.wifi@1.0-service \
    wifilogd \
    wificond

# Qcom WiFi Firmware
ifneq (,$(wildcard $(IMX_DEVICE_PATH)/wifi-firmware/QCA9377/wlan/cfg.dat))
PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/wifi-firmware/QCA9377/wlan/cfg.dat:vendor/firmware/wlan/cfg.dat
endif
ifneq (,$(wildcard $(IMX_DEVICE_PATH)/wifi-firmware/QCA9377/wlan/qcom_cfg.ini))
PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/wifi-firmware/QCA9377/wlan/qcom_cfg.ini:vendor/firmware/wlan/qcom_cfg.ini
endif
ifneq (,$(wildcard $(IMX_DEVICE_PATH)/wifi-firmware/QCA9377/bdwlan30.bin))
PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/wifi-firmware/QCA9377/bdwlan30.bin:vendor/firmware/bdwlan30.bin
endif
ifneq (,$(wildcard $(IMX_DEVICE_PATH)/wifi-firmware/QCA9377/otp30.bin))
PRODUCT_COPY_FILES += \
     $(IMX_DEVICE_PATH)/wifi-firmware/QCA9377/otp30.bin:vendor/firmware/otp30.bin
endif
ifneq (,$(wildcard $(IMX_DEVICE_PATH)/wifi-firmware/QCA9377/qwlan30.bin))
PRODUCT_COPY_FILES += \
     $(IMX_DEVICE_PATH)/wifi-firmware/QCA9377/qwlan30.bin:vendor/firmware/qwlan30.bin
endif
ifneq (,$(wildcard $(IMX_DEVICE_PATH)/wifi-firmware/QCA9377/utf30.bin))
PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/wifi-firmware/QCA9377/utf30.bin:vendor/firmware/utf30.bin
endif

# Qcom Bluetooth Firmware
PRODUCT_COPY_FILES += \
    vendor/nxp/qca-wifi-bt/qca_proprietary/Android_HAL/wcnss_filter_8mq:vendor/bin/wcnss_filter

ifneq (,$(wildcard $(IMX_DEVICE_PATH)/bluetooth/rampatch_tlv_3.2.tlv))
PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/bluetooth/rampatch_tlv_3.2.tlv:$(TARGET_COPY_OUT_VENDOR)/firmware/qca/tfbtfw11.tlv
endif

ifneq (,$(wildcard $(IMX_DEVICE_PATH)/bluetooth/nvm_tlv_3.2.bin))
PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/bluetooth/nvm_tlv_3.2.bin:$(TARGET_COPY_OUT_VENDOR)/firmware/qca/tfbtnv11.bin
endif

PRODUCT_PACKAGES += \
    bt_vendor.conf

# Keymaster HAL
PRODUCT_PACKAGES += \
    android.hardware.keymaster@3.0-impl \
    android.hardware.keymaster@3.0-service

# DRM HAL
PRODUCT_PACKAGES += \
    android.hardware.drm@1.0-impl \
    android.hardware.drm@1.0-service

# new gatekeeper HAL
PRODUCT_PACKAGES += \
    android.hardware.gatekeeper@1.0-impl \
    android.hardware.gatekeeper@1.0-service

PRODUCT_PROPERTY_OVERRIDES += \
    ro.internel.storage_size=/sys/block/mmcblk2/size

PRODUCT_PROPERTY_OVERRIDES += ro.frp.pst=/dev/block/by-name/presistdata
PRODUCT_COMPATIBLE_PROPERTY_OVERRIDE := true

PRODUCT_PROPERTY_OVERRIDES += \
    ro.crypto.fde_algorithm=adiantum \
    ro.crypto.fde_sector_size=4096 \
    ro.crypto.volume.contents_mode=adiantum \
    ro.crypto.volume.filenames_mode=adiantum
