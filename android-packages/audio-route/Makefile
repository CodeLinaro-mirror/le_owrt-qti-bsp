include $(TOPDIR)/rules.mk

PKG_NAME:=audio-route
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_FIXUP:= autoreconf

SOURCE_DIR := $(TOPDIR)/src/frameworks/audio_route

include $(INCLUDE_DIR)/package.mk

define Package/audio-route
  SECTION:=QTI
  CATEGORY:=QTI-PACKAGES
  TITLE:=audio-route
  DEPENDS:= +libexpat +liblog +tinyalsa +core-include
endef

define Package/audio-route/Description
	Build Android audio-route.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) $(SOURCE_DIR)/* $(PKG_BUILD_DIR)/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR)
	mkdir -p  $(1)/usr/include
	mkdir -p  $(1)/usr/lib
	mkdir -p  $(1)/usr/share/pkgconfig
	$(CP) $(PKG_BUILD_DIR)/include/* $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/.libs/libaudio*.so* $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/audio_route.pc.in $(1)/usr/share/pkgconfig
endef

define Package/audio-route/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/.libs/libaudio*.so* $(1)/usr/lib/
endef
$(eval $(call BuildPackage,audio-route))
