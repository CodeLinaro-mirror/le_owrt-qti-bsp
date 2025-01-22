include $(TOPDIR)/rules.mk

PKG_NAME:=audio-utils
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_FIXUP:=autoreconf
PKG_LICENSE:=Apache-2.0
SOURCE_DIR:= $(TOPDIR)/src/frameworks/audio_utils

include $(INCLUDE_DIR)/package.mk

define Package/audio-utils
  SECTION:=QTI
  CATEGORY:=QTI-PACKAGES
  TITLE:=Audio Utilities Android
  DEPENDS:= +libcutils +media-headers
endef

define Package/audio-utils/Description
	Android audio utilities library.
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
	$(CP) $(PKG_BUILD_DIR)/include/* $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/audio_utils.pc $(1)/usr/share/pkgconfig
endef

define Package/audio-utils/install
	@true
endef

$(eval $(call BuildPackage,audio-utils))
