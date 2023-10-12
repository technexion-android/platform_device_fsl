#LOCAL_PATH := $(call my-dir)
LOCAL_PATH := $(VENDOR_MULTIMEDIA_PATH)


ifeq ($(BOARD_HAVE_VPU), true)
ifeq ($(BOARD_SOC_TYPE),IMX8MP)

#for video recoder profile setting
include $(CLEAR_VARS)

LOCAL_SRC_FILES := media_profiles_8mp-1080p_30fps.xml
#LOCAL_SRC_FILES :=  $(FSL_PROPRIETARY_PATH)/fsl-proprietary/media_profiles_8mm.xml
LOCAL_MODULE := media_profiles_V1_0.xml
LOCAL_MODULE_CLASS := ETC
LOCAL_VENDOR_MODULE := true
include $(BUILD_PREBUILT)

endif
endif
