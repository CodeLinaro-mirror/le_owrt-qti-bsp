include $(TOPDIR)/rules.mk

PKG_NAME:=user_permissions
PKG_VERSION:=1.0
PKG_RELEASE:=1

SOURCE_DIR:=

include $(INCLUDE_DIR)/package.mk

define Package/user_permissions
  SECTION:=QTI
  CATEGORY:=QTI-PACKAGES
  TITLE:=User & Group Permissions
  USERID:=system=1000:system=1000 radio=1001:radio=1001 adb=2000:adb=2000
endef

define Package/user_permissions/description
 Initial set of global users and groups definitions.
endef

define Build/Prepare
	@true
endef

define Build/Compile
	@true
endef

define Package/$(PKG_NAME)/install
	@true
endef

$(eval $(call BuildPackage,user_permissions))
