# This is a FSL Android Reference Design platform based on i.MX6Q ARD board
# It will inherit from FSL core product which in turn inherit from Google generic

$(call inherit-product, device/fsl/imx6/imx6.mk)
$(call inherit-product-if-exists,vendor/google/products/gms.mk)

ifneq ($(wildcard device/fsl/tep5_6dq/fstab_nand.freescale),)
$(shell touch device/fsl/tep5_6dq/fstab_nand.freescale)
endif

ifneq ($(wildcard device/fsl/tep5_6dq/fstab.freescale),)
$(shell touch device/fsl/tep5_6dq/fstab.freescale)
endif

# Overrides
PRODUCT_NAME := tep5_6dq
PRODUCT_DEVICE := tep5_6dq

PRODUCT_COPY_FILES += \
        device/fsl/tep5_6dq/init.rc:root/init.freescale.rc \
        device/fsl/tep5_6dq/init.i.MX6Q.rc:root/init.freescale.i.MX6Q.rc \
        device/fsl/tep5_6dq/init.i.MX6DL.rc:root/init.freescale.i.MX6DL.rc \
        device/fsl/tep5_6dq/init.i.MX6QP.rc:root/init.freescale.i.MX6QP.rc

# Audio
USE_XML_AUDIO_POLICY_CONF := 1
PRODUCT_COPY_FILES += \
	device/fsl/tep5_6dq/audio_effects.conf:system/vendor/etc/audio_effects.conf \
	device/fsl/tep5_6dq/audio_policy_configuration.xml:system/etc/audio_policy_configuration.xml \
	frameworks/av/services/audiopolicy/config/a2dp_audio_policy_configuration.xml:system/etc/a2dp_audio_policy_configuration.xml \
	frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:system/etc/r_submix_audio_policy_configuration.xml \
	frameworks/av/services/audiopolicy/config/usb_audio_policy_configuration.xml:system/etc/usb_audio_policy_configuration.xml \
	frameworks/av/services/audiopolicy/config/default_volume_tables.xml:system/etc/default_volume_tables.xml \
	frameworks/av/services/audiopolicy/config/audio_policy_volumes.xml:system/etc/audio_policy_volumes.xml

PRODUCT_COPY_FILES +=	\
	external/linux-firmware-imx/firmware/vpu/vpu_fw_imx6d.bin:system/lib/firmware/vpu/vpu_fw_imx6d.bin 	\
	external/linux-firmware-imx/firmware/vpu/vpu_fw_imx6q.bin:system/lib/firmware/vpu/vpu_fw_imx6q.bin

# wifi+bt files
#	device/fsl/tep5_6dq/bluetooth/bt_vendor.conf:system/etc/bluetooth/bt_vendor.conf \
PRODUCT_COPY_FILES += \
	device/fsl/tep5_6dq/bluetooth/bt_reset:system/bin/bt_reset \
	device/fsl/tep5_6dq/bluetooth/bd_mac_gen:system/bin/bd_mac_gen


# ethernet files
PRODUCT_COPY_FILES += \
	device/fsl/tep5_6dq/ethernet/eth_updown:system/bin/eth_updown \
	device/fsl/tep5_6dq/ethernet/eth_flag:system/bin/eth_flag

# touch files
PRODUCT_COPY_FILES += \
	device/fsl/common/input/eGalax_Touch_Screen.idc:system/usr/idc/fusion_Touch_Screen.idc \
	device/fsl/common/input/eGalax_Touch_Screen.idc:system/usr/idc/ADS7846_Touchscreen.idc

# busybox login files
PRODUCT_COPY_FILES += \
        device/fsl/tep5_6dq/bin/login:system/bin/login \
        device/fsl/tep5_6dq/bin/busybox:system/bin/busybox \
        device/fsl/tep5_6dq/bin/Technexion.sh:/system/bin/Technexion.sh

# setup dm-verity configs.
ifneq ($(BUILD_TARGET_DEVICE),sd)
 PRODUCT_SYSTEM_VERITY_PARTITION := /dev/block/mmcblk3p5
 $(call inherit-product, build/target/product/verity.mk)
else 
 PRODUCT_SYSTEM_VERITY_PARTITION := /dev/block/mmcblk2p5
 $(call inherit-product, build/target/product/verity.mk)

endif

# GPU files

DEVICE_PACKAGE_OVERLAYS := device/fsl/tep5_6dq/overlay

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
	device/fsl/tep5_6dq/required_hardware.xml:system/etc/permissions/required_hardware.xml

PRODUCT_COPY_FILES += \
	device/fsl/tep5_6dq/brcm-firmware/bcm43438a0.hcd:system/etc/firmware/bcm/bcm43438a0.hcd 	\
	device/fsl/tep5_6dq/brcm-firmware/fw_bcm43438a0.bin:system/etc/firmware/bcm/fw_bcm43438a0.bin 	\
	device/fsl/tep5_6dq/brcm-firmware/fw_bcm43438a0_apsta.bin:system/etc/firmware/bcm/fw_bcm43438a0_apsta.bin 	\
	device/fsl/tep5_6dq/brcm-firmware/fw_bcm43438a0_p2p.bin:system/etc/firmware/bcm/fw_bcm43438a0_p2p.bin 	\
	device/fsl/tep5_6dq/brcm-firmware/nvram_ap6212.txt:system/etc/firmware/bcm/nvram_ap6212.txt 	\
	external/imx-firmware/BCM4339/TypeZP/BCM4339_BT/Type_ZP.hcd:system/etc/firmware/bcm/Type_ZP.hcd 	\
	external/imx-firmware/BCM4339/TypeZP/BCM4339_wifi/fw_bcmdhd.bin:system/etc/firmware/bcm/fw_bcm4339a0_ag.bin 	\
	external/imx-firmware/BCM4339/TypeZP/BCM4339_wifi/fw_bcmdhd.bin:system/etc/firmware/bcm/fw_bcm4339a0_ag_apsta.bin 	\
	external/imx-firmware/BCM4339/TypeZP/BCM4339_wifi/nvram_ap6335.txt:system/etc/firmware/bcm/nvram_ap6335.txt 	\
	external/imx-firmware/BCM4330/bcm4330.hcd:system/etc/firmware/bcm/bcm4330.hcd 	\
	external/imx-firmware/BCM4330/fw_bcm4330_bg.bin:system/etc/firmware/bcm/fw_bcm4330_bg.bin 	\
	external/imx-firmware/BCM4330/fw_bcm4330_bg_apsta.bin:system/etc/firmware/bcm/fw_bcm4330_bg_apsta.bin \
	external/imx-firmware/BCM4330/brcmfmac4330-sdio.txt:system/etc/firmware/bcm/brcmfmac4330-sdio.txt

PRODUCT_COPY_FILES += \
    device/fsl-proprietary/gpu-viv/lib/egl/egl.cfg:system/lib/egl/egl.cfg

PRODUCT_PACKAGES += \
    libEGL_VIVANTE \
    libGLESv1_CM_VIVANTE \
    libGLESv2_VIVANTE \
    gralloc_viv.imx6 \
    hwcomposer_viv.imx6 \
    hwcomposer_fsl.imx6 \
    libGAL \
    libGLSLC \
    libVSC \
    libg2d \
    libgpuhelper

PRODUCT_PACKAGES += \
	AudioRoute \
    EDM_GPIO \
    EDM_UART \
    EDM_CANBUS \
    Reboot \
    busybox \
    AmazeFileManager \
    Chromium \
	BluetoothLeGatt
