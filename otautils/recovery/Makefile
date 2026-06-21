include $(TOPDIR)/rules.mk

PKG_NAME:=recovery
PKG_VERSION:=1.0
PKG_LICENSE:=Apache-2.0,BSD-3-Clause
PKG_RELEASE:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

SOURCE_DIR:=$(TOPDIR)/src/OTA/recovery

PKG_BUILD_DEPENDS += recovery/host
HOST_BUILD_DEPENDS += bzip2/host

ifeq ($(CONFIG_PACKAGE_selinux-policy),y)
CONFIGURE_ARGS += --enable-selinux-policy
APPLYPATCH_DEPENDS:=+libbase +libstdcpp +libbz2 +libcutils +libmincrypt +libselinux +libopenssl +zlib
else
CONFIGURE_ARGS += --disable-selinux-policy
APPLYPATCH_DEPENDS:=+libbase +libstdcpp +libbz2 +libcutils +libmincrypt +libopenssl +zlib
endif

define Package/libfusesideload
  SECTION:=libs
  CATEGORY:=OTA
  TITLE:=libfusesideload
endef

define Package/recovery
  SECTION:=external
  CATEGORY:=OTA
  TITLE:=recovery
  DEPENDS:=+libbase +libbz2 +libopenssl +ext4_utils +libmincrypt +libstdcpp +zlib +adbd
endef

ifeq ($(CONFIG_OTA_PACKAGE_VERIFICATION), y)
	CONFIGURE_ARGS += TARGET_SUPPORTS_OTA_VERIFICATION=true
  define Package/recovery/generate_public_key
	$(STAGING_DIR_HOST)/bin/openssl pkcs8 -inform DER -nocrypt -in $(TOPDIR)/src/OTA/recovery/tests/testdata/testkey.pk8 -out $(TOPDIR)/src/OTA/build/tools/releasetools/private.pem
	mkdir -p $(PKG_BUILD_DIR)/ipkg-$(PKGARCH)/$(PKG_NAME)/etc
	$(STAGING_DIR_HOST)/bin/openssl rsa -in $(TOPDIR)/src/OTA/build/tools/releasetools/private.pem -outform PEM -pubout > $(PKG_BUILD_DIR)/ipkg-$(PKGARCH)/$(PKG_NAME)/etc/public.pem
  endef
endif

define Package/edify
  SECTION:=external
  CATEGORY:=OTA
  TITLE:=edify
  DEPENDS:=+libbase +libstdcpp
endef

define Package/applypatch
  SECTION:=external
  CATEGORY:=OTA
  TITLE:=applypatch
  DEPENDS:= $(APPLYPATCH_DEPENDS)
endef

define Package/updater
  SECTION:=external
  CATEGORY:=OTA
  TITLE:=updater
  DEPENDS:=+librecovery-updater-msm +libbase +libstdcpp +libbz2 +libmincrypt +libopenssl +zlib +ext4_utils +liblog
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp -r $(SOURCE_DIR)/* $(PKG_BUILD_DIR)
	$(Build/Patch)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR)
	mkdir -p  $(1)/usr/share/pkgconfig
	$(CP) $(PKG_BUILD_DIR)/recovery.pc $(1)/usr/share/pkgconfig
endef

define Host/Prepare
	mkdir -p $(HOST_BUILD_DIR)
	cp -rp $(SOURCE_DIR)/applypatch/* $(HOST_BUILD_DIR)
endef

define Host/Install
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/imgdiff $(STAGING_DIR_HOST)/bin/
endef

define Package/libfusesideload/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/.libs/libfusesideload.a $(1)/usr/lib
endef

define Package/recovery/install
	$(Package/recovery/generate_public_key)
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/recovery $(1)/usr/bin/recovery
	$(INSTALL_BIN) ./files/recovery.init $(1)/etc/init.d/recovery.init
endef

define Package/edify/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/edify/edify $(1)/usr/bin/edify
endef

define Package/applypatch/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/applypatch/applypatch $(1)/usr/bin/applypatch
endef

define Package/updater/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/updater/updater $(1)/usr/bin/updater
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,libfusesideload))
$(eval $(call BuildPackage,recovery))
$(eval $(call BuildPackage,edify))
$(eval $(call BuildPackage,applypatch))
$(eval $(call BuildPackage,updater))
