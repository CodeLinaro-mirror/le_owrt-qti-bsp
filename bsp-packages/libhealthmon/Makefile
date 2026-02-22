include $(TOPDIR)/rules.mk

PKG_NAME:=libhealthmon
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_LICENSE:=BSD-3-Clause-Clear

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += --with-glib

SOURCE_DIR:= $(TOPDIR)/src/system/extras/libhealthmon

ifneq ($(PRPL_VERSION),)
	TARGET_CFLAGS += -DFEATURE_PRPLWRT
endif

define Package/$(PKG_NAME)
	SECTION:=QTI
	CATEGORY:=QTI-PACKAGES
	TITLE:= $(PKG_NAME)
	DEPENDS:= +glib2
endef

define Package/$(PKG_NAME)/description
	libhealthmon
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp -rp $(SOURCE_DIR)/* $(PKG_BUILD_DIR)
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/.libs/healthmon $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/.libs/libhealthmon.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

