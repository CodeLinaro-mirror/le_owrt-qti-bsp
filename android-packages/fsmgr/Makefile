include $(TOPDIR)/rules.mk

PKG_NAME:=fs_mgr
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

SOURCE_DIR:= $(TOPDIR)/src/system/core/$(PKG_NAME)/

TARGET_CFLAGS += -DUSE_MUSL -I$(STAGING_DIR)/usr/include/glib-2.0 -Dstrlcat=strlcat

define Package/fs_mgr
	SECTION:=QTI
	CATEGORY:=QTI-PACKAGES
	TITLE:= fs_mgr
	DEPENDS:= +core-include +libcutils +liblog +logwrapper +libmincrypt +ext4_utils
endef

define Package/fs_mgr/description
  fs_mgr is an open source build system meant to be both extremely fast, and, even more importantly, as user friendly as possible.
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
	mkdir -p  $(STAGING_DIR)/usr/include
	$(CP) $(PKG_BUILD_DIR)/include/fs_mgr.h $(STAGING_DIR)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/.libs/libfs_mgr.so* $(STAGING_DIR)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/fs_mgr.pc $(STAGING_DIR)/usr/share/pkgconfig
endef

define Package/fs_mgr/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/.libs/libfs_mgr.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,fs_mgr))
$(eval $(call HostBuild))
