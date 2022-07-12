include $(TOPDIR)/rules.mk

PKG_NAME:=edk2
PKG_VERSION:=1.0
PKG_RELEASE:=1

SOURCE_DIR:= $(TOPDIR)/src/bootable/bootloader/edk2

include $(INCLUDE_DIR)/package.mk

MAKE_FLAGS = TARGET_ARCHITECTURE="$(ARCH)" \
	CLANG_PREFIX="$(ARCH)-openwrt-linux-" \
	HOST_ARCH="X64" \
	BUILDDIR="$(PKG_BUILD_DIR)" \
	BOOTLOADER_OUT="$(PKG_BUILD_DIR)/out" \
	ENABLE_LE_VARIANT="true" \
	VERIFIED_BOOT_LE="1" \
	ENABLE_SYSTEMD_BOOTSLOT="0" \
	EDK_TOOLS_PATH="$(PKG_BUILD_DIR)/BaseTools" \
	VERITY_LE="0" \
	INIT_BIN_LE="/sbin/init" \
	EARLY_ETH_ENABLED="0" \
	BOOTLOADER_PLATFORM="sdxlemur" \
	NAND_SQUASHFS_SUPPORT="0" \
	USER_BUILD_VARIANT="0" \
	DEVICE_STATUS=DEFAULT_UNLOCK="true" \
	SIGNED_KERNEL="1"

define Package/edk2
  SECTION:=QTI
  CATEGORY:=QTI-PACKAGES
  TITLE:=UEFI bootloader
endef

define Package/edk2/description
 UEFI bootloader
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp -rp $(SOURCE_DIR)/* $(PKG_BUILD_DIR)
	$(Build/Patch)
endef

define Build/Configure
	@true
endef

define Package/edk2/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/Build/DEBUG_CLANG35/FV/abl.elf $(1)/usr/bin
endef

$(eval $(call BuildPackage,edk2))
