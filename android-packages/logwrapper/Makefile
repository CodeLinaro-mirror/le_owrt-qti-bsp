include $(TOPDIR)/rules.mk

PKG_NAME:=logwrapper
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

SOURCE_DIR:= $(TOPDIR)/src/system/core/$(PKG_NAME)/

define Package/logwrapper
	SECTION:=QTI
	CATEGORY:=QTI-PACKAGES
	TITLE:= logwrapper
	DEPENDS:= +libcutils +liblog
endef

define Package/logwrapper/description
  Logwrapper is an open source build system meant to be both extremely fast, and, even more importantly, as user friendly as possible.
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
	cp -r $(PKG_BUILD_DIR)/include/logwrap $(STAGING_DIR)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/.libs/liblogwrap.so* $(STAGING_DIR)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/logwrapper.pc $(STAGING_DIR)/usr/share/pkgconfig/
endef

define Package/logwrapper/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/.libs/liblogwrap.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/logwrapper $(1)/usr/bin/
endef

$(eval $(call BuildPackage,logwrapper))
$(eval $(call HostBuild))
