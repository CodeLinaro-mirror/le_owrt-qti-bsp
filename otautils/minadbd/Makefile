include $(TOPDIR)/rules.mk

PKG_NAME:=minadbd
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

SOURCE_DIR:=$(TOPDIR)/src/OTA/recovery

define Package/minadbd
  SECTION:=external
  CATEGORY:=OTA
  TITLE:=minadbd
  DEPENDS:= +libbase +libstdcpp +adbd
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp -r $(SOURCE_DIR)/* $(PKG_BUILD_DIR)
	$(Build/Patch)
endef

define Package/minadbd/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/minadbd/.libs/libminadbd.so.* $(1)/usr/lib
endef

$(eval $(call BuildPackage,minadbd))
