QTIBSP:=adbd core-include ext4_utils fs_mgr libbase libcutils liblog libmincrypt mkbootimg libsparse leproperties logwrapper usb-composition user_permissions libdmabufheap postboot

## add target specific packages
ifeq ($(BOARD),sdx65)
	QTIBSP+= edk2
else ifeq ($(BOARD),sdx75)
	QTIBSP+= procrank
endif
