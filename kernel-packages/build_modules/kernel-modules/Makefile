all:
	cd $(TOPDIR)/src/kernel-5.15/kernel_platform; \
	BUILD_CONFIG=msm-kernel/build.config.msm.sdxpinn EXT_MODULES=../../../build_dir/target-aarch64_cortex-a53_musl/linux-sdx75/$(shell basename $(M)) MODULE_OUT=$(M) OUT_DIR=../out/msm-kernel-sdxpinn-debug_defconfig/ ./build/build_module.sh; \
	cd -;

