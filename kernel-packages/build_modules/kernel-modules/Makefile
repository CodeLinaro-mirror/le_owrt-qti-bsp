all:
	cd $(TOPDIR)/src/kernel-5.15/kernel_platform; \
	SHELL= flock $(TOPDIR)/tmp/.build-modules.flock -c 'BUILD_CONFIG=msm-kernel/build.config.msm.sdxpinn EXT_MODULES=../../../build_dir/target-aarch64_cortex-a53_musl/linux-sdx75/$(shell basename $(M)) MODULE_OUT=$(M) KERNEL_KIT=../out/msm-kernel-sdxpinn-debug_defconfig/ OUT_DIR=temp_out_dir ./build/build_module.sh'; \
	cd -;

