include $(TOPDIR)/rules.mk

PKG_NAME:=libutils
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_FIXUP:= autoreconf
SOURCE_DIR:= $(TOPDIR)/src/system/core/libutils

include $(INCLUDE_DIR)/package.mk

define Package/libutils
  SECTION:=QTI
  CATEGORY:=QTI-PACKAGES
  TITLE:=Libutils Android
  DEPENDS:= +safe-iop +core-include +libstdcpp
endef

define Package/libutils/Description
	Build Android libutils.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) $(SOURCE_DIR)/* $(PKG_BUILD_DIR)/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR)
	mkdir -p  $(1)/usr/lib
	mkdir -p  $(1)/usr/include
	mkdir -p  $(1)/usr/share/pkgconfig
	$(CP) $(PKG_BUILD_DIR)/.libs/libutils.so* $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/libutils.pc $(1)/usr/share/pkgconfig
endef

define Package/libutils/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/.libs/libutils.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libutils))
