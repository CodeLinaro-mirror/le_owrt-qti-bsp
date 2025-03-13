ifeq ($(BOARD),sdx85)
	PLATFORM=sdxkova
endif
all:
ifeq ($(LINUX_VERSION), 6.6)
	cd $(TOPDIR)/src/kernel-$(LINUX_VERSION)/kernel_platform; \
	SHELL= flock $(TOPDIR)/tmp/.build-modules.flock -c 'ENABLE_DDK_BUILD=true TARGET_BOARD_PLATFORM=$(PLATFORM) VARIANT=$(TARGET_VARIANT)_defconfig BUILD_CONFIG=msm-kernel/$(BUILD_CONFIG_NAME) EXT_MODULES=../../../build_dir/$(TARGET_DIR_NAME)/linux-$(BOARD)/$(shell basename $(M)) MODULE_OUT=$(M) KERNEL_KIT=../out/$(OUT_DIR_NAME)/ OUT_DIR=temp_out_dir ./build/build_module.sh'; \
	cd -;
else ifeq ($(LINUX_VERSION), 5.15)
	cd $(TOPDIR)/src/kernel-$(LINUX_VERSION)/kernel_platform; \
	SHELL= flock $(TOPDIR)/tmp/.build-modules.flock -c 'BUILD_CONFIG=msm-kernel/$(BUILD_CONFIG_NAME) EXT_MODULES=../../../build_dir/$(TARGET_DIR_NAME)/linux-$(BOARD)/$(shell basename $(M)) MODULE_OUT=$(M) KERNEL_KIT=../out/$(OUT_DIR_NAME)/ OUT_DIR=temp_out_dir ./build/build_module.sh'; \
	cd -;
endif
