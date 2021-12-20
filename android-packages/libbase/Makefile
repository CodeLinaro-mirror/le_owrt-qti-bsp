include $(TOPDIR)/rules.mk

PKG_NAME:=libbase
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

SOURCE_DIR:= $(TOPDIR)/src/system/core/base/

define Package/libbase
	SECTION:=QTI
	CATEGORY:=QTI-PACKAGES
	TITLE:= libbase
	DEPENDS:= +libcutils +libselinux
endef

define Package/libbase/description
  Libbase is an open source build system meant to be both extremely fast, and, even more importantly, as user friendly as possible.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp -rp $(SOURCE_DIR)/* $(PKG_BUILD_DIR)
	cp -rp $(SOURCE_DIR)/../include $(PKG_BUILD_DIR)/../
endef

define Host/Prepare
	mkdir -p $(HOST_BUILD_DIR)
	cp -rp $(SOURCE_DIR)/* $(HOST_BUILD_DIR)
	cp -rp $(SOURCE_DIR)/../include $(HOST_BUILD_DIR)/../
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR)
	mkdir -p  $(STAGING_DIR)/usr/lib
	mkdir -p  $(STAGING_DIR)/usr/share/pkgconfig
	mkdir -p  $(STAGING_DIR)/usr/include
	$(CP) $(PKG_BUILD_DIR)/include/base $(STAGING_DIR)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/.libs/libbase.so* $(STAGING_DIR)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/libbase.pc $(STAGING_DIR)/usr/share/pkgconfig
endef

define Package/libbase/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/.libs/libbase.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libbase))
$(eval $(call HostBuild))
