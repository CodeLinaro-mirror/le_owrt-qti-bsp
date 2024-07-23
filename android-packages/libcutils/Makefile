include $(TOPDIR)/rules.mk

PKG_NAME:=libcutils
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_LICENSE:=Apache-2.0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

SOURCE_DIR:= $(TOPDIR)/src/system/core/$(PKG_NAME)/
TARGET_CFLAGS += -DUSE_MUSL
HOST_BUILD_DEPENDS:= liblog/host

CONFIGURE_ARGS += --with-host-os=linux --disable-static --enable-leproperties

define Package/libcutils
	SECTION:=QTI
	CATEGORY:=QTI-PACKAGES
	TITLE:= libcutils
	DEPENDS:= +core-include +liblog
endef

define Package/libcutils/description
  Libcutils is an open source build system meant to be both extremely fast, and, even more importantly, as user friendly as possible.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp -rp $(SOURCE_DIR)/* $(PKG_BUILD_DIR)
endef

define Host/Prepare
	mkdir -p $(HOST_BUILD_DIR)
	cp -rp $(SOURCE_DIR)/* $(HOST_BUILD_DIR)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR)
	mkdir -p  $(STAGING_DIR)/usr/lib
	mkdir -p  $(STAGING_DIR)/usr/share/pkgconfig
	mkdir -p  $(STAGING_DIR)/usr/include/cutils
	$(CP) $(PKG_BUILD_DIR)/.libs/libcutils.so* $(STAGING_DIR)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/libcutils.pc $(STAGING_DIR)/usr/share/pkgconfig
	$(CP) $(PKG_BUILD_DIR)/property_ops.h $(STAGING_DIR)/usr/include/cutils/
endef

define Package/libcutils/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/.libs/libcutils.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libcutils))
$(eval $(call HostBuild))
