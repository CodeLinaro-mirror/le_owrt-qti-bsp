include $(TOPDIR)/rules.mk

PKG_NAME:=dmverity-utils
PKG_VERSION:=1.0
PKG_RELEASE:=1
#PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk



LOCAL_SRC:= $(TOPDIR)/src/system/extras/verity

PKG_BUILD_DEPENDS := dmverity-utils/host   image-utils/host
#libfec/host  libfec-rs/host 
HOST_BUILD_DEPENDS := libsparse/host
define Package/dmverity-utils
	SECTION:=QTI
	CATEGORY:=QTI-PACKAGES
	TITLE:=dmverity-utils
	DEPENDS:=+libsparse +core-include +image-utils
#+libfec-rs  +libfec 	
endef

define Package/dmverity-utils/Description
	dm-veriy and required utils which  support  generation of metadata , hash tree generation  which
	are used for dm-verity enablement
endef

define Host/Prepare
	mkdir -p $(HOST_BUILD_DIR)
	cp -rp $(LOCAL_SRC)/*  $(HOST_BUILD_DIR)
	cp  files/Makefile     $(HOST_BUILD_DIR)

endef

define Host/Compile
	CFLAGS="$(TARGET_CPPFLAGS) $(TARGET_CFLAGS)" \
	make -C $(HOST_BUILD_DIR) \
	LIBS= -lsparse -lcrypto
endef

define Host/Install
	#--------------------
	# DM-Verity HOST install
	#---------------------
	cp -rf  $(HOST_BUILD_DIR)/build_verity_tree $(STAGING_DIR_HOSTPKG)/bin/
	cp -rf  $(HOST_BUILD_DIR)/build_verity_metadata.py $(STAGING_DIR_HOSTPKG)/bin/
	cp -rf  $(HOST_BUILD_DIR)/verity.pk8      $(STAGING_DIR_HOSTPKG)/bin/
	cp -rf  $(HOST_BUILD_DIR)/verity.x509.pem   $(STAGING_DIR_HOSTPKG)/bin/
endef

$(eval $(call BuildPackage,dmverity-utils))
$(eval $(call HostBuild))
