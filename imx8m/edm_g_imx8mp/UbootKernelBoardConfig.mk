# from BoardConfig.mk
TARGET_BOOTLOADER_POSTFIX := bin
UBOOT_POST_PROCESS := true

# u-boot target
TARGET_BOOTLOADER_CONFIG := imx8mp:edm-g-imx8mp_android_defconfig
#TARGET_BOOTLOADER_CONFIG += imx8mp-trusty-secure-unlock-dual:edm-g-imx8mp_android_trusty_secure_unlock_dual_defconfig
#TARGET_BOOTLOADER_CONFIG += imx8mp-dual:edm-g-imx8mp_android_dual_defconfig
#TARGET_BOOTLOADER_CONFIG += imx8mp-trusty-dual:edm-g-imx8mp_android_trusty_dual_defconfig
ifeq ($(POWERSAVE),true)
TARGET_BOOTLOADER_CONFIG += imx8mp-powersave:edm-g-imx8mp_android_powersave_defconfig
TARGET_BOOTLOADER_CONFIG += imx8mp-trusty-powersave-dual:edm-g-imx8mp_android_trusty_powersave_dual_defconfig
endif
#TARGET_BOOTLOADER_CONFIG += imx8mp-evk-uuu:edm-g-imx8mp_android_uuu_defconfig
TARGET_BOOTLOADER_CONFIG += imx8mp-evk-uuu:edm-g-imx8mp_android_defconfig

ifeq ($(IMX8MP_USES_GKI),true)
TARGET_KERNEL_DEFCONFIG := gki_defconfig
TARGET_KERNEL_GKI_DEFCONF:= tn_imx8mp_gki.fragment
else
TARGET_KERNEL_DEFCONFIG := tn_imx8_android_defconfig
endif

ifeq ($(SIM8202_MODEM_ACTIVE),true)
TARGET_KERNEL_ADDITION_DEFCONF := android_sim8202_addition_defconfig
else
TARGET_KERNEL_ADDITION_DEFCONF := android_addition_defconfig
endif

# absolute path is used, not the same as relative path used in AOSP make
TARGET_DEVICE_DIR := $(patsubst %/, %, $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

# define bootloader rollback index
BOOTLOADER_RBINDEX ?= 0

