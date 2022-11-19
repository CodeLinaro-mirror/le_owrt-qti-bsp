include $(TOPDIR)/rules.mk

PKG_NAME:=gtest
PKG_VERSION:=1.0
PKG_RELEASE:=${AUTORELEASE}
PKG_FIXUP:= autoreconf
PKG_INSTALL:=1
PKG_LICENSE:=BSD-3-Clause

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://git.codelinaro.org/clo/la/platform/external/chromium_org/testing/gtest.git
PKG_SOURCE_VERSION:=caf_migration/LA.AF.1.1.1
PKG_MIRROR_HASH:=ecc37ead5c1efd1d28bfe5e81ae598f505fb8066a116473a9b6fe1ad5641fcb9

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/$(PKG_NAME)
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=gtest
	DEPENDS:=+libstdcpp
endef

define Package/$(PKG_NAME)/Description
	Google's framework for writing C++ tests
endef

CMAKE_OPTIONS += \
        -DCMAKE_INSTALL_INCLUDEDIR:PATH=include \
        -DCMAKE_INSTALL_LIBDIR:PATH=lib \
        -DBUILD_SHARED_LIBS=ON

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgtest.so $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgtest_main.so $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/gtest.pc $(1)/usr/lib/pkgconfig/
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgtest.so $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgtest_main.so $(1)/usr/lib/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
