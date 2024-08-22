include $(TOPDIR)/rules.mk

PKG_NAME:=libsparse
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_LICENSE:=Apache-2.0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

SOURCE_DIR:= $(TOPDIR)/src/system/core/$(PKG_NAME)/

define Package/libsparse
	SECTION:=QTI
	CATEGORY:=QTI-PACKAGES
	TITLE:= libsparse
	DEPENDS:= +core-include +zlib
endef

define Package/libsparse/description
  Libsparse is an open source build system meant to be both extremely fast, and, even more importantly, as user friendly as possible.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp -rp $(SOURCE_DIR)/* $(PKG_BUILD_DIR)
endef

define Host/Prepare
	mkdir -p $(HOST_BUILD_DIR)
	cp -rp $(SOURCE_DIR)/* $(HOST_BUILD_DIR)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR)
	mkdir -p  $(STAGING_DIR)/usr/lib
	mkdir -p  $(STAGING_DIR)/usr/share/pkgconfig
	mkdir -p  $(STAGING_DIR)/usr/include
	$(CP) $(PKG_BUILD_DIR)/include/sparse $(STAGING_DIR)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/.libs/libsparse.so* $(STAGING_DIR)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/libsparse.pc $(STAGING_DIR)/usr/share/pkgconfig/
endef

define Package/libsparse/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/.libs/libsparse.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libsparse))
$(eval $(call HostBuild))

