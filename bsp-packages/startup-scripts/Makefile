include $(TOPDIR)/rules.mk

PKG_NAME:=usb-composition
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_LICENSE:=Apache-2.0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/target.mk

SOURCE_DIR:= $(TOPDIR)/src/system/core/usb

define Package/usb-composition
	SECTION:=QTI
	CATEGORY:=QTI-PACKAGES
	TITLE:= usb-composition
endef

define Package/usb-composition/description
  Scripts to set USB compositions
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

define Package/usb-composition/install
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
	$(INSTALL_BIN) ./files/usb.init $(1)/etc/init.d/usb.init
	$(INSTALL_BIN) ./files/create-firmwarelinks.init $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/block_procd.init $(1)/etc/init.d/
	$(INSTALL_DIR) $(1)/etc/scripts
	$(INSTALL_DIR) $(1)/mnt/sdcard
	ln -s /mnt/sdcard $(1)/sdcard
	$(INSTALL_BIN) ./files/createsymlinks.sh $(1)/etc/scripts
	$(INSTALL_BIN) ./files/automountsdcard.sh $(1)/etc/scripts
	$(INSTALL_DIR) $(1)/etc/hotplug.d/block
	$(INSTALL_DATA) ./files/automountsdcard $(1)/etc/hotplug.d/block/
	$(INSTALL_BIN) ./files/zram.init $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/init.zram.sh $(1)/etc/scripts
	$(INSTALL_BIN) ./files/ntp.init $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/ntp.config.sh $(1)/etc/init.d/

ifeq ($(BOARD), sdx75)
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/overlay_backup.sh $(1)/usr/bin/
	$(INSTALL_BIN) ./files/overlay_restore.sh $(1)/usr/bin/
	$(INSTALL_BIN) ./files/data-config-restore.init $(1)/etc/init.d/
endif

ifeq ($(BOARD), sdx85)
	$(INSTALL_DIR) $(1)/etc/hotplug.d/devcoredump
	$(INSTALL_DATA) ./files/devcd_rule $(1)/etc/hotplug.d/devcoredump/
endif
	$(INSTALL_BIN) ./files/proxy_vote.init $(1)/etc/init.d/
	$(INSTALL_DIR) $(1)/etc/hotplug.d/usb
	$(INSTALL_DATA) $(SOURCE_DIR)/usb-bind-rules $(1)/etc/hotplug.d/usb
endef

$(eval $(call BuildPackage,usb-composition))
$(eval $(call HostBuild))
