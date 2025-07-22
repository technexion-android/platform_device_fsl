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

ifdef BOARD_BPT_INPUT_FILES

BPTTOOL := device/nxp/common/tools/bpttool

IMX_BUILT_BPTIMAGE_TARGET := $(PRODUCT_OUT)/partition-table.img
IMX_BUILT_BPTJSON_TARGET := $(PRODUCT_OUT)/partition-table.bpt

IMX_INTERNAL_BVBTOOL_MAKE_TABLE_ARGS := \
	--output_gpt $(IMX_BUILT_BPTIMAGE_TARGET) \
	--output_json $(IMX_BUILT_BPTJSON_TARGET) \
	$(foreach file, $(BOARD_BPT_INPUT_FILES), --input $(file))

ifdef BOARD_BPT_DISK_SIZE
IMX_INTERNAL_BVBTOOL_MAKE_TABLE_ARGS += --disk_size $(BOARD_BPT_DISK_SIZE)
endif

define imx_build-bptimage-target
  @echo "Target partition table image: $(IMX_BUILT_BPTIMAGE_TARGET)"
  $(hide) $(BPTTOOL) make_table $(IMX_INTERNAL_BVBTOOL_MAKE_TABLE_ARGS) $(BOARD_BPT_MAKE_TABLE_ARGS)
  for addition_partition in $(ADDITION_BPT_PARTITION); do \
    PARTITION_OUT_IMAGE=`echo $$addition_partition | cut -d":" -f1`; \
    PARTITION_INPUT_BPT=`echo $$addition_partition | cut -d":" -f2`; \
    $(BPTTOOL) make_table --output_gpt $(PRODUCT_OUT)/$$PARTITION_OUT_IMAGE.img \
    --output_json $(PRODUCT_OUT)/$$PARTITION_OUT_IMAGE.bpt --input $$PARTITION_INPUT_BPT \
    $(BOARD_BPT_MAKE_TABLE_ARGS); \
   done
endef

partition_imgs: $(BPTTOOL) $(BOARD_BPT_INPUT_FILES)
	$(hide)mkdir -p $(PRODUCT_OUT)
	$(imx_build-bptimage-target)

.PHONY: partition_imgs

endif # BOARD_BPT_INPUT_FILES
