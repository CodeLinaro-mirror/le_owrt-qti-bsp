include $(TOPDIR)/rules.mk

PKG_NAME:=bsdiff-ota
PKG_VERSION:=1.0
PKG_LICENSE:=BSD-3-Clause
PKG_RELEASE:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

SOURCE_DIR:=$(TOPDIR)/src/OTA/external/bsdiff/
PKG_BUILD_DEPENDS:=bsdiff-ota/host
HOST_BUILD_DEPENDS:=bzip2/host libdivsufsort/host

HOST_LDFLAGS += -L$(STAGING_DIR_HOST)/lib \
                -L$(STAGING_DIR_HOSTPKG)/lib \
                -ldivsufsort -Wl,-rpath=$(STAGING_DIR_HOST)/lib

define Package/bsdiff-ota
  SECTION:=external
  CATEGORY:=OTA
  TITLE:= Binary diff tool
  DEPENDS:=+libdivsufsort
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp -rp $(SOURCE_DIR)/* $(PKG_BUILD_DIR)
endef

define Host/Prepare
	mkdir -p $(HOST_BUILD_DIR)
	cp -rp $(SOURCE_DIR)/* $(HOST_BUILD_DIR)
endef

define Host/Install
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/bsdiff $(STAGING_DIR_HOST)/bin/
endef

define Package/bsdiff-ota/install
	@true
endef

$(eval $(call BuildPackage,bsdiff-ota))
$(eval $(call HostBuild))
