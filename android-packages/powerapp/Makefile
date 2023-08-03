include $(TOPDIR)/rules.mk

PKG_NAME:=powerapp
PKG_VERSION:=1.0
PKG_RELEASE:=${AUTORELEASE}
PKG_FIXUP:= autoreconf
PKG_INSTALL:=1
PKG_LICENSE:=BSD-3-Clause

LOCAL_SRC ?= $(TOPDIR)/src/system/core/powerapp
include $(INCLUDE_DIR)/package.mk

ifeq ($(BOARD), sdx35)
	TARGET_CFLAGS += -DIS_KUNO
endif

define Package/$(PKG_NAME)
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=powerapp
	DEPENDS:=+libcutils +liblog
endef

define Package/$(PKG_NAME)/Description
	Powerapp binary
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)/
	$(CP) $(LOCAL_SRC)/* $(PKG_BUILD_DIR)/
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/sbin
	$(CP) $(PKG_BUILD_DIR)/powerapp $(1)/sbin/
	$(LN) powerapp $(1)/sbin/sys_reboot
	$(LN) powerapp $(1)/sbin/sys_shutdown
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
