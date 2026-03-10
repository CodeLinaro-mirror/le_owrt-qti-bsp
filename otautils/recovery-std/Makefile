include $(TOPDIR)/rules.mk

PKG_NAME:=recovery-std
PKG_VERSION:=1.0
PKG_LICENSE:=Apache-2.0,BSD-3-Clause-Clear
PKG_RELEASE:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

SOURCE_DIR:=$(TOPDIR)/src/OTA/recovery

CONFIGURE_ARGS += CONFIG_RECOVERY_STD=true

ifeq ($(CONFIG_TARGET_sdx85), y)
CONFIGURE_ARGS += TARGET_SUPPORTS_LVM=true
endif

define Package/libfusesideload
  SECTION:=libs
  CATEGORY:=OTA
  TITLE:=libfusesideload
endef

define Package/recovery-std
  SECTION:=external
  CATEGORY:=OTA
  TITLE:=recovery-std
  DEPENDS:= +libbase +libsparse +libbz2 +adbd +libopenssl +ext4_utils +libmincrypt +libstdcpp +zlib
endef

ifeq ($(CONFIG_OTA_PACKAGE_VERIFICATION), y)
	CONFIGURE_ARGS += TARGET_SUPPORTS_OTA_VERIFICATION=true
  define Package/recovery-std/generate_public_key
	$(STAGING_DIR_HOST)/bin/openssl pkcs8 -inform DER -nocrypt -in $(TOPDIR)/src/OTA/recovery/tests/testdata/testkey.pk8 -out $(TOPDIR)/src/OTA/build/tools/releasetools/private.pem
	mkdir -p $(PKG_BUILD_DIR)/ipkg-$(PKGARCH)/$(PKG_NAME)/etc
	$(STAGING_DIR_HOST)/bin/openssl rsa -in $(TOPDIR)/src/OTA/build/tools/releasetools/private.pem -outform PEM -pubout > $(PKG_BUILD_DIR)/ipkg-$(PKGARCH)/$(PKG_NAME)/etc/public.pem
  endef
endif

define Package/edify-std
  SECTION:=external
  CATEGORY:=OTA
  TITLE:=edify-std
  DEPENDS:=+libbase +libstdcpp
endef

define Package/applypatch-std
  SECTION:=external
  CATEGORY:=OTA
  TITLE:=applypatch-std
  DEPENDS:= +libbase +libstdcpp +libbz2 +libcutils +libmincrypt +libselinux +libopenssl +zlib
endef

define Package/updater-std
  SECTION:=external
  CATEGORY:=OTA
  TITLE:=updater-std
  DEPENDS:= +librecovery-updater-msm +libbase +libstdcpp +libbz2 +libmincrypt +libopenssl +zlib +ext4_utils +liblog
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

define Package/libfusesideload/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/.libs/libfusesideload.a $(1)/usr/lib
endef

define Package/recovery-std/install
	$(Package/recovery-std/generate_public_key)
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/recovery $(1)/usr/bin/recovery
	$(INSTALL_BIN) ./files/fstab_AB_cache_ext4 $(1)/etc/recovery_volume_config
endef

define Package/edify-std/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/edify/edify $(1)/usr/bin/edify
endef

define Package/applypatch-std/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/applypatch/applypatch $(1)/usr/bin/applypatch
endef

define Package/updater-std/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/updater/updater $(1)/usr/bin/updater
endef


$(eval $(call BuildPackage,recovery-std))
$(eval $(call BuildPackage,libfusesideload))
$(eval $(call BuildPackage,edify-std))
$(eval $(call BuildPackage,applypatch-std))
$(eval $(call BuildPackage,updater-std))
