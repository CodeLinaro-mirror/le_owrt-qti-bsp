include $(TOPDIR)/rules.mk

PKG_NAME:=tinyalsa
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_FIXUP:=autoreconf
SOURCE_DIR:= $(TOPDIR)/src/vendor/qcom/opensource/tinyalsa/

include $(INCLUDE_DIR)/package.mk

define Package/tinyalsa
  SECTION:=QTI
  CATEGORY:=QTI-PACKAGES
  TITLE:=tinyalsa Android
  DEPENDS:= +libcutils +libexpat +glib2
endef

define Package/tinyalsa/Description
	Build Android tinyalsa.
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
	$(CP) $(PKG_BUILD_DIR)/.libs/libtinyalsa.so* $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/include/* $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/tinyalsa.pc $(1)/usr/share/pkgconfig
endef

define Package/tinyalsa/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/.libs/libtinyalsa.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tests/* $(1)/usr/bin/
endef

$(eval $(call BuildPackage,tinyalsa))
