include $(TOPDIR)/rules.mk

PKG_NAME:=procrank
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

SOURCE_DIR:= $(TOPDIR)/src/system/extras/$(PKG_NAME)/

define Package/procrank
	SECTION:=QTI
	CATEGORY:=QTI-PACKAGES
	TITLE:= procrank
	DEPENDS:= +libcutils +libpagemap
endef

define Package/procrank/description
  Procrank memory analysis tool
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp -rp $(SOURCE_DIR)/* $(PKG_BUILD_DIR)
endef

define Host/Prepare
	mkdir -p $(HOST_BUILD_DIR)
	cp -rp $(SOURCE_DIR)/* $(HOST_BUILD_DIR)
endef

define Package/procrank/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/procrank $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,procrank))
$(eval $(call HostBuild))

