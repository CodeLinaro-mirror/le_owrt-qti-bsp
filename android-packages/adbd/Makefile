include $(TOPDIR)/rules.mk

PKG_NAME:=adbd
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

SOURCE_DIR:= $(TOPDIR)/src/system/core/adb

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

TARGET_CFLAGS += -DUSE_MUSL -I$(TOPDIR)/src/system/core/mkbootimg -I$(STAGING_DIR)/usr/include/glib-2.0 -Dstrlcpy=strlcpy

define Package/adbd
  SECTION:=Utils
  CATEGORY:=QTI-PACKAGES
  TITLE:=Android Debug Bridge CLI tool
  DEPENDS:= +core-include +liblog +libcutils +libselinux +libmincrypt +libbase +fs_mgr +ext4_utils
endef

define Package/adbd/description
 Android Debug Bridge (adb) is a versatile command line tool that lets you communicate with an emulator instance or connected Android-powered device.
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
	$(INSTALL_DIR) $(STAGING_DIR)/usr/lib
	mkdir -p  $(STAGING_DIR)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/.libs/libadbd.so* $(STAGING_DIR)/usr/lib/
endef

define Package/adbd/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/.libs/libadbd.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_DIR) $(1)/etc/initscripts
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/.libs/adbd $(1)/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/launch_adbd $(1)/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/start_pcie $(1)/etc/initscripts/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/pcie.init $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/adbd.init $(1)/etc/init.d/
endef

$(eval $(call BuildPackage,adbd))
$(eval $(call HostBuild))
