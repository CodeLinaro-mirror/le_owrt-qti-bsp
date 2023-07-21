include $(TOPDIR)/rules.mk

PKG_NAME:=recovery-ab
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

SOURCE_DIR:=$(TOPDIR)/src/OTA/recovery

CONFIGURE_ARGS += TARGET_SUPPORTS_AB=true
CONFIGURE_ARGS += TARGET_NAND_AB_BOOT=true

define Package/libfusesideload
  SECTION:=libs
  CATEGORY:=OTA
  TITLE:=libfusesideload
endef

define Package/recovery-ab
  SECTION:=external
  CATEGORY:=OTA
  TITLE:=recovery-ab
  DEPENDS:= +abctl +minadbd +libbase +libsparse +libbz2 +adbd +libopenssl +ext4_utils +libmincrypt +libstdcpp +zlib
endef

ifeq ($(CONFIG_OTA_PACKAGE_VERIFICATION), y)
	CONFIGURE_ARGS += TARGET_SUPPORTS_OTA_VERIFICATION=true
  define Package/recovery-ab/generate_public_key
	$(STAGING_DIR_HOST)/bin/openssl pkcs8 -inform DER -nocrypt -in $(TOPDIR)/src/OTA/recovery/tests/testdata/testkey.pk8 -out $(TOPDIR)/src/OTA/build/tools/releasetools/private.pem
	mkdir -p $(PKG_BUILD_DIR)/ipkg-$(PKGARCH)/$(PKG_NAME)/etc
	$(STAGING_DIR_HOST)/bin/openssl rsa -in $(TOPDIR)/src/OTA/build/tools/releasetools/private.pem -outform PEM -pubout > $(PKG_BUILD_DIR)/ipkg-$(PKGARCH)/$(PKG_NAME)/etc/public.pem
  endef
endif

define Package/edify-ab
  SECTION:=external
  CATEGORY:=OTA
  TITLE:=edify-ab
  DEPENDS:=+libbase +libstdcpp
endef

define Package/applypatch-ab
  SECTION:=external
  CATEGORY:=OTA
  TITLE:=applypatch-ab
  DEPENDS:= +libbase +libstdcpp +libbz2 +libcutils +libmincrypt +libselinux +libopenssl +zlib
endef

define Package/updater-ab
  SECTION:=external
  CATEGORY:=OTA
  TITLE:=updater-ab
  DEPENDS:= +abctl +librecovery-updater-msm +libbase +libstdcpp +libbz2 +libmincrypt +libopenssl +zlib +ext4_utils +liblog
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

define Package/recovery-ab/install
	$(Package/recovery-ab/generate_public_key)
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/.libs/recovery $(1)/usr/bin/recovery
	$(INSTALL_BIN) ./files/fstab_AB_cache_ext4 $(1)/etc/recovery_volume_config
endef

define Package/edify-ab/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/edify/edify $(1)/usr/bin/edify
endef

define Package/applypatch-ab/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/applypatch/applypatch $(1)/usr/bin/applypatch
endef

define Package/updater-ab/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/updater/updater $(1)/usr/bin/updater
endef

$(eval $(call BuildPackage,recovery-ab))
$(eval $(call BuildPackage,libfusesideload))
$(eval $(call BuildPackage,edify-ab))
$(eval $(call BuildPackage,applypatch-ab))
$(eval $(call BuildPackage,updater-ab))
