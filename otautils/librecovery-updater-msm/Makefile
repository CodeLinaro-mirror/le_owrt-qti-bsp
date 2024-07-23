include $(TOPDIR)/rules.mk

PKG_NAME:=librecovery-updater-msm
PKG_VERSION:=1.0
PKG_LICENSE:=BSD-3-Clause
PKG_RELEASE:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

SOURCE_DIR:=$(TOPDIR)/src/OTA/device/qcom/common/recovery/oem-recovery

define Package/librecovery-updater-msm
  SECTION:=libs
  CATEGORY:=OTA
  TITLE:=librecovery-updater-msm
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp -r $(SOURCE_DIR)/* $(PKG_BUILD_DIR)
	$(Build/Patch)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR)
	mkdir -p $(STAGING_DIR)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/.libs/librecovery_updater_msm.a $(STAGING_DIR)/usr/lib
endef

define Package/librecovery-updater-msm/install
	@true
endef

$(eval $(call BuildPackage,librecovery-updater-msm))
