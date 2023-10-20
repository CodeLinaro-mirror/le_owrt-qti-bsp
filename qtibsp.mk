QTIBSP:=adbd powerapp core-include ext4_utils fs_mgr libbase libcutils liblog libmincrypt mkbootimg libsparse leproperties logwrapper usb-composition user_permissions libdmabufheap postboot binder bouncycastle

## add target specific packages
ifeq ($(BOARD),sdx65)
	QTIBSP+= edk2
else ifeq ($(BOARD),sdx75)
	QTIBSP+= procrank lsusb
endif

## Enablement of DM_veity supported  utilties
## this are mostly Host base utilties which will
##  run on system image and update verity data
ifeq ($(CONFIG_PACKAGE_dmverity-utils),y)
	QTIBSP+= dmverity-utils image-utils verity-fec
# Issue with libs usage need to enable later
#libfec-rs libfec
endif
