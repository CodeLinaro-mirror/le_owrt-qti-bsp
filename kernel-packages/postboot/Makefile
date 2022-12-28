include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/target.mk

PKG_NAME:=postboot
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_FIXUP:=autoreconf

LOCAL_SRC := $(TOPDIR)/src/system/core/rootdir/$(KERNEL_PLATFORM_TARGET)

include $(INCLUDE_DIR)/package.mk

define Package/postboot
	SECTION:=QTI
	CATEGORY:=QTI-PACKAGES
	TITLE:=Postboot
endef

define Package/postboot/Description
	postboot
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)/
	$(CP) $(LOCAL_SRC)/* $(PKG_BUILD_DIR)/
endef

define Build/Configure
	@true
endef

define Build/Compile
	@true
endef

define Package/postboot/install
	$(INSTALL_DIR) $(1)/etc/scripts
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/init.post_boot.sh $(1)/etc/scripts/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/postboot.init $(1)/etc/init.d/
endef

$(eval $(call BuildPackage,postboot))

