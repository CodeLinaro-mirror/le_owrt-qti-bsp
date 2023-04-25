include $(TOPDIR)/rules.mk

PKG_NAME:=postboot
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_FIXUP:=autoreconf

ifeq ($(BOARD),sdx35)
LOCAL_SRC := $(TOPDIR)/src/system/core/rootdir/sdxbaagha
else
LOCAL_SRC := $(TOPDIR)/src/system/core/rootdir/sdxpinn
endif

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

ifeq ($(USER_VARIANT),1)
define Package/postboot/install
	$(INSTALL_DIR) $(1)/etc/scripts
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/init.post_boot.sh $(1)/etc/scripts/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/postboot.init $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/logging-restrictions.init $(1)/etc/init.d/
endef

else

define Package/postboot/install
	$(INSTALL_DIR) $(1)/etc/scripts
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/init.post_boot.sh $(1)/etc/scripts/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/postboot.init $(1)/etc/init.d/
endef
endif

$(eval $(call BuildPackage,postboot))

