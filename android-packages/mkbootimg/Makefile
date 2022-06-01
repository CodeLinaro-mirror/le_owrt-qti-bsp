include $(TOPDIR)/rules.mk

PKG_NAME:=mkbootimg
PKG_VERSION:=1.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

LOCAL_SRC ?= $(TOPDIR)/src/system/core/$(PKG_NAME)

HOST_CFLAGS += -I$(HOST_BUILD_DIR)/../include/
TARGET_LDFLAGS += -lmincrypt
PKG_BUILD_DEPENDS += mkbootimg/host
HOST_BUILD_DEPENDS += libmincrypt/host

define Package/mkbootimg
  SECTION:=QTI
  CATEGORY:=QTI-PACKAGES
  TITLE:= mkbootimg
  DEPENDS:= +core-include +libmincrypt
endef

define Package/mkbootimg/description
  mkbootimg module
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) $(LOCAL_SRC)/* $(PKG_BUILD_DIR)
endef

define Host/Prepare
	mkdir -p $(HOST_BUILD_DIR)/
	$(CP) $(LOCAL_SRC)/* $(HOST_BUILD_DIR)/
endef

define Host/Compile
	$(call Host/Compile/Default,LIBS=$(STAGING_DIR_HOSTPKG)/lib/libmincrypt.a)
endef

define Package/mkbootimg/compile
	@true
endef

define Package/mkbootimg/install
	@true
endef

define Host/Install
	$(INSTALL_DIR) $(STAGING_DIR_HOSTPKG)/bin
	$(CP) $(HOST_BUILD_DIR)/mkbootimg $(STAGING_DIR_HOSTPKG)/bin
endef


$(eval $(call BuildPackage,mkbootimg))
$(eval $(call HostBuild))
