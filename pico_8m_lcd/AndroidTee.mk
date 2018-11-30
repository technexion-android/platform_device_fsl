# uboot.imx in android combine scfw.bin and uboot.bin
MAKE += SHELL=/bin/bash

define build_uboot_w_tee
	$(MAKE) -C bootable/bootloader/arm-trusted-firmware/ -B CROSS_COMPILE=aarch64-linux-android- PLAT=imx8mq V=1 SPD=opteed DECRYPTED_BUFFER_START=$(DECRYPTED_BUFFER_START) DECRYPTED_BUFFER_LEN=$(DECRYPTED_BUFFER_LEN) DECODED_BUFFER_START=$(DECODED_BUFFER_START) DECODED_BUFFER_LEN=$(DECODED_BUFFER_LEN) bl31; \
	cp bootable/bootloader/arm-trusted-firmware/build/imx8mq/release/bl31.bin $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M_LCD/.;\
	aarch64-linux-android-objcopy -O binary out/target/product/pico_8m_lcd/optee/arm-plat-imx/core/tee.elf $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M_LCD/tee.bin; \
	$(MAKE) -C $(IMX_MKIMAGE_PATH)/imx-mkimage/ clean; \
	$(MAKE) -C $(IMX_MKIMAGE_PATH)/imx-mkimage/ SOC=iMX8M_LCD flash_hdmi_spl_uboot; \
	cp $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M_LCD/flash.bin $(PRODUCT_OUT)/u-boot-$(strip $(2)).imx;
endef


