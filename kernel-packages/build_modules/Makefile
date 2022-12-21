MAKE_OPTS= \
	ARCH=$(ARCH) \
	CROSS_COMPILE=$(CROSS_COMPILE) \
	M=$(M)

modules:
	cd kernel-modules && $(MAKE) $(MAKE_OPTS)
