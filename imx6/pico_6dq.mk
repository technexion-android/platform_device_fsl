# This is a FSL Android Reference Design platform based on i.MX6Q ARD board
# It will inherit from FSL core product which in turn inherit from Google generic

$(call inherit-product, device/fsl/imx6/imx6.mk)
$(call inherit-product-if-exists,vendor/google/products/gms.mk)

ifneq ($(wildcard device/fsl/pico_6dq/fstab_nand.freescale),)
$(shell touch device/fsl/pico_6dq/fstab_nand.freescale)
endif

ifneq ($(wildcard device/fsl/pico_6dq/fstab.freescale),)
$(shell touch device/fsl/pico_6dq/fstab.freescale)
endif

# Overrides
PRODUCT_NAME := pico_6dq
PRODUCT_DEVICE := pico_6dq

LIBBT_VENDORFILE := device/fsl/wandboard/brcm-firmware/libbt_vnd_edm1cf.conf

PRODUCT_COPY_FILES += \
	device/fsl/pico_6dq/init.rc:root/init.freescale.rc \
        device/fsl/pico_6dq/init.i.MX6Q.rc:root/init.freescale.i.MX6Q.rc \
        device/fsl/pico_6dq/init.i.MX6DL.rc:root/init.freescale.i.MX6DL.rc \
	device/fsl/pico_6dq/init.i.MX6QP.rc:root/init.freescale.i.MX6QP.rc \
	device/fsl/pico_6dq/audio_policy.conf:system/etc/audio_policy.conf \
	device/fsl/pico_6dq/audio_effects.conf:system/vendor/etc/audio_effects.conf

PRODUCT_COPY_FILES +=	\
	external/linux-firmware-imx/firmware/vpu/vpu_fw_imx6d.bin:system/lib/firmware/vpu/vpu_fw_imx6d.bin 	\
	external/linux-firmware-imx/firmware/vpu/vpu_fw_imx6q.bin:system/lib/firmware/vpu/vpu_fw_imx6q.bin

# wifi+bt files
PRODUCT_COPY_FILES += \
	device/fsl/pico_6dq/bluetooth/bt_vendor.conf:system/etc/bluetooth/bt_vendor.conf \
	device/fsl/pico_6dq/bluetooth/bt_reset:system/bin/bt_reset \
	device/fsl/pico_6dq/bluetooth/bd_mac_gen:system/bin/bd_mac_gen \

# ethernet files
PRODUCT_COPY_FILES += \
	device/fsl/pico_6dq/ethernet/eth_updown:system/bin/eth_updown \
	device/fsl/pico_6dq/ethernet/eth_flag:system/bin/eth_flag


# touch files
PRODUCT_COPY_FILES += \
	device/fsl/common/input/eGalax_Touch_Screen.idc:system/usr/idc/fusion_Touch_Screen.idc \
	device/fsl/common/input/eGalax_Touch_Screen.idc:system/usr/idc/ADS7846_Touchscreen.idc


# GPU files

DEVICE_PACKAGE_OVERLAYS := device/fsl/pico_6dq/overlay

PRODUCT_CHARACTERISTICS := tablet

PRODUCT_AAPT_CONFIG += xlarge large tvdpi hdpi xhdpi

PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/tablet_core_hardware.xml:system/etc/permissions/tablet_core_hardware.xml \
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
	device/fsl/pico_6dq/required_hardware.xml:system/etc/permissions/required_hardware.xml
PRODUCT_PACKAGES += AudioRoute \
					EDM_GPIO \
					EDM_UART \
					EDM_CANBUS \
					Reboot \
					AmazeFileManager

# Broadcom firmwares
PRODUCT_PACKAGES += \
       Type_ZP.hcd     \
       bt_vendor.conf  \
       bcmdhd.cal              \
       fw_bcmdhd.bin   \
       fw_bcmdhd_apsta.bin

# Broadcom BCM4339 extended binary
PRODUCT_PACKAGES += \
    bcmdhd.SN8000.OOB.cal     \
    bcmdhd.SN8000.SDIO.cal    \
    sn_fw_bcmdhd_apsta.bin    \
    sn_fw_bcmdhd.bin          \
    sn_fw_bcmdhd_mfgtest.bin  \
    1bw_fw_bcmdhd.bin         \
    1bw_fw_bcmdhd_mfgtest.bin \
    BCM43341B0.1BW.hcd        \
    bcmdhd.1BW.OOB.cal        \
    bcmdhd.1BW.SDIO.cal       \
    1dx_fw_bcmdhd.bin         \
    1dx_fw_bcmdhd_mfgtest.bin \
    BCM43430A1.1DX.hcd        \
    bcmdhd.1DX.OOB.cal        \
    bcmdhd.1DX.SDIO.cal       \
    wl
