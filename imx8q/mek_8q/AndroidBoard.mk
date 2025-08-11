LOCAL_PATH := $(call my-dir)

include $(CONFIG_REPO_PATH)/common/build/dtbo.mk
include $(CONFIG_REPO_PATH)/common/build/imx-recovery.mk
include $(FSL_PROPRIETARY_PATH)/fsl-proprietary/media-profile/media-profile.mk

ifneq ($(BOARD_OTA_BOOTLOADERIMAGE),)
  INSTALLED_RADIOIMAGE_TARGET += $(PRODUCT_OUT)/bootloader.img
  BOARD_PACK_RADIOIMAGES += bootloader.img
endif

# uncomment below to enable gbl OTA
#BOARD_PACK_RADIOIMAGES += efisp.img
#INSTALLED_RADIOIMAGE_TARGET  += $(PRODUCT_OUT)/efisp.img

-include $(IMX_MEDIA_CODEC_XML_PATH)/mediacodec-profile/mediacodec-profile.mk
