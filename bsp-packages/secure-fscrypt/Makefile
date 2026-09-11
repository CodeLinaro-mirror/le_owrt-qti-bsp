include $(TOPDIR)/rules.mk

PKG_NAME:=secure-fscrypt
PKG_RELEASE:=1
PKG_LICENSE:=BSD-3-Clause-Clear
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

SOURCE_DIR:=$(TOPDIR)/src/system/extras/secure-fscrypt/

define Package/secure-fscrypt
  SECTION:=system
  CATEGORY:=System
  TITLE:=FSPAPP-backed fscrypt directory service
endef

define Package/secure-fscrypt/description
  Automatically provisions and unlocks an fscrypt v2 encrypted directory
  using a wrapped key stored in cfg and unwrapped through the
  /dev/fspapp_fscrypt kernel driver.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp -rp $(SOURCE_DIR)/* $(PKG_BUILD_DIR)
endef

define Build/Compile
	$(TARGET_CC) \
	$(TARGET_CFLAGS) \
	$(TARGET_CPPFLAGS) \
	-I $(PKG_BUILD_DIR) \
	-o $(PKG_BUILD_DIR)/secure-fscryptctl \
	$(PKG_BUILD_DIR)/secure-fscryptctl.c \
	$(TARGET_LDFLAGS)
endef

define Package/secure-fscrypt/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/secure-fscryptctl $(1)/usr/bin/secure-fscryptctl

	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(CURDIR)/files/secure-fscrypt.sh $(1)/usr/bin/secure-fscrypt.sh

	$(INSTALL_DIR) $(1)/usr/share
	$(INSTALL_CONF) $(CURDIR)/files/secure-fscrypt.config $(1)/usr/share/secure-fscrypt
endef

$(eval $(call BuildPackage,secure-fscrypt))
