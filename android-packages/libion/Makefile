include $(TOPDIR)/rules.mk

PKG_NAME:=libion
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_FIXUP:= autoreconf

SOURCE_DIR := $(TOPDIR)/src/system/core/libion

include $(INCLUDE_DIR)/package.mk

define Package/libion
  SECTION:=QTI
  CATEGORY:=QTI-PACKAGES
  TITLE:=Libion Android
  DEPENDS:= +liblog
endef

define Package/libion/Description
	Build Android libion.
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
	$(CP) $(PKG_BUILD_DIR)/.libs/libion.so* $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/include/* $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/libion.pc $(1)/usr/share/pkgconfig
endef

define Package/libion/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/.libs/libion.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/iontest $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libion))
