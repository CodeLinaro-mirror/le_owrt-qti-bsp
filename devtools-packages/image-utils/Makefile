include $(TOPDIR)/rules.mk

PKG_NAME:=image-utils
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

LOCAL_SRC:= $(TOPDIR)/src/system/core/libsparse

PKG_BUILD_DEPENDS := image-utils/host
HOST_BUILD_DEPENDS := libsparse/host
define Package/image-utils
	SECTION:=QTI
	CATEGORY:=QTI-PACKAGES
	TITLE:=image-utils
	DEPENDS:=+libsparse  +core-include
endef

define Package/image-utils/Description
	Image utils will add utils which can appending images, sparse to unsparse images.
endef

define Host/Prepare
	mkdir -p $(HOST_BUILD_DIR)
	cp -rp $(LOCAL_SRC)/append2simg.c  $(HOST_BUILD_DIR)
	cp -rp $(LOCAL_SRC)/simg2img.c     $(HOST_BUILD_DIR)
	cp -rp $(LOCAL_SRC)/img2simg.c     $(HOST_BUILD_DIR)
	cp -rp $(LOCAL_SRC)/simg2simg.c    $(HOST_BUILD_DIR)
	cp  files/Makefile       $(HOST_BUILD_DIR)

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
	cp -rf  $(HOST_BUILD_DIR)/append2simg   $(STAGING_DIR_HOSTPKG)/bin/
	cp -rf  $(HOST_BUILD_DIR)/simg2img      $(STAGING_DIR_HOSTPKG)/bin/
	cp -rf  $(HOST_BUILD_DIR)/img2simg      $(STAGING_DIR_HOSTPKG)/bin/
	cp -rf  $(HOST_BUILD_DIR)/img2simg      $(STAGING_DIR_HOST)/bin/
	cp -rf  $(HOST_BUILD_DIR)/simg2simg.c   $(STAGING_DIR_HOSTPKG)/bin/
endef

$(eval $(call BuildPackage,image-utils))
$(eval $(call HostBuild))
