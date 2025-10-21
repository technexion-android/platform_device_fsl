
# Support gpt
ifeq ($(TARGET_INCLUDE_DTB_TO_VENDOR_BOOT),true)
BOARD_BPT_INPUT_FILES += $(CONFIG_REPO_PATH)/common/partition/device-partitions-7GB-ab_super_gbl.bpt
ADDITION_BPT_PARTITION = partition-table-dual:$(CONFIG_REPO_PATH)/common/partition/device-partitions-7GB-ab-dual-bootloader_super_gbl.bpt
else
BOARD_BPT_INPUT_FILES += $(CONFIG_REPO_PATH)/common/partition/device-partitions-7GB-ab_super.bpt
ADDITION_BPT_PARTITION = partition-table-dual:$(CONFIG_REPO_PATH)/common/partition/device-partitions-7GB-ab-dual-bootloader_super.bpt
endif
