include $(TOPDIR)/rules.mk

PKG_NAME:=liblog
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

SOURCE_DIR:= $(TOPDIR)/src/system/core/$(PKG_NAME)/

define Package/liblog
	SECTION:=QTI
	CATEGORY:=QTI-PACKAGES
	DEPENDS:= +libstdcpp
	TITLE:= liblog
endef

define Package/liblog/description
  Liblog is an open source build system meant to be both extremely fast, and, even more importantly, as user friendly as possible.
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
	mkdir -p  $(1)/usr/lib
	mkdir -p  $(1)/usr/share/pkgconfig
	$(CP) $(PKG_BUILD_DIR)/.libs/liblog.so* $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/liblog.pc $(1)/usr/share/pkgconfig
endef

define Package/liblog/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/.libs/liblog.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,liblog))
$(eval $(call HostBuild))
