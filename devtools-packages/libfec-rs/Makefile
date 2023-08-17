include $(TOPDIR)/rules.mk

PKG_NAME:=libfec-rs
PKG_VERSION:=1.0
PKG_RELEASE:=${AUTORELEASE}
PKG_FIXUP:=autoreconf

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://git.codelinaro.org/clo/la/platform/external/fec.git
PKG_SOURCE_VERSION:=caf_migration/LA.BR.1.3.6.c2_rb2.28
PKG_MIRROR_HASH:=b8363b991ab1b15d485252e8b243773a7887ecb4e525b62866c8aeb6871f8f4a
PKG_LICENSE:= LGPL-2.1+
PKG_SOURCE:=libfec-rs.tar.bz2
PKG_SOURCE_SUBDIR:=fec

HOST_CONFIGURE_ARGS += \
	--disable-shared \
	CFLAGS += -fPIC  -no-pie  --disable-shared \
	LDFLAGS += -fPIC  -no-pie --disable-shared\
	-fpic -fpie -pie


include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

TARGET_CFLAGS += $(FPIC)  --disable-shared
HOST_CFLAGS += $(FPIC)

define Package/libfec-rs
	SECTION:=QTI
	CATEGORY:=QTI-PACKAGES
	TITLE:=libfec-rs
endef


define Package/libfec-rs/Description
	Forward Error Correction (FEC) - Reed–Solomon  utility
endef

define Build/Configure
	mkdir -p $(PKG_BUILD_DIR)/sources
         $(warning "***libfec-rs * HOST/Configure*")
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(Build/Patch)
endef

define Host/Prepare
	mkdir -p $(HOST_BUILD_DIR)
	tar -xf $(DL_DIR)/$(PKG_SOURCE) -C  $(HOST_BUILD_DIR)
	cp  $(HOST_BUILD_DIR)/fec/*         $(HOST_BUILD_DIR)
	$(Host/Patch)
endef

define Host/compile
	$(warning "***libfec-rs * HOST/Compile*")
endef

define Build/Compile
	#--------------------
	# libfec_rs build/compile
	#---------------------
endef

define Package/$(PKG_NAME)/install
	#------------------------------------
	#----- Copy libfec_rs.la to lib folder
	#-------------------------------------
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/libfec_rs.la  $(STAGING_DIR_HOSTPKG)/lib/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
$(eval $(call HostBuild))
