include $(TOPDIR)/rules.mk

# Name, version and release number
# The name and version of your package are used to define the variable to point to the build directory of your package: $(PKG_BUILD_DIR)
PKG_NAME:=libmincrypt
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_FIXUP:=autoreconf

# Source settings (i.e. where to find the source codes)
# This is a custom variable, used below
SOURCE_DIR:=$(TOPDIR)/src/system/core/libmincrypt

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

# Package definition; instructs on how and where our package will appear in the overall configuration menu ('make menuconfig')
define Package/libmincrypt
	SECTION:=QTI
	CATEGORY:=QTI-PACKAGES
	TITLE:=libmincrypt
	DEPENDS:=+core-include
endef

# Package description; a more verbose description on what our package does
define Package/libmincrypt/description
	Libmincrypt package
endef

# Package preparation instructions; create the build directory and copy the source code.
define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp -rp $(SOURCE_DIR)/* $(PKG_BUILD_DIR)
endef

define Host/Prepare
	mkdir -p $(HOST_BUILD_DIR)
	cp -rp $(SOURCE_DIR)/* $(HOST_BUILD_DIR)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR)
	mkdir -p  $(STAGING_DIR)/usr/lib
	mkdir -p  $(STAGING_DIR)/usr/share/pkgconfig
	mkdir -p  $(STAGING_DIR)/usr/include
	$(CP) $(PKG_BUILD_DIR)/.libs/libmincrypt.so* $(STAGING_DIR)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/libmincrypt.pc $(STAGING_DIR)/usr/share/pkgconfig/
endef

define Package/libmincrypt/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/.libs/libmincrypt.so* $(1)/usr/lib/
endef

# This command is always the last, it uses the definitions and variables we give above in order to get the job done

$(eval $(call BuildPackage,libmincrypt))
$(eval $(call HostBuild))
