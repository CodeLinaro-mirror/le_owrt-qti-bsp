include $(TOPDIR)/rules.mk

PKG_NAME:=qdss_config
PKG_VERSION:=1.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

define Package/qdss_config
	SECTION:=QTI
	CATEGORY:=QTI-PACKAGES
	TITLE:= qdss_config
endef

define Package/qdss_config/description
  Scripts to config qdss component
endef

define Host/Prepare
	@true
endef

define Build/Compile
	@true
endef

define Build/Configure
	@true
endef

define Build/Prepare
	$(Build/Patch)
endef

define Package/qdss_config/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/qdss_config.init $(1)/etc/init.d/qdss_config.init
	$(INSTALL_DIR) $(1)/etc/scripts
	$(INSTALL_BIN) ./files/qdss_config $(1)/etc/scripts/qdss_config
endef

$(eval $(call BuildPackage,qdss_config))
$(eval $(call HostBuild))
