include $(TOPDIR)/rules.mk

PKG_NAME:=rd-init
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0-only
SOURCE_DIR:=

include $(INCLUDE_DIR)/package.mk

define Package/rd-init
  SECTION:=QTI
  CATEGORY:=QTI-PACKAGES
  TITLE:=Ramdisk init package
endef

define Package/rd-init/description
 Ramdisk init package
endef

define Build/Prepare
	@true
endef

define Build/Compile
	@true
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_BIN) ./files/init $(1)/init
	$(INSTALL_BIN) ./files/init_verity.sh $(1)/init_verity.sh
endef

$(eval $(call BuildPackage,rd-init))
