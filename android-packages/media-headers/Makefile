include $(TOPDIR)/rules.mk

PKG_NAME:=media-headers
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

SOURCE_DIR:=$(TOPDIR)/src/frameworks/include/media
PKG_BUILD_DEPENDS:= media-headers/host

define Package/media-headers
	SECTION:=QTI
	CATEGORY:=QTI-PACKAGES
	TITLE:=Linux Media Headers
endef

define Package/media-headers/Description
	Linux Media Headers.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) $(SOURCE_DIR)/* $(PKG_BUILD_DIR)/
endef

define Host/Prepare
	mkdir -p $(HOST_BUILD_DIR)
	cp -rp $(SOURCE_DIR)/* $(HOST_BUILD_DIR)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/* $(1)/usr/include/
endef

define Package/media-headers/install
	@true
endef

$(eval $(call BuildPackage,media-headers))
$(eval $(call HostBuild))
