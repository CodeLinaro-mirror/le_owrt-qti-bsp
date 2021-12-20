include $(TOPDIR)/rules.mk

PKG_NAME:=core-include
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

SOURCE_DIR := $(TOPDIR)/src/system/core/include/
PKG_INSTALL:=1

define Package/core-include
  SECTION:=QTI
  CATEGORY:=QTI-PACKAGES
  TITLE:= core-include
endef

define Package/core-include/description
  Core-include headers required by various QTI recipes
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp -rp $(SOURCE_DIR)/* $(PKG_BUILD_DIR)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR)
	mkdir -p $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/android $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/diskconfig $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/mincrypt $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/netutils $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/sys $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/sysutils $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/utils $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/backtrace $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/cutils $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/log $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/memtrack $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/nativebridge $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/private $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/system $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/usbhost $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/ziparchive $(1)/usr/include/
endef

define Package/core-include/install
	@true
endef

$(eval $(call BuildPackage,core-include))
