#Copyright (C) 2017 Khem Raj <raj.khem@gmail.com>
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT
#SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
#DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
#OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
#THE USE OR OTHER DEALINGS IN THE SOFTWARE.

include $(TOPDIR)/rules.mk

PKG_NAME:=libexecinfo
PKG_VERSION:=1.1

#filename of original sources
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2

#where to download the sources from (directory)
PKG_SOURCE_URL:= http://distcache.freebsd.org/local-distfiles/itetcu

#A checksum to validate the download. It can be either a MD5 or SHA256 checksum, but SHA256 should be used
PKG_HASH:=c9a21913e7fdac8ef6b33250b167aa1fc0a7b8a175145e26913a4c19d8a59b1f


PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

TARGET_CFLAGS += -fno-omit-frame-pointer  -D_GNU_SOURCE

include $(INCLUDE_DIR)/package.mk

define Package/libexecinfo
  SECTION:=QTI
  CATEGORY:=QTI-PACKAGES
  TITLE:=Libexecinfo
endef

define Package/libexecinfo/Description
	A quick-n-dirty BSD licensed clone of the GNU libc backtrace facility
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR)
	mkdir -p $(1)/usr/include
	mkdir -p $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/*.h $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/libexecinfo.so* $(1)/usr/lib/
	ln -s $(PKG_BUILD_DIR)/libexecinfo.so.1 $(1)/usr/lib/libexecinfo.so
endef

define Package/libexecinfo/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/libexecinfo.so* $(1)/usr/lib/
	ln -s /usr/lib/libexecinfo.so.1 $(1)/usr/lib/libexecinfo.so
endef

$(eval $(call BuildPackage,libexecinfo))
