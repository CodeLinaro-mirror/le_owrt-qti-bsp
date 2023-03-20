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
  USERID:=system=1000:system=1000 radio=1001:radio=1001 adb=2000:adb=2000 \
			wifi=1010:wifi=1010 input=1004:input=1004 qrtr=2906:qrtr=2906 \
			diag=2901:diag=2901 diag=2901:rebooters=1301 \
			:wakelock=3010 :readproc=3009 :kmsg=2902 :inet=3003 :net_admin=3005 :qwes=3013 \
           		:netdev=996 :net_raw=3004 :sdcard=1015
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
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/user_permissions.init $(1)/etc/init.d/
	$(INSTALL_DIR) $(1)/etc/scripts
	$(INSTALL_BIN) ./files/user_permissions.sh $(1)/etc/scripts/
endef

$(eval $(call BuildPackage,user_permissions))
