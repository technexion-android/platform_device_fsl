QCACLD_PATH ?= $(ANDROID_BUILD_TOP)/vendor/nxp-opensource/qcacld-2.0
QCACLD_OUT  ?= $(TARGET_OUT_INTERMEDIATES)/QCACLD_OBJ
CROSS_COMPILE := aarch64-linux-gnu-
KERNEL_CFLAGS += -Wno-error

qcacld_build_make_env = KERNEL_SRC=$(KERNEL_OUT) ARCH=$(KERNEL_ARCH) \
	CROSS_COMPILE=$(CROSS_COMPILE) $(CLANG_TO_COMPILE) KCFLAGS="$(KERNEL_CFLAGS)" \
	CONFIG_FORCE_MLO_SUPPORT=y \
	CONFIG_HDD_WLAN_START_WAIT_TIME=4000 \
	CONFIG_CLD_HL_SDIO_CORE=y \
	TARGET_BUILD_VARIANT=user \
	CONFIG_P2P_INTERFACE=y

qcacld: $(QCACLD_PATH)
	mkdir -p $(QCACLD_OUT)
	$(hide) if [ ${clean_build} = 1 ]; then \
		rm -fv $(QCACLD_PATH)/wlan.ko $(QCACLD_OUT)/wlan.ko ; \
		$(kernel_build_shell_env) $(MAKE) -C $(QCACLD_PATH) $(qcacld_build_make_env) clean ; \
	fi

#   workaround : fix build fail with needed stdarg.h on android 14
	cp -v $(ANDROID_BUILD_TOP)/$(KERNEL_IMX_PATH)/kernel_imx/include/linux/stdarg.h $(QCACLD_PATH)/CORE/VOSS/inc/ ; \

	$(kernel_build_shell_env) $(MAKE) -C $(QCACLD_PATH) $(qcacld_build_make_env) ; \
	$(kernel_build_shell_env) llvm-strip --strip-debug \
		$(QCACLD_PATH)/wlan.ko -o $(QCACLD_OUT)/wlan.ko
#	cp $(QCACLD_PATH)/wlan.ko $(QCACLD_OUT);