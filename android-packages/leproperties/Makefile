include $(TOPDIR)/rules.mk

PKG_NAME:=leproperties
PKG_VERSION:=2.0
PKG_RELEASE:=${AUTORELEASE}
PKG_FIXUP:= autoreconf
PKG_INSTALL:=1
PKG_LICENSE:=BSD-3-Clause & Apache-2.0

LOCAL_SRC ?= $(TOPDIR)/src/system/core/leproperties
include $(INCLUDE_DIR)/package.mk

ifeq ($(BOARD), sdx35)
	TARGET_CFLAGS += -DPROP_TRIGGER
endif



ifeq ($(CONFIG_PACKAGE_selinux-policy),y)
CONFIGURE_ARGS += --enable-selinux-policy
LEPROP_DEPENDS:= +libselinux +libcutils +liblog
else
CONFIGURE_ARGS += --disable-selinux-policy
LEPROP_DEPENDS:= +libcutils +liblog
endif

define Package/$(PKG_NAME)
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=leproperties
	DEPENDS:=$(LEPROP_DEPENDS)
endef

define Package/$(PKG_NAME)/Description
	Andorid like properties managment for LE
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)/
	$(CP) $(LOCAL_SRC)/* $(PKG_BUILD_DIR)/
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/sbin/* $(1)/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/proptrigger.conf $(1)/etc/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/proptrigger.sh $(1)/etc/
	$(INSTALL_BIN) ./files/leproperties.init $(1)/etc/init.d/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
