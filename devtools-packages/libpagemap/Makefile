include $(TOPDIR)/rules.mk

PKG_NAME:=libpagemap
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

SOURCE_DIR:= $(TOPDIR)/src/system/extras/$(PKG_NAME)/

define Package/libpagemap
	SECTION:=QTI
	CATEGORY:=QTI-PACKAGES
	TITLE:= libpagemap
endef

define Package/libpagemap/description
  Libpagemap package
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
	mkdir -p  $(STAGING_DIR)/usr/include/pagemap
	$(CP) $(PKG_BUILD_DIR)/include/pagemap/*.h $(STAGING_DIR)/usr/include/pagemap/
	$(CP) $(PKG_BUILD_DIR)/*.h $(STAGING_DIR)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/.libs/libpagemap.so* $(STAGING_DIR)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/libpagemap.pc $(STAGING_DIR)/usr/share/pkgconfig/
endef

define Package/libpagemap/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/.libs/libpagemap.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libpagemap))
$(eval $(call HostBuild))

