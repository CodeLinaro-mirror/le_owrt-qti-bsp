include $(TOPDIR)/rules.mk

PKG_NAME:=recovery-updater
PKG_VERSION:=1.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

SOURCE_DIR:=$(TOPDIR)/src/OTA/recovery/recovery_updater

INIT_SCRIPT = "trigger_recovery_updater.init"
ifeq ($(CONFIG_OTA_PACKAGE_VERIFICATION), y)
	INIT_SCRIPT = "updater_ota_authentication.init"
  define Package/recovery-updater/generate_public_key
	$(STAGING_DIR_HOST)/bin/openssl pkcs8 -inform DER -nocrypt -in $(TOPDIR)/src/OTA/recovery/tests/testdata/testkey.pk8 -out $(TOPDIR)/src/OTA/build/tools/releasetools/private.pem
	mkdir -p $(PKG_BUILD_DIR)/ipkg-$(PKGARCH)/$(PKG_NAME)/etc
	$(STAGING_DIR_HOST)/bin/openssl rsa -in $(TOPDIR)/src/OTA/build/tools/releasetools/private.pem -outform PEM -pubout > $(PKG_BUILD_DIR)/ipkg-$(PKGARCH)/$(PKG_NAME)/etc/public.pem
  endef
endif

define Package/recovery-updater
  SECTION:=external
  CATEGORY:=OTA
  TITLE:=recovery_updater
  DEPENDS:=+NAND_SUPPORT:nand-utils
endef

define Package/recovery-updater/description
  Package that triggers recovery updater shell script
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp -rp $(SOURCE_DIR)/* $(PKG_BUILD_DIR)
endef

define Build/Compile
endef

define Package/recovery-updater/install
	$(Package/recovery-updater/generate_public_key)
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(INIT_SCRIPT) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/recovery-updater.sh $(1)/bin
endef

$(eval $(call BuildPackage,recovery-updater))
