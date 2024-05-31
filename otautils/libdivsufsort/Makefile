include $(TOPDIR)/rules.mk

PKG_NAME:=libdivsufsort
PKG_VERSION:=1.0
PKG_LICENSE:=MIT
PKG_RELEASE:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

SOURCE_DIR:=$(TOPDIR)/src/OTA/external/$(PKG_NAME)

define Package/libdivsufsort
  SECTION:=libs
  CATEGORY:=OTA
  TITLE:=libdivsufsort
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp -r $(SOURCE_DIR)/* $(PKG_BUILD_DIR)
endef

define Host/Prepare
	mkdir -p $(HOST_BUILD_DIR)
	cp -rp $(SOURCE_DIR)/* $(HOST_BUILD_DIR)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR)
	mkdir -p $(STAGING_DIR)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/lib/.libs/libdivsufsort.so* $(STAGING_DIR)/usr/lib
endef

define Package/libdivsufsort/install
	@true
endef

define Host/Install
	$(INSTALL_DIR) $(STAGING_DIR_HOST)/lib/
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/lib/.libs/libdivsufsort.so* $(STAGING_DIR_HOST)/lib/
endef

$(eval $(call BuildPackage,libdivsufsort))
$(eval $(call HostBuild))
