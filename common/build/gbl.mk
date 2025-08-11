# Copyright 2025 NXP
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

include ${product_path}/BoardConfig.mk
include ${product_path}/${TARGET_PRODUCT}.mk

GBLSIGNTOOL := device/nxp/common/tools/gbl_signtool.py

IMX_BUILT_GBL_TARGET := $(PRODUCT_OUT)/efisp.img
IMX_PREBUILT_GBL_IMAGE := vendor/nxp-opensource/imx-gbl/gbl_aarch64.efi

define imx_build-gblimage-target
  @echo "Building the GBL image..."
  $(GBLSIGNTOOL) --key ${BOARD_GBL_KEY_PATH} --image ${IMX_PREBUILT_GBL_IMAGE} \
  --rollback_index_location $(BOARD_GBL_ROLLBACK_INDEX_LOCATION) --rollback_index $(BOARD_GBL_ROLLBACK_INDEX) \
  --partition_size $(BOARD_GBL_PARTITION_SIZE) --out $(IMX_BUILT_GBL_TARGET)
endef

gblimage: $(GBLSIGNTOOL) $(IMX_PREBUILT_GBL_IMAGE)
	$(hide)mkdir -p $(PRODUCT_OUT)
	$(imx_build-gblimage-target)

.PHONY: gblimage
