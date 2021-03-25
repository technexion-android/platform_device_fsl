# Copyright (C) 2018 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

TARGET_KERNEL_ARCH := $(strip $(TARGET_KERNEL_ARCH))
TARGET_KERNEL_SRC := $(KERNEL_IMX_PATH)/kernel_imx
KERNEL_AFLAGS ?=
KERNEL_CFLAGS ?=

ifeq ($(TARGET_KERNEL_ARCH), arm)
KERNEL_SRC_ARCH := arm
DTS_ADDITIONAL_PATH :=
else ifeq ($(TARGET_KERNEL_ARCH), arm64)
KERNEL_SRC_ARCH := arm64
DTS_ADDITIONAL_PATH := freescale
DTS_OVERLAY_PATH := freescale/overlays
else
$(error kernel arch not supported at present)
endif

MKDTIMG := $(HOST_OUT_EXECUTABLES)/mkdtimg
DTB_OUT_PATH := $(KERNEL_OUT)/arch/$(TARGET_KERNEL_ARCH)/boot/dts/$(DTS_ADDITIONAL_PATH)/

TARGET_DTB :=
$(foreach dts_config,$(TARGET_BOARD_DTS_CONFIG), \
	$(eval TARGET_DTB += $(addprefix $(DTB_OUT_PATH),$(shell echo ${dts_config} | cut -d':' -f2))))

$(BOARD_PREBUILT_DTBOIMAGE): $(KERNEL_BIN) $(TARGET_DTB) | $(MKDTIMG) $(AVBTOOL)
	$(hide) echo "Building $(KERNEL_ARCH) dtbo ..."
	for dtboplat in $(TARGET_BOARD_DTBO_CONFIG); do \
			DTBO_FILE=`echo $$dtboplat | cut -d':' -f2`; \
			DTBO_APPEND+=`echo "$(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/arch/$(TARGET_KERNEL_ARCH)/boot/dts/$(DTS_OVERLAY_PATH)/$${DTBO_FILE} "`; \
	done; \
	for dtsplat in $(TARGET_BOARD_DTS_CONFIG); do \
		DTS_PLATFORM=`echo $$dtsplat | cut -d':' -f1`; \
		DTB_NAME=`echo $$dtsplat | cut -d':' -f2`; \
		DTB=`echo $(KERNEL_OUT)/arch/$(TARGET_KERNEL_ARCH)/boot/dts/$(DTS_ADDITIONAL_PATH)/$${DTB_NAME}`; \
		DTBO_IMG=`echo $(PRODUCT_OUT)/dtbo-$${DTS_PLATFORM}.img`; \
		echo $$DTBO_APPEND; \
		$(MKDTIMG) create $$DTBO_IMG $$DTB $$DTBO_APPEND; \
		$(AVBTOOL) add_hash_footer --image $$DTBO_IMG  \
			--partition_name dtbo \
			--partition_size $(BOARD_DTBOIMG_PARTITION_SIZE); \
	done

.PHONY: dtboimage
dtboimage: $(BOARD_PREBUILT_DTBOIMAGE)

IMX_INSTALLED_VBMETAIMAGE_TARGET := $(PRODUCT_OUT)/vbmeta-$(shell echo $(word 1,$(TARGET_BOARD_DTS_CONFIG)) | cut -d':' -f1).img
$(IMX_INSTALLED_VBMETAIMAGE_TARGET): $(PRODUCT_OUT)/vbmeta.img $(BOARD_PREBUILT_DTBOIMAGE) | $(AVBTOOL)
	for dtsplat in $(TARGET_BOARD_DTS_CONFIG); do \
		DTS_PLATFORM=`echo $$dtsplat | cut -d':' -f1`; \
		DTBO_IMG=`echo $(PRODUCT_OUT)/dtbo-$${DTS_PLATFORM}.img`; \
		VBMETA_IMG=`echo $(PRODUCT_OUT)/vbmeta-$${DTS_PLATFORM}.img`; \
		RECOVERY_IMG=`echo $(PRODUCT_OUT)/recovery-$${DTS_PLATFORM}.img`; \
		$(if $(filter true, $(BOARD_USES_RECOVERY_AS_BOOT)), \
			$(AVBTOOL) make_vbmeta_image \
				--algorithm $(BOARD_AVB_ALGORITHM) --key $(BOARD_AVB_KEY_PATH)  \
				$(BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS) \
				--include_descriptors_from_image $(PRODUCT_OUT)/vbmeta.img \
				--include_descriptors_from_image $$DTBO_IMG \
				--output $$VBMETA_IMG, \
			$(AVBTOOL) make_vbmeta_image \
				--algorithm $(BOARD_AVB_ALGORITHM) --key $(BOARD_AVB_KEY_PATH) \
				$(BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS) \
				--include_descriptors_from_image $(PRODUCT_OUT)/vbmeta.img \
				--include_descriptors_from_image $$DTBO_IMG \
				--include_descriptors_from_image $$RECOVERY_IMG \
				--output $$VBMETA_IMG); \
	done
	cp $(IMX_INSTALLED_VBMETAIMAGE_TARGET) $(PRODUCT_OUT)/vbmeta.img

.PHONY: imx_vbmetaimage
imx_vbmetaimage: IMX_INSTALLED_RECOVERYIMAGE_TARGET $(IMX_INSTALLED_VBMETAIMAGE_TARGET)

droid: imx_vbmetaimage
otapackage: imx_vbmetaimage
target-files-package: imx_vbmetaimage

ifeq (true,$(BOARD_BUILD_SUPER_IMAGE_BY_DEFAULT))
otapackage: superimage_empty superimage
target-files-package: superimage_empty superimage
endif

otapackage: signapk
target-files-package: signapk

ifeq ($(TARGET_USE_VENDOR_BOOT), true)
INSTALLED_DTBIMAGE_TARGET := $(PRODUCT_OUT)/dtb.img
$(INSTALLED_DTBIMAGE_TARGET): $(KERNEL_BIN) $(TARGET_DTB)
	cp $(word 1,$(TARGET_DTB)) $(INSTALLED_DTBIMAGE_TARGET)
endif
