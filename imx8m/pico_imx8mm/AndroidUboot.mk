# uboot.imx in android combine scfw.bin and uboot.bin
MAKE += SHELL=/bin/bash

ifneq ($(AARCH64_GCC_CROSS_COMPILE),)
  ATF_CROSS_COMPILE := $(strip $(AARCH64_GCC_CROSS_COMPILE))
else
  $(error shell env AARCH64_GCC_CROSS_COMPILE is not set)
endif

define build_imx_uboot
	$(hide) echo Building i.MX U-Boot with firmware; \
	cp $(UBOOT_OUT)/u-boot-nodtb.$(strip $(1)) $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/.; \
	cp $(UBOOT_OUT)/spl/u-boot-spl.bin  $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/.; \
	cp $(UBOOT_OUT)/tools/mkimage  $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/mkimage_uboot; \
	if [ `echo $(2) | cut -d '-' -f2` = "ddr4" ]; then \
		cp $(UBOOT_OUT)/arch/arm/dts/imx8mm-ddr4-evk.dtb $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/.; \
		cp $(FSL_PROPRIETARY_PATH)/linux-firmware-imx/firmware/ddr/synopsys/ddr4* $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/.; \
	else \
		cp $(UBOOT_OUT)/arch/arm/dts/imx8mm-evk.dtb  $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/.; \
		cp $(FSL_PROPRIETARY_PATH)/linux-firmware-imx/firmware/ddr/synopsys/lpddr4_pmu_train* $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/.; \
	fi; \
	$(MAKE) -C $(IMX_PATH)/arm-trusted-firmware/ PLAT=`echo $(2) | cut -d '-' -f1` clean; \
	if [ `echo $(2) | cut -d '-' -f2` = "trusty" ] && [ `echo $(2) | rev | cut -d '-' -f1` != "uuu" ]; then \
		cp $(FSL_PROPRIETARY_PATH)/fsl-proprietary/uboot-firmware/imx8m/tee-imx8mm.bin $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/tee.bin; \
		if [ `echo $(2) | cut -d '-' -f3` = "4g" ]; then \
			$(MAKE) -C $(IMX_PATH)/arm-trusted-firmware/ CROSS_COMPILE="$(ATF_CROSS_COMPILE)" PLAT=`echo $(2) | cut -d '-' -f1` bl31 -B BL32_BASE=0xfe000000 SPD=trusty 1>/dev/null || exit 1; \
		else \
			$(MAKE) -C $(IMX_PATH)/arm-trusted-firmware/ CROSS_COMPILE="$(ATF_CROSS_COMPILE)" PLAT=`echo $(2) | cut -d '-' -f1` bl31 -B SPD=trusty 1>/dev/null || exit 1; \
		fi; \
	else \
		if [ -f $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/tee.bin ] ; then \
			rm -rf $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/tee.bin; \
		fi; \
		$(MAKE) -C $(IMX_PATH)/arm-trusted-firmware/ CROSS_COMPILE="$(ATF_CROSS_COMPILE)" PLAT=`echo $(2) | cut -d '-' -f1` bl31 -B 1>/dev/null || exit 1; \
	fi; \
	cp $(IMX_PATH)/arm-trusted-firmware/build/`echo $(2) | cut -d '-' -f1`/release/bl31.bin $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/bl31.bin; \
	$(MAKE) -C $(IMX_MKIMAGE_PATH)/imx-mkimage/ clean; \
	if [ `echo $(2) | cut -d '-' -f2` = "ddr4" ]; then \
		$(MAKE) -C $(IMX_MKIMAGE_PATH)/imx-mkimage/ SOC=iMX8MM  flash_ddr4_evk || exit 1; \
		$(MAKE) -C $(IMX_MKIMAGE_PATH)/imx-mkimage/ SOC=iMX8MM print_fit_hab_ddr4 || exit 1; \
	elif [ `echo $(2) | cut -d '-' -f2` = "4g" ] || [ `echo $(2) | cut -d '-' -f3` = "4g" ] || [ `echo $(2) | rev | cut -d '-' -f1` = "uuu" ]; then \
		$(MAKE) -C $(IMX_MKIMAGE_PATH)/imx-mkimage/ SOC=iMX8MM TEE_LOAD_ADDR=0xfe000000 flash_spl_uboot || exit 1; \
		$(MAKE) -C $(IMX_MKIMAGE_PATH)/imx-mkimage/ SOC=iMX8MM print_fit_hab || exit 1; \
	elif [ `echo $(2) | rev | cut -d '-' -f1 | rev` != "dual" ]; then \
		$(MAKE) -C $(IMX_MKIMAGE_PATH)/imx-mkimage/ SOC=iMX8MM flash_spl_uboot || exit 1; \
		$(MAKE) -C $(IMX_MKIMAGE_PATH)/imx-mkimage/ SOC=iMX8MM print_fit_hab || exit 1; \
	else \
		$(MAKE) -C $(IMX_MKIMAGE_PATH)/imx-mkimage/ SOC=iMX8MM flash_evk_no_hdmi_dual_bootloader || exit 1; \
		$(MAKE) -C $(IMX_MKIMAGE_PATH)/imx-mkimage/ SOC=iMX8MM PRINT_FIT_HAB_OFFSET=0x0 print_fit_hab || exit 1; \
	fi; \
	if [ `echo $(2) | rev | cut -d '-' -f1 | rev` != "dual" ]; then \
		cp $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/flash.bin $(UBOOT_COLLECTION)/u-boot-$(strip $(2)).imx; \
	else \
		cp $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/flash.bin $(UBOOT_COLLECTION)/spl-$(strip $(2)).bin; \
		cp $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/u-boot-ivt.itb $(UBOOT_COLLECTION)/bootloader-$(strip $(2)).img; \
	fi;
endef


