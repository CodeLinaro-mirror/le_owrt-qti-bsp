include $(TOPDIR)/rules.mk

PKG_NAME:=safe-iop
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_FIXUP:=autoreconf
SOURCE_DIR:= $(TOPDIR)/src/external/safe-iop/

include $(INCLUDE_DIR)/package.mk

define Package/safe-iop
  SECTION:=QTI
  CATEGORY:=QTI-PACKAGES
  TITLE:=safe-iop
endef

define Package/safe-iop/Description
	safe-iop.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) $(SOURCE_DIR)/* $(PKG_BUILD_DIR)/
        $(Build/Patch)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR)
	mkdir -p  $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/include/* $(1)/usr/include/
endef

define Package/safe-iop/install
        $(INSTALL_DIR) $(1)/usr/lib
        $(CP) $(PKG_BUILD_DIR)/.libs/libsafe_iop.so.0 $(1)/usr/lib/
        $(CP) $(PKG_BUILD_DIR)/.libs/libsafe_iop.so.0.0.0 $(1)/usr/lib/
endef

$(eval $(call BuildPackage,safe-iop))
