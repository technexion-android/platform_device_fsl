#
# Copyright 2015 The Android Open Source Project
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
#

# Targets for builing kernels
#
# The following must be set before including this file:
# KERNEL_IMX_PATH must be set the base of a kernel tree.
# TARGET_KERNEL_DEFCONFIG must name a base kernel config.
# TARGET_KERNEL_ARCH must be set to match kernel arch.
#
# The following maybe set:
# TARGET_KERNEL_CONFIGS to specify a set of additional kernel config files.
# ENABLE_GCC_BUILD which enbale external gcc compiler

# Brillo does not support prebuilt kernels.
ifneq ($(TARGET_PREBUILT_KERNEL),)
$(error TARGET_PREBUILT_KERNEL defined but Brillo kernels build from source)
endif


ifeq ($(KERNEL_IMX_PATH),)
$(error KERNEL_IMX_PATH not defined)
endif

ifeq ($(TARGET_KERNEL_DEFCONFIG),)
$(error TARGET_KERNEL_DEFCONFIG not defined)
endif

ifeq ($(TARGET_KERNEL_ARCH),)
$(error TARGET_KERNEL_ARCH not defined)
endif

# Check target arch.
# ENABLE_GCC_BUILD := true
TARGET_KERNEL_ARCH := $(strip $(TARGET_KERNEL_ARCH))
KERNEL_ARCH := $(TARGET_KERNEL_ARCH)
KERNEL_CC_WRAPPER := $(CC_WRAPPER)
KERNEL_AFLAGS :=
TARGET_KERNEL_SRC := $(KERNEL_IMX_PATH)/kernel_imx

CLANG_TO_COMPILE := LLVM=1

# Define the path for kernel prebuilts
#KERNEL_PREBUILTS_PATH := /opt/android-kernel-prebuilts-6.12

ifeq (,$(wildcard $(KERNEL_PREBUILTS_PATH)))
$(error Error: kenrel build tool path KERNEL_PREBUILTS_PATH $(KERNEL_PREBUILTS_PATH) does not exist. Please follow user guide doc to set correct KERNEL_PREBUILTS_PATH)
endif

# Define paths for kernel build tools
KERNEL_BUILD_TOOLS_BIN := $(KERNEL_PREBUILTS_PATH)/kernel-build-tools/linux-x86/bin

ifeq (,$(wildcard $(KERNEL_BUILD_TOOLS_BIN)))
$(error Error: kenrel build tools KERNEL_BUILD_TOOLS_BIN $(KERNEL_BUILD_TOOLS_BIN) does not exist.)
endif

# Define paths for kernel build tools libraries
KERNEL_BUILD_TOOLS_LIB64_PATH := $(KERNEL_PREBUILTS_PATH)/kernel-build-tools/linux-x86/lib64

ifeq (,$(wildcard $(KERNEL_BUILD_TOOLS_LIB64_PATH)))
$(error Error: kenrel build tools lib64 path KERNEL_BUILD_TOOLS_LIB64_PATH $(KERNEL_BUILD_TOOLS_LIB64_PATH) does not exist.)
endif

# Define Rust toolchain path
RUST_BIN := $(KERNEL_PREBUILTS_PATH)/rust/linux-x86/1.82.0/bin

ifeq (,$(wildcard $(RUST_BIN)))
$(error Error: rust tools RUST_BIN $(RUST_BIN) does not exist.)
endif

# Define Clang tools path
CLANG_TOOLS_BIN := $(KERNEL_PREBUILTS_PATH)/clang-tools/linux-x86/bin

ifeq (,$(wildcard $(CLANG_TOOLS_BIN)))
$(error Error: clang tools CLANG_TOOLS_BIN $(CLANG_TOOLS_BIN) does not exist.)
endif

# Define clang path
CLANG_PATH := $(KERNEL_PREBUILTS_PATH)/clang/host/linux-x86

ifeq (,$(wildcard $(CLANG_PATH)))
$(error Error: CLANG_PATH $(CLANG_PATH) does not exist.)
endif

# This clang version need align with $(kernel_source)/build.config.common
CLANG_BIN := $(CLANG_PATH)/clang-r536225/bin

ifeq (,$(wildcard $(CLANG_BIN)))
$(error CLANG_BIN:$(CLANG_BIN) does not exist. Please update clang to latest version: \
cd $(CLANG_PATH); sudo git remote update; sudo git checkout origin/master )
endif

# Define the path for Clang libraries
LIBCLANG_PATH := $(CLANG_PATH)/clang-r536225/lib

ifeq (,$(wildcard $(LIBCLANG_PATH)))
$(error Error: LIBCLANG_PATH $(LIBCLANG_PATH) does not exist.)
endif

# Set include path and linker path for kernel build tools
KERNEL_HOSTCFLAGS += "-I$(KERNEL_PREBUILTS_PATH)/kernel-build-tools/linux-x86/include"
KERNEL_HOSTLDFLAGS += "-L$(KERNEL_PREBUILTS_PATH)/kernel-build-tools/linux-x86/lib64"

ifeq ($(TARGET_KERNEL_ARCH), arm)
KERNEL_CFLAGS :=
CLANG_TRIPLE := CLANG_TRIPLE=arm-linux-gnueabi-
KERNEL_SRC_ARCH := arm
KERNEL_NAME := zImage
else ifeq ($(TARGET_KERNEL_ARCH), arm64)
CLANG_TRIPLE := CLANG_TRIPLE=aarch64-linux-gnu-
KERNEL_SRC_ARCH := arm64
KERNEL_CFLAGS :=
KERNEL_NAME ?= Image.gz
else
$(error kernel arch not supported at present)
endif

ifeq ($(ENABLE_GCC_BUILD), true)
CLANG_TRIPLE :=
CLANG_TO_COMPILE :=
CLANG_BIN :=
# prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-androidkernel-gcc have been remove in android11
# android do not support internal gcc in android11 anymore, export external gcc for imx device. you can asign one local gcc here.
ifeq ($(TARGET_KERNEL_ARCH), arm)
KERNEL_TOOLCHAIN_ABS := /opt/fsl-imx-internal-xwayland/5.4-zeus/sysroots/x86_64-pokysdk-linux/usr/bin/arm-poky-linux-gnueabi
KERNEL_CROSS_COMPILE := $(KERNEL_TOOLCHAIN_ABS)/arm-poky-linux-gnueabi-
else ifeq ($(TARGET_KERNEL_ARCH), arm64)
KERNEL_TOOLCHAIN_ABS := /opt/fsl-imx-internal-xwayland/5.4-zeus/sysroots/x86_64-pokysdk-linux/usr/bin/aarch64-poky-linux
KERNEL_CROSS_COMPILE := $(KERNEL_TOOLCHAIN_ABS)/aarch64-poky-linux-
endif
endif

# Use ccache if requested by USE_CCACHE variable
KERNEL_CROSS_COMPILE_WRAPPER := $(realpath $(KERNEL_CC_WRAPPER)) $(KERNEL_CROSS_COMPILE)

ifeq ($(CLANG_TO_COMPILE),)
KERNEL_GCC_NOANDROID_CHK := $(shell (echo "int main() {return 0;}" | $(KERNEL_CROSS_COMPILE)gcc -E -mno-android - > /dev/null 2>&1 ; echo $$?))
else
KERNEL_GCC_NOANDROID_CHK := $(shell (echo "int main() {return 0;}" | $(CLANG_BIN)clang --target=$(CLANG_TRIPLE:%-=%) \
  -E -mno-android - > /dev/null 2>&1 ; echo $$?))
endif

ifeq ($(strip $(KERNEL_GCC_NOANDROID_CHK)),0)
KERNEL_CFLAGS += -mno-android
KERNEL_AFLAGS += -mno-android
endif

# options are used to eliminate compilation errors with qca wifi driver when use clang
ifneq ($(CLANG_TO_COMPILE),)
KERNEL_CFLAGS := -Wno-incompatible-pointer-types
endif

# Set the output for the kernel build products.
KERNEL_BIN := $(KERNEL_OUT)/arch/$(KERNEL_SRC_ARCH)/boot/$(KERNEL_NAME)

# Figure out which kernel version is being built (disregard -stable version).
KERNEL_VERSION := $(shell PATH=$$PATH $(MAKE) --no-print-directory -C $(TARGET_KERNEL_SRC) -s SUBLEVEL="" kernelversion)

# Kernel config file sources.
KERNEL_CONFIG_DEFAULT := $(realpath $(TARGET_KERNEL_SRC)/arch/$(KERNEL_SRC_ARCH)/configs/$(TARGET_KERNEL_DEFCONFIG))
ifneq ($(TARGET_KERNEL_ADDITION_DEFCONF),)
KERNEL_CONFIG_ADDITION := $(TARGET_DEVICE_DIR)/$(TARGET_KERNEL_ADDITION_DEFCONF)
else
KERNEL_CONFIG_ADDITION :=
endif

ifneq ($(TARGET_KERNEL_GKI_DEFCONF),)
KERNEL_CONFIG_GKI := $(realpath $(TARGET_KERNEL_SRC)/arch/$(KERNEL_SRC_ARCH)/configs/$(TARGET_KERNEL_GKI_DEFCONF))
else
KERNEL_CONFIG_GKI :=
endif

KERNEL_CONFIG_SRC := $(KERNEL_CONFIG_DEFAULT) \
  $(KERNEL_CONFIG_ADDITION) \
  $(KERNEL_CONFIG_GKI)

KERNEL_CONFIG := $(KERNEL_OUT)/.config
KERNEL_MERGE_CONFIG := $(realpath device/nxp/common/tools/merge_config.sh)

KERNEL_HEADERS_INSTALL := $(KERNEL_OUT)/usr
#KERNEL_MODULES_INSTALL := $(TARGET_OUT)/lib/modules
KERNEL_MODULES_INSTALL := $(BOARD_VENDOR_KERNEL_MODULES)

$(KERNEL_OUT):
	mkdir -p $@

KERNEL_FIRMWARE_DIR_CONFIG := $(KERNEL_OUT)/firmware.kconf

$(KERNEL_FIRMWARE_DIR_CONFIG):
	$(hide) echo CONFIG_EXTRA_FIRMWARE_DIR="\"$(TARGET_KERNEL_EXTRA_FIRMWARE_DIR)\"" > $@

ifdef TARGET_KERNEL_EXTRA_FIRMWARE_DIR
KERNEL_CONFIG_SRC += $(KERNEL_FIRMWARE_DIR_CONFIG)
endif

# Merge the required kernel config elements into a single file.
$(KERNEL_CONFIG_REQUIRED): $(KERNEL_CONFIG_REQUIRED_SRC) | $(KERNEL_OUT)
	$(hide) cat $^ > $@

# use deferred expansion
kernel_build_shell_env = KBUILD_GENDWARFKSYMS_STABLE=1 KBUILD_SYMTYPES=1 PATH=$(CLANG_BIN):$(KERNEL_BUILD_TOOLS_BIN):$(RUST_BIN):$(CLANG_TOOLS_BIN):$(realpath prebuilts/misc/linux-x86/lz4):$${PATH} \
        $(CLANG_TRIPLE) LIBCLANG_PATH="$(LIBCLANG_PATH)" CCACHE_NODIRECT="true" HOSTCFLAGS="$(KERNEL_HOSTCFLAGS)" HOSTLDFLAGS="$(KERNEL_HOSTLDFLAGS)"\
        LD_LIBRARY_PATH=$(KERNEL_BUILD_TOOLS_LIB64_PATH):$${LD_LIBRARY_PATH}
ifeq ($(CLANG_TO_COMPILE),)
kernel_build_common_env = ARCH=$(KERNEL_ARCH) CROSS_COMPILE=$(strip $(KERNEL_CROSS_COMPILE_WRAPPER)) \
        KCFLAGS="$(KERNEL_CFLAGS)" KAFLAGS="$(KERNEL_AFLAGS)"
else
kernel_build_common_env = ARCH=$(KERNEL_ARCH) \
        KCFLAGS="$(KERNEL_CFLAGS)" KAFLAGS="$(KERNEL_AFLAGS)"
endif
kernel_build_make_env = $(kernel_build_common_env) $(CLANG_TO_COMPILE) -C $(TARGET_KERNEL_SRC) O=$(realpath $(KERNEL_OUT))
merge_config_env = $(kernel_build_shell_env) $(kernel_build_common_env)
merge_config_params = -p "$(CLANG_TO_COMPILE)" -O $(realpath $(KERNEL_OUT)) $(KERNEL_CONFIG_SRC)

# Merge the final target kernel config.
$(KERNEL_CONFIG): $(KERNEL_CONFIG_SRC) $(TARGET_KERNEL_SRC) | $(KERNEL_OUT)
	$(hide) if [ "${skip_config_or_clean}" != "1" ]; then \
		if [ "${clean_build}" = "1" ]; then \
			PATH=$$PATH $(MAKE) -C $(TARGET_KERNEL_SRC) O=$(realpath $(KERNEL_OUT)) clean; \
		fi; \
		echo Merging KERNEL config srcs: $(KERNEL_CONFIG_SRC); \
		rm -f $(KERNEL_CONFIG); \
		cd $(TARGET_KERNEL_SRC) && $(merge_config_env) $(KERNEL_MERGE_CONFIG) $(merge_config_params); \
	fi

$(KERNEL_BIN): $(KERNEL_CONFIG) $(TARGET_KERNEL_SRC) | $(KERNEL_OUT)
	$(hide) echo "Building $(KERNEL_ARCH) $(KERNEL_VERSION) kernel ..."
	$(hide) $(kernel_build_shell_env) $(MAKE) $(kernel_build_make_env) syncconfig
	$(hide) $(kernel_build_shell_env) $(MAKE) $(kernel_build_make_env) $(KERNEL_NAME)

.PHONY: KERNEL_MODULES KERNEL_DTB

KERNEL_MODULES: $(KERNEL_CONFIG) $(TARGET_KERNEL_SRC) | $(KERNEL_OUT)
	$(hide) echo "Building $(KERNEL_ARCH) $(KERNEL_VERSION) kernel modules ..."
	$(hide) $(kernel_build_shell_env) $(MAKE) $(kernel_build_make_env) syncconfig
	$(hide) $(kernel_build_shell_env) $(MAKE) $(kernel_build_make_env) modules

KERNEL_DTB: $(KERNEL_CONFIG) $(TARGET_KERNEL_SRC) | $(KERNEL_OUT)
	$(hide) echo "Building $(KERNEL_ARCH) $(KERNEL_VERSION) device trees ..."
	$(hide) $(kernel_build_shell_env) $(MAKE) $(kernel_build_make_env) syncconfig
	$(hide) $(kernel_build_shell_env) $(MAKE) $(kernel_build_make_env) dtbs

$(KERNEL_OUT)/vmlinux: $(KERNEL_BIN)
	@true

$(KERNEL_MODULES_INSTALL): $(KERNEL_BIN)
	$(hide) echo "Installing kernel modules ..."

$(KERNEL_HEADERS_INSTALL): $(KERNEL_BIN)
	$(hide) echo "Installing kernel headers ..."
	$(hide) $(kernel_build_shell_env) $(MAKE) $(kernel_build_make_env) headers_install

# If the kernel generates VDSO files, generate breakpad symbol files for them.
# VDSO libraries are mapped as linux-gate.so, so rename the symbol file to
# match as well as the filename in the first line of the .sym file.
$(KERNEL_BIN).vdso: $(KERNEL_BIN) $(BREAKPAD_DUMP_SYMS)
ifeq ($(BREAKPAD_GENERATE_SYMBOLS),true)
	$(hide) echo "BREAKPAD: Generating kernel VDSO symbol files."
	$(hide) set -e; \
	for sofile in `cd $(KERNEL_OUT) && find . -type f -name '*.so'`; do \
		mkdir -p $(TARGET_OUT_BREAKPAD)/kernel/$${sofile}; \
		$(BREAKPAD_DUMP_SYMS) -c $(KERNEL_OUT)/$${sofile} > $(TARGET_OUT_BREAKPAD)/kernel/$${sofile}/linux-gate.so.sym; \
		sed -i.tmp "1s/`basename "$${sofile}"`/linux-gate.so/" $(TARGET_OUT_BREAKPAD)/kernel/$${sofile}/linux-gate.so.sym; \
		rm $(TARGET_OUT_BREAKPAD)/kernel/$${sofile}/linux-gate.so.sym.tmp; \
	done
endif

# The list of dependencies for the final kernel.
KERNEL_DEPS := $(KERNEL_BIN).vdso $(KERNEL_HEADERS_INSTALL) $(KERNEL_MODULES_INSTALL)
KERNEL_IMAGE := $(KERNEL_BIN)

# Indicate use vivante drm based egl and gralloc
BOARD_GPU_DRIVERS := vivante

$(PRODUCT_OUT)/kernel: $(KERNEL_IMAGE) $(KERNEL_DEPS)
	$(hide)cp -fp $< $@
