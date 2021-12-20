include $(TOPDIR)/rules.mk

PKG_NAME:=adbd
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_FIXUP:=autoreconf

SOURCE_DIR:= $(TOPDIR)/src/system/core/adb

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

TARGET_CFLAGS = -I$(TOPDIR)/src/system/core/mkbootimg

define Package/adbd
  SECTION:=Utils
  CATEGORY:=QTI-PACKAGES
  TITLE:=Android Debug Bridge CLI tool
  DEPENDS:= +liblog +libcutils +libselinux +libmincrypt +libbase +fs_mgr +ext4_utils
endef

define Package/adbd/description
 Android Debug Bridge (adb) is a versatile command line tool that lets you communicate with an emulator instance or connected Android-powered device.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp -rp $(SOURCE_DIR)/* $(PKG_BUILD_DIR)
	cp -rp $(SOURCE_DIR)/../include $(PKG_BUILD_DIR)/../
endef

define Host/Prepare
	mkdir -p $(HOST_BUILD_DIR)
	cp -rp $(SOURCE_DIR)/* $(HOST_BUILD_DIR)
	cp -rp $(SOURCE_DIR)/../include $(HOST_BUILD_DIR)/../
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
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/.libs/adbd $(1)/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/launch_adbd $(1)/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/adbd.init $(1)/etc/init.d/
endef

$(eval $(call BuildPackage,adbd))
$(eval $(call HostBuild))
