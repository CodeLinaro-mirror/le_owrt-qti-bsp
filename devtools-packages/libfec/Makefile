include $(TOPDIR)/rules.mk

PKG_NAME:=libfec
PKG_VERSION:=1.0
PKG_RELEASE:=1
HOST_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

SOURCE_DIR:=$(TOPDIR)/src/OTA/system/extras/$(PKG_NAME)

HOST_CONFIGURE_ARGS += \
	--disable-shared

TARGET_CFLAGS += $(FPIC)  --disable-shared
HOST_CFLAGS += $(FPIC)


define Package/$(PKG_NAME)
	SECTION:=QTI
	CATEGORY:=QTI-PACKAGES
	TITLE:=$(PKG_NAME)

endef


define Package/$(PKG_NAME)/Description
	libfec  utility for fec calculations
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp  -rp $(SOURCE_DIR)/*  $(PKG_BUILD_DIR)
	$(Build/Patch)

endef

define Host/Prepare
	mkdir -p $(HOST_BUILD_DIR)
	#----------------------
	#  host /prepare
	# ---------------------
	cp -rp $(SOURCE_DIR)/*   $(HOST_BUILD_DIR)
	$(Host/Patch)

endef

define Host/compile
	$(warning "***libfec * HOST/Compile*")
endef
define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	#----------------------
	#  configure in host bin
	# ---------------------
	cp -rp $(SOURCE_DIR)/*   $(PKG_BUILD_DIR)
	$(Build/Patch)

endef

define Build/Compile
	#--------------------
	# libfec build/compile
	#---------------------
endef

define Package/$(PKG_NAME)/configure
	#----------------------
	# configure in libefec in host bin
	# ---------------------
endef

define Package/$(PKG_NAME)/compile
	#----------------------
	#  compile in libfec
	# ---------------------
endef
define Package/$(PKG_NAME)/install
	#------------------------------------
	#----- Copy FEC utility to bin folder
	#-------------------------------------
	cp -rf  $(HOST_BUILD_DIR)/libfec.la   $(STAGING_DIR_HOSTPKG)/lib/
	cp -rf  $(HOST_BUILD_DIR)/libfec.a   $(STAGING_DIR_HOSTPKG)/lib/
endef
#$(eval $(call BuildPackage,$(PKG_NAME)))
$(eval $(call HostBuild))
