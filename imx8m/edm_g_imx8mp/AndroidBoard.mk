LOCAL_PATH := $(call my-dir)

include $(CONFIG_REPO_PATH)/common/build/dtbo.mk
include $(CONFIG_REPO_PATH)/common/build/imx-recovery.mk
#TODO add imx8mp target
include $(IMX_DEVICE_PATH)/media-profile.mk
-include $(IMX_MEDIA_CODEC_XML_PATH)/mediacodec-profile/mediacodec-profile.mk

# uncomment below to enable gbl OTA
#BOARD_PACK_RADIOIMAGES += efisp.img
#INSTALLED_RADIOIMAGE_TARGET  += $(PRODUCT_OUT)/efisp.img
