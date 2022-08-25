#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=qtisqlite
PKG_VERSION:=3330000
PKG_RELEASE:=1

PKG_SOURCE:=sqlite-autoconf-$(PKG_VERSION).tar.gz
PKG_HASH:=106a2c48c7f75a298a7557bcc0d5f4f454e5b43811cc738b7ca294d6956bbb15
PKG_SOURCE_URL:=https://www.sqlite.org/2020/

PKG_LICENSE:=PUBLICDOMAIN
PKG_LICENSE_FILES:=

PKG_MAINTAINER:=

PKG_CPE_ID:=cpe:/a:sqlite:sqlite

PKG_FIXUP:=autoreconf

PKG_INSTALL:=1

PKG_CONFIG_DEPENDS := \
	CONFIG_SQLITE3_DYNAMIC_EXTENSIONS \
	CONFIG_SQLITE3_FTS3 \
	CONFIG_SQLITE3_FTS4 \
	CONFIG_SQLITE3_FTS5 \
	CONFIG_SQLITE3_JSON1 \
	CONFIG_SQLITE3_LIBEDIT \
	CONFIG_SQLITE3_READLINE \
	CONFIG_SQLITE3_RTREE \
	CONFIG_SQLITE3_SESSION

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

define Package/qtisqlite3/Default
  SUBMENU:=Database
  TITLE:=SQLite (v3.x) database engine
  URL:=http://www.sqlite.org/
endef

define Package/qtisqlite3/Default/description
 SQLite is a small C library that implements a self-contained, embeddable,
 zero-configuration SQL database engine.
endef

define Package/qtilibsqlite3
  $(call Package/qtisqlite3/Default)
  SECTION:=QTI
  CATEGORY:=QTI-PACKAGES
  DEPENDS:=+libpthread +zlib
  TITLE+= (library)
  ABI_VERSION:=0
endef

define Package/qtilibsqlite3/description
$(call Package/qtisqlite3/Default/description)
 This package contains the SQLite (v3.x) shared library, used by other
 programs.
endef

define Download/qtisqlite3
  FILE:=$(PKG_SOURCE)
  URL:=$(PKG_SOURCE_URL)
  HASH:=$(PKG_HASH)
endef

define Host/Prepare
	$(eval $(call Download,qtisqlite3))
	tar -zxvf $(TOPDIR)/dl/$(PKG_SOURCE) --strip-components 1 -C $(HOST_BUILD_DIR)
endef

define Package/qtilibsqlite3/config
  source "$(SOURCE)/Config-lib.in"
endef

define Package/qtisqlite3-cli
  $(call Package/qtisqlite3/Default)
  SECTION:=QTI
  CATEGORY:=QTI-PACKAGES
  DEPENDS := \
	  +qtilibsqlite3 \
	  +SQLITE3_LIBEDIT:libedit \
	  +SQLITE3_READLINE:libreadline \
	  +SQLITE3_READLINE:libncursesw
  TITLE+= (cli)
endef

define Package/qtisqlite3-cli/description
$(call Package/qtisqlite3/Default/description)
 This package contains a terminal-based front-end to the SQLite (v3.x) library
 that can evaluate queries interactively and display the results in multiple
 formats.
endef

define Package/qtisqlite3-cli/config
  source "$(SOURCE)/Config-cli.in"
endef

TARGET_CFLAGS += \
	-DHAVE_ISNAN \
	-DHAVE_MALLOC_USABLE_SIZE \
	-DSQLITE_ENABLE_UNLOCK_NOTIFY

CONFIGURE_ARGS += \
	--disable-debug \
	--disable-static-shell \
	--enable-shared \
	--enable-static \
	--enable-threadsafe \
	$(if $(CONFIG_SQLITE3_DYNAMIC_EXTENSIONS),--enable-dynamic-extensions,--disable-dynamic-extensions) \
	$(if $(CONFIG_SQLITE3_FTS3),--enable-fts3,--disable-fts3) \
	$(if $(CONFIG_SQLITE3_FTS3),--enable-fts4,--disable-fts4) \
	$(if $(CONFIG_SQLITE3_FTS3),--enable-fts5,--disable-fts5) \
	$(if $(CONFIG_SQLITE3_JSON1),--enable-json1,--disable-json1) \
	$(if $(CONFIG_SQLITE3_RTREE),--enable-rtree,--disable-rtree) \
	$(if $(CONFIG_SQLITE3_SESSION),--enable-session,--disable-session)

ifeq ($(CONFIG_SQLITE3_LIBEDIT),y)
CONFIGURE_ARGS+=--disable-readline
else ifeq ($(CONFIG_SQLITE3_READLINE),y)
CONFIGURE_ARGS+=--disable-editline
else
CONFIGURE_ARGS+=--disable-editline --disable-readline
endif

define Host/qtilibsqlite3/Install
	$(INSTALL_DIR) $(STAGING_DIR_HOSTPKG)/lib
	$(CP) $(HOST_BUILD_DIR)/.libs/libsqlite3.* $(STAGING_DIR_HOSTPKG)/lib
endef

define Host/qtisqlite3-cli/Install
	$(INSTALL_DIR) $(STAGING_DIR_HOSTPKG)/bin
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/sqlite3 $(STAGING_DIR_HOSTPKG)/bin
endef

#$(eval $(call BuildPackage,qtilibsqlite3))
#$(eval $(call BuildPackage,qtisqlite3-cli))
$(eval $(call HostBuild))
