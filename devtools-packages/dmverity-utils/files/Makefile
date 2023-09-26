# Makefile for OpenWRT system

INCLUDE_DIR += $(TOPDIR)/src/system/core/include/
VERITY_CFLAGS += -I$(INCLUDE_DIR) \
	  -I$(STAGING_DIR_HOSTPKG)/include \
	  -I$(TOPDIR)/src/OTA/system/extras/libfec/include \
	  -I$(TOPDIR)/src/system/core/libsparse \
	  -I$(TOPDIR)/src/system/core/base/include \
	  -Wundef \
	  -Wno-trigraphs \
	  -g -O0

VERITY_LDFLAGS +=  -L$(STAGING_DIR_HOSTPKG)/lib  -L$(STAGING_DIR_HOST)/lib

RM := rm -rf

all: verity_tree

verity_tree:
	$(CXX)  $(VERITY_LDFLAGS) -I$(STAGING_DIR_HOSTPKG)/include -L$(STAGING_DIR_HOSTPKG)/lib build_verity_tree.cpp -o build_verity_tree  -Wl,-Bstatic -lcrypto -lsparse -lz -Wl,-Bdynamic -pthread 

clean:
	$(RM) bin
	$(RM) *.o
