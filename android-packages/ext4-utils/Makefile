include $(TOPDIR)/rules.mk

PKG_NAME:=ext4_utils
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_LICENSE:=Apache-2.0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

SOURCE_DIR:= $(TOPDIR)/src/system/extras/$(PKG_NAME)/

PKG_BUILD_DEPENDS:= ext4-utils/host

ifneq ($(CONFIG_PACKAGE_selinux-policy),y)
CONFIGURE_ARGS += --disable-selinux-mode
endif

ifeq ($(CONFIG_PACKAGE_selinux-policy),y)
HOST_BUILD_DEPENDS:= libselinux/host libsparse/host libcutils/host
EXT4_DEPENDS:= +libselinux +libsparse +libcutils +libpcre +core-include
else
HOST_BUILD_DEPENDS:= libsparse/host libcutils/host
EXT4_DEPENDS:= +libsparse +libcutils +libpcre +core-include
endif

define Package/ext4_utils
	SECTION:=QTI
	CATEGORY:=QTI-PACKAGES
	TITLE:= ext4_utils
        DEPENDS:= $(EXT4_DEPENDS)
endef

define Package/ext4_utils/description
  Ext4_utils is an open source build system meant to be both extremely fast, and, even more importantly, as user friendly as possible.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp -rp $(SOURCE_DIR)/* $(PKG_BUILD_DIR)
endef

define Host/Prepare
	mkdir -p $(HOST_BUILD_DIR)
	cp -rp $(SOURCE_DIR)/* $(HOST_BUILD_DIR)
endef

define Host/Install
	$(INSTALL_DIR) $(STAGING_DIR_HOSTPKG)/bin
	$(INSTALL_DIR) $(STAGING_DIR_HOSTPKG)/lib
	$(CP) $(HOST_BUILD_DIR)/.libs/make_ext4fs $(STAGING_DIR_HOSTPKG)/bin/
	$(CP) $(HOST_BUILD_DIR)/.libs/libext4_utils.so* $(STAGING_DIR_HOSTPKG)/lib/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR)
	mkdir -p  $(STAGING_DIR)/usr/lib
	mkdir -p  $(STAGING_DIR)/usr/share/pkgconfig
	mkdir -p  $(STAGING_DIR)/usr/include
	$(CP) $(PKG_BUILD_DIR)/.libs/libext4_utils.so* $(STAGING_DIR)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/*.h $(STAGING_DIR)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/ext4_utils.pc $(STAGING_DIR)/usr/share/pkgconfig
endef

define Package/ext4_utils/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/.libs/libext4_utils.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,ext4_utils))
$(eval $(call HostBuild))
