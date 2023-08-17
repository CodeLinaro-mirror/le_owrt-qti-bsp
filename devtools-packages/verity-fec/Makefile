
include $(TOPDIR)/rules.mk

PKG_NAME:=verity-fec
PKG_VERSION:=1.0

CPPFLAGS += "-I$(LOCAL_SRC)/../../core/include"
LOCAL_SRC:=$(TOPDIR)/src/OTA/system/extras/verity/fec/

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk



define Package/verity-fec
	SECTION:=QTI
	CATEGORY:=QTI-PACKAGES
	TITLE:=verity-fec
endef

define Package/verity-fec/Description
	Build Android fec binary need to calculate the FEC data on the image
endef

define Host/Prepare
	mkdir -p $(HOST_BUILD_DIR)
	cp -rp $(LOCAL_SRC)*.*   $(HOST_BUILD_DIR)
	cp  files/Makefile       $(HOST_BUILD_DIR)

endef

define Host/Compile
	CFLAGS="$(TARGET_CPPFLAGS) $(TARGET_CFLAGS)" \
	LIBS= -lsparse -lcrypto \
	make -C $(HOST_BUILD_DIR)
endef

define Host/Install
	$(warning "***verity-fec * Install")
	#------------------------------------
	#----- Copy FEC utility to bin folder
	#-------------------------------------
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/fec  $(STAGING_DIR_HOSTPKG)/bin/
	
endef
$(eval $(call BuildPackage,verity-fec))
$(eval $(call HostBuild))
