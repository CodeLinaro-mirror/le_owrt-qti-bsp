include $(TOPDIR)/rules.mk

PKG_NAME:=crash-collect
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_LICENSE:=BSD-3-Clause-Clear

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += --with-glib

SOURCE_DIR:= $(TOPDIR)/src/QPlatformUtils/crash-collect/

define Package/$(PKG_NAME)
	SECTION:=QTI
	CATEGORY:=QTI-PACKAGES
	TITLE:=$(PKG_NAME)
	DEPENDS:=+glib2
endef

define Package/$(PKG_NAME)/description
	crash-collect: A utility to notify SSR and collect full crash dumps.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp -rp $(SOURCE_DIR)/* $(PKG_BUILD_DIR)/
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/crashcollect $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/crash-collect.init $(1)/etc/init.d/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
