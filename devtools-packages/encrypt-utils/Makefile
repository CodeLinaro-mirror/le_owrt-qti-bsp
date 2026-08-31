include $(TOPDIR)/rules.mk

PKG_NAME:=encrypt-utils
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

PYTHON ?= python3

check_pycryptodome := $(shell $(PYTHON) -c "import Crypto" 2>/dev/null && echo yes || echo no)

ifeq ($(check_pycryptodome),no)
$(error pycryptodome (Crypto module) not found in host Python environment )
endif

#  host dependency (optional, minimal)
PKG_BUILD_DEPENDS :=
HOST_BUILD_DEPENDS := cryptsetup/host

define Package/encrypt-utils
	SECTION:=QTI
	CATEGORY:=QTI-PACKAGES
	TITLE:=encrypt-utils
endef

define Package/encrypt-utils/Description
	Utilities to generate encrypted images using dm-crypt (cryptsetup).
endef

# --------------------------------
# Host Build Steps
# --------------------------------
define Host/Prepare
	mkdir -p $(HOST_BUILD_DIR)
endef

define Host/Compile
	#  FAIL build if cryptsetup missing
	which cryptsetup || \
		(echo "ERROR: cryptsetup not found. Install it." && false)

	#  FAIL build if losetup missing
	which losetup || \
		(echo "ERROR: losetup not found. Install util-linux." && false)

endef

define Host/Install
	# install script to host bin
endef

# --------------------------------
# Build invoke
# --------------------------------
$(eval $(call BuildPackage,encrypt-utils))
$(eval $(call HostBuild))
