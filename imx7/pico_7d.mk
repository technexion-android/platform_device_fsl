# This is a FSL Android Reference Design platform based on i.MX6Q ARD board
# It will inherit from FSL core product which in turn inherit from Google generic

$(call inherit-product, device/fsl/imx7/imx7.mk)
$(call inherit-product-if-exists,vendor/google/products/gms.mk)

ifneq ($(wildcard device/fsl/pico_7d/fstab_nand.freescale),)
$(shell touch device/fsl/pico_7d/fstab_nand.freescale)
endif

ifneq ($(wildcard device/fsl/pico_7d/fstab.freescale),)
$(shell touch device/fsl/pico_7d/fstab.freescale)
endif

# setup dm-verity configs.
 PRODUCT_SYSTEM_VERITY_PARTITION := /dev/block/mmcblk0p5
 $(call inherit-product, build/target/product/verity.mk)

# Overrides
PRODUCT_NAME := pico_7d
PRODUCT_DEVICE := pico_7d

PRODUCT_COPY_FILES += \
	device/fsl/pico_7d/init.rc:root/init.freescale.rc \
	device/fsl/common/input/imx-keypad.idc:system/usr/idc/imx-keypad.idc \
	device/fsl/common/input/imx-keypad.kl:system/usr/keylayout/imx-keypad.kl \
	device/fsl/common/input/20b8000_kpp.idc:system/usr/idc/20b8000_kpp.idc \
	device/fsl/common/input/20b8000_kpp.kl:system/usr/keylayout/20b8000_kpp.kl

# touch files
PRODUCT_COPY_FILES += \
	device/fsl/common/input/eGalax_Touch_Screen.idc:system/usr/idc/fusion_Touch_Screen.idc \
	device/fsl/common/input/eGalax_Touch_Screen.idc:system/usr/idc/ADS7846_Touchscreen.idc

# Audio
USE_XML_AUDIO_POLICY_CONF := 1
PRODUCT_COPY_FILES += \
	device/fsl/sabresd_7d/audio_effects.conf:system/vendor/etc/audio_effects.conf \
	device/fsl/sabresd_7d/audio_policy_configuration.xml:system/etc/audio_policy_configuration.xml \
	frameworks/av/services/audiopolicy/config/a2dp_audio_policy_configuration.xml:system/etc/a2dp_audio_policy_configuration.xml \
	frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:system/etc/r_submix_audio_policy_configuration.xml \
	frameworks/av/services/audiopolicy/config/usb_audio_policy_configuration.xml:system/etc/usb_audio_policy_configuration.xml \
	frameworks/av/services/audiopolicy/config/default_volume_tables.xml:system/etc/default_volume_tables.xml \
	frameworks/av/services/audiopolicy/config/audio_policy_volumes.xml:system/etc/audio_policy_volumes.xml \

# bt files
PRODUCT_COPY_FILES += \
	device/fsl/pico_7d/bluetooth/bt_vendor.conf:system/etc/bluetooth/bt_vendor.conf \
	device/fsl/pico_7d/bluetooth/bt_reset:system/bin/bt_reset \
	device/fsl/pico_7d/bluetooth/bd_mac_gen:system/bin/bd_mac_gen

# wifi files
PRODUCT_COPY_FILES += \
	device/fsl/pico_7d/brcm-firmware/bcm43438a0.hcd:system/etc/firmware/bcm/bcm43438a0.hcd 	\
	device/fsl/pico_7d/brcm-firmware/fw_bcm43438a0.bin:system/etc/firmware/bcm/fw_bcm43438a0.bin 	\
	device/fsl/pico_7d/brcm-firmware/fw_bcm43438a0_apsta.bin:system/etc/firmware/bcm/fw_bcm43438a0_apsta.bin 	\
	device/fsl/pico_7d/brcm-firmware/fw_bcm43438a0_p2p.bin:system/etc/firmware/bcm/fw_bcm43438a0_p2p.bin 	\
	device/fsl/pico_7d/brcm-firmware/nvram_ap6212.txt:system/etc/firmware/bcm/nvram_ap6212.txt 	\
	external/imx-firmware/BCM4339/TypeZP/BCM4339_BT/Type_ZP.hcd:system/etc/firmware/bcm/Type_ZP.hcd 	\
	external/imx-firmware/BCM4339/TypeZP/BCM4339_wifi/fw_bcmdhd.bin:system/etc/firmware/bcm/fw_bcm4339a0_ag.bin 	\
	external/imx-firmware/BCM4339/TypeZP/BCM4339_wifi/fw_bcmdhd.bin:system/etc/firmware/bcm/fw_bcm4339a0_ag_apsta.bin 	\
	external/imx-firmware/BCM4339/TypeZP/BCM4339_wifi/nvram_ap6335.txt:system/etc/firmware/bcm/nvram_ap6335.txt 	\
	external/imx-firmware/BCM4330/bcm4330.hcd:system/etc/firmware/bcm/bcm4330.hcd 	\
	external/imx-firmware/BCM4330/fw_bcm4330_bg.bin:system/etc/firmware/bcm/fw_bcm4330_bg.bin 	\
	external/imx-firmware/BCM4330/fw_bcm4330_bg_apsta.bin:system/etc/firmware/bcm/fw_bcm4330_bg_apsta.bin \
	external/imx-firmware/BCM4330/brcmfmac4330-sdio.txt:system/etc/firmware/bcm/brcmfmac4330-sdio.txt

# ethernet files
PRODUCT_COPY_FILES += \
        device/fsl/pico_6dq/ethernet/eth_updown:system/bin/eth_updown \
        device/fsl/pico_6dq/ethernet/eth_flag:system/bin/eth_flag

DEVICE_PACKAGE_OVERLAYS := device/fsl/pico_7d/overlay

PRODUCT_CHARACTERISTICS := tablet

PRODUCT_AAPT_CONFIG += xlarge large tvdpi hdpi xhdpi

PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.audio.output.xml:system/etc/permissions/android.hardware.audio.output.xml \
	frameworks/native/data/etc/android.hardware.touchscreen.xml:system/etc/permissions/android.hardware.touchscreen.xml \
	frameworks/native/data/etc/android.hardware.touchscreen.multitouch.xml:system/etc/permissions/android.hardware.touchscreen.multitouch.xml \
	frameworks/native/data/etc/android.hardware.touchscreen.multitouch.distinct.xml:system/etc/permissions/android.hardware.touchscreen.multitouch.distinct.xml \
	frameworks/native/data/etc/android.hardware.screen.portrait.xml:system/etc/permissions/android.hardware.screen.portrait.xml \
	frameworks/native/data/etc/android.hardware.screen.landscape.xml:system/etc/permissions/android.hardware.screen.landscape.xml \
	frameworks/native/data/etc/android.software.app_widgets.xml:system/etc/permissions/android.software.app_widgets.xml \
	frameworks/native/data/etc/android.software.voice_recognizers.xml:system/etc/permissions/android.software.voice_recognizers.xml \
	frameworks/native/data/etc/android.software.backup.xml:system/etc/permissions/android.software.backup.xml \
	frameworks/native/data/etc/android.software.print.xml:system/etc/permissions/android.software.print.xml \
	frameworks/native/data/etc/android.software.device_admin.xml:system/etc/permissions/android.software.device_admin.xml \
	frameworks/native/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
	frameworks/native/data/etc/android.hardware.wifi.direct.xml:system/etc/permissions/android.hardware.wifi.direct.xml \
	frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml \
	frameworks/native/data/etc/android.hardware.usb.host.xml:system/etc/permissions/android.hardware.usb.host.xml \
	frameworks/native/data/etc/android.hardware.usb.accessory.xml:system/etc/permissions/android.hardware.usb.accessory.xml \
	frameworks/native/data/etc/android.hardware.camera.xml:system/etc/permissions/android.hardware.camera.xml \
	frameworks/native/data/etc/android.hardware.camera.front.xml:system/etc/permissions/android.hardware.camera.front.xml \
	frameworks/native/data/etc/android.hardware.ethernet.xml:system/etc/permissions/android.hardware.ethernet.xml \
	frameworks/native/data/etc/android.hardware.sensor.compass.xml:system/etc/permissions/android.hardware.sensor.compass.xml \
	frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:system/etc/permissions/android.hardware.sensor.accelerometer.xml \
	frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:system/etc/permissions/android.hardware.sensor.gyroscope.xml \
	frameworks/native/data/etc/android.hardware.sensor.ambient_temperature.xml:system/etc/permissions/android.hardware.sensor.ambient_temperature.xml \
	frameworks/native/data/etc/android.hardware.sensor.barometer.xml:system/etc/permissions/android.hardware.sensor.barometer.xml \
	frameworks/native/data/etc/android.hardware.bluetooth_le.xml:system/etc/permissions/android.hardware.bluetooth_le.xml \
        device/fsl/pico_7d/required_hardware.xml:system/etc/permissions/required_hardware.xml
PRODUCT_PACKAGES += AudioRoute \
                                       EDM_GPIO \
                                       EDM_UART \
                                       EDM_CANBUS \
                                       Reboot \
                                       AmazeFileManager
