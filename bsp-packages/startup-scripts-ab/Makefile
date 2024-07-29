include $(TOPDIR)/rules.mk

PKG_NAME:=usb-composition-ab
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_LICENSE:=Apache-2.0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/target.mk

SOURCE_DIR:= $(TOPDIR)/src/system/core/usb

define Package/usb-composition-ab
	SECTION:=QTI
	CATEGORY:=QTI-PACKAGES
	TITLE:= usb-composition-ab
endef

define Package/usb-composition-ab/description
  Scripts to set USB compositions A/B
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp -rp $(SOURCE_DIR)/* $(PKG_BUILD_DIR)
	$(Build/Patch)
endef

define Host/Prepare
	@true
endef

define Build/Compile
	@true
endef

define Package/usb-composition-ab/install
	$(INSTALL_DIR) $(1)/etc/usb
	$(INSTALL_BIN) -b -m 0644 /dev/null $(1)/etc/usb/boot_hsic_comp
	$(INSTALL_BIN) -b -m 0644 /dev/null $(1)/etc/usb/boot_hsusb_comp
	echo $(USB_COMPOSITION) > $(1)/etc/usb/boot_hsusb_comp
	$(INSTALL_DIR) $(1)/sbin/usb
	$(INSTALL_DIR) $(1)/sbin/usb/compositions
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/usb_composition $(1)/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/start_usb $(1)/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/compositions/* -m 755 $(1)/sbin/usb/compositions
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/target $(1)/sbin/usb
	$(INSTALL_DIR) $(1)/sbin/usb/debugger
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/debuger/debugFiles -D $(1)/sbin/usb/debugger/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/debuger/help -D $(1)/sbin/usb/debugger/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/debuger/usb_debug -D $(1)/sbin/usb/debugger/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ../startup-scripts/files/usb.init $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/ab-updater.init $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/mounts-ab.init $(1)/etc/init.d/
	$(INSTALL_DIR) $(1)/etc/scripts
	$(INSTALL_DIR) $(1)/mnt/sdcard
	$(INSTALL_BIN) ./files/mounts-ab.sh $(1)/etc/scripts
ifneq ($(BOARD), sdx35)
	$(INSTALL_BIN) ./files/partition-symlinks.init $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/partition-symlinks.sh $(1)/etc/scripts
endif
	$(INSTALL_BIN) ../startup-scripts/files/automountsdcard.sh $(1)/etc/scripts
	$(INSTALL_DIR) $(1)/etc/hotplug.d/block
	$(INSTALL_DATA) ../startup-scripts/files/automountsdcard $(1)/etc/hotplug.d/block/
ifeq ($(BOARD), sdx35)
	$(INSTALL_BIN) ./files/zram.init $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/init.zram.sh $(1)/etc/scripts
endif

endef

$(eval $(call BuildPackage,usb-composition-ab))
$(eval $(call HostBuild))
