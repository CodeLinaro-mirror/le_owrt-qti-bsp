include $(TOPDIR)/rules.mk

PKG_NAME:=binder
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_FIXUP:= autoreconf
SOURCE_DIR:= $(TOPDIR)/src/frameworks/binder
TARGET_CFLAGS+= -DUSE_MUSL
CONFIGURE_ARGS+= --with-glib

ifeq ($(BOARD), sdx35)
	TARGET_CFLAGS+= -DBINDER_IPC_32BIT
endif

include $(INCLUDE_DIR)/package.mk

define Package/binder
  SECTION:=QTI
  CATEGORY:=QTI-PACKAGES
  TITLE:=Binder Android
  DEPENDS:= +liblog +libcutils +libutils +core-include +libselinux +glib2
endef

define Package/binder/Description
	Build Android binder.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) $(SOURCE_DIR)/* $(PKG_BUILD_DIR)/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR)
	mkdir -p $(1)/usr/include
	mkdir -p $(1)/usr/share/pkgconfig
	mkdir -p $(1)/usr/lib/
	mkdir -p $(1)/usr/bin/
	$(CP) $(PKG_BUILD_DIR)/include/* $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/libs/binder/libbinder.pc $(1)/usr/share/pkgconfig
	$(CP) $(PKG_BUILD_DIR)/libs/binder/.libs/libbinder.so* $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/libs/binder/.libs/test_binder $(1)/usr/bin/
	$(CP) $(PKG_BUILD_DIR)/cmds/servicemanager/servicemanager $(1)/usr/bin/
endef

define Package/binder/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/libs/binder/.libs/libbinder.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/libs/binder/.libs/test_binder $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cmds/servicemanager/servicemanager $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/binderfs.init $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/servicemanager.init $(1)/etc/init.d/
endef

$(eval $(call BuildPackage,binder))
