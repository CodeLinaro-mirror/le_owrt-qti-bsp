include $(TOPDIR)/rules.mk

PKG_NAME:=linux-msm-headers
PKG_VERSION:=1.0
PKG_RELEASE:=1

SOURCE_DIR := $(TOPDIR)/src/kernel/msm-5.4/usr/include

include $(INCLUDE_DIR)/package.mk

define Package/linux-msm-headers-5.4
  SECTION:=QTI
  CATEGORY:=QTI-PACKAGES
  TITLE:=Linux MSM Headers
endef

define Package/linux-msm-headers-5.4/Description
	Linux MSM Headers.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) $(SOURCE_DIR)/audio $(PKG_BUILD_DIR)
endef

define Build/Configure
	@true
endef

define Build/Compile
	@true
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/audio $(1)/usr/include/
endef

define Package/linux-msm-headers-5.4/install
	@true
endef

$(eval $(call BuildPackage,linux-msm-headers-5.4))