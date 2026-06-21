include $(TOPDIR)/rules.mk

PKG_NAME:=log-collector
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_FIXUP:=autoreconf
PKG_LICENSE:=BSD-3-Clause-Clear

include $(INCLUDE_DIR)/package.mk

SOURCE_DIR:=$(TOPDIR)/src/QPlatformUtils/log-collector

define Package/$(PKG_NAME)
	SECTION:=QTI
	CATEGORY:=QTI-PACKAGES
	TITLE:=log-collector
	DEPENDS:= +libssh2 +jsoncpp +libopenssl +openssh-client +openssh-keygen
endef

define Package/$(PKG_NAME)/Description
	Daemon for collecting log data
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp -rp $(SOURCE_DIR)/* $(PKG_BUILD_DIR)
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/log-collector $(1)/usr/sbin	

	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/log-conf.json $(1)/etc/log-conf.json
	
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/log-collector.init $(1)/etc/init.d/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

