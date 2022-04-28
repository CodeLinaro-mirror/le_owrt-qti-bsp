include $(TOPDIR)/rules.mk

PKG_NAME:=libhardware
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_FIXUP:=autoreconf

SOURCE_DIR := $(TOPDIR)/src/hardware/libhardware

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += --enable-audio
CONFIGURE_ARGS += --with-hal-path=/usr/lib

define Package/libhardware
  SECTION:=QTI
  CATEGORY:=QTI-PACKAGES
  TITLE:=Android Libhardware headers
  DEPENDS:= +libcutils +libutils +liblog +core-include
endef

define Package/libhardware/Description
	Android libhardware headers
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) $(SOURCE_DIR)/* $(PKG_BUILD_DIR)/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/include/* $(1)/usr/include/
endef

define Package/libhardware/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/.libs/libhardware.so.0 $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/.libs/libhardware.so.0.0.0 $(1)/usr/lib/

endef

$(eval $(call BuildPackage,libhardware))
