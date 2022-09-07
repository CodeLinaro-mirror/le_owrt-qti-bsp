MAKE_OPTS= \
	ARCH="arm64" \
	CROSS_COMPILE="aarch64-linux-gnu-" \
	M=$(M)

modules:
	cd kernel-modules && $(MAKE) $(MAKE_OPTS)
