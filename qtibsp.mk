QTIBSP:=adbd core-include ext4_utils fs_mgr libbase libcutils liblog libmincrypt mkbootimg libsparse logwrapper usb-composition user_permissions

## add target specific packages
ifeq ($(BOARD),sdx65)
	QTIBSP+= edk2
endif
