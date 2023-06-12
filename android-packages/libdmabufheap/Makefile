include $(TOPDIR)/rules.mk

PKG_NAME:=libdmabufheap
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_FIXUP:= autoreconf

SOURCE_DIR := $(TOPDIR)/src/system/memory/libdmabufheap
KMEM_RULES_DIR := $(TOPDIR)/src/system/memory

include $(INCLUDE_DIR)/package.mk

define Package/libdmabufheap
  SECTION:=QTI
  CATEGORY:=QTI-PACKAGES
  TITLE:=Libdmabufheap Android
  DEPENDS:= +libbase +libion
endef

define Package/libdmabufheap/Description
	Build Android libdmabufheap.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) $(SOURCE_DIR)/* $(PKG_BUILD_DIR)/
endef


define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR)
	mkdir -p  $(1)/usr/lib
	mkdir -p  $(1)/usr/include
	mkdir -p  $(1)/usr/share/pkgconfig
	mkdir -p  $(1)/etc/hotplug.d/dma_heap
	$(CP) $(PKG_BUILD_DIR)/.libs/libdmabufheap.so* $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/include/* $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/libdmabufheap.pc $(1)/usr/share/pkgconfig
endef

define Package/libdmabufheap/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/.libs/libdmabufheap.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/etc/hotplug.d/dma_heap
	$(INSTALL_DATA) $(KMEM_RULES_DIR)/kmem-dmaheap-rules $(1)/etc/hotplug.d/dma_heap
endef

$(eval $(call BuildPackage,libdmabufheap))
