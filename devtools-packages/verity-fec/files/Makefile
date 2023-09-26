# Makefile for OpenWRT system

INCLUDE_DIR += $(TOPDIR)/src/system/core/include/
VERITY_CFLAGS += -I$(INCLUDE_DIR) \
	  -I$(STAGING_DIR_HOSTPKG)/include \
	  -I$(TOPDIR)/src/OTA/system/extras/libfec/include \
	  -I$(TOPDIR)/src/system/core/libsparse \
	  -I$(TOPDIR)/src/system/core/base/include \
          -Wundef \
          -Wno-trigraphs \
          -g -O0 \
          -fno-inline \
          -fno-short-enums  \
          -fPIC
	  
VERITY_LDFLAGS += -L$(STAGING_DIR_HOSTPKG)/lib  -fPIC \
           -lcrypto  -lsparse

RM := rm -rf

all: fec_utils  

fec_utils:
	$(CXX)  $(VERITY_CFLAGS)  $(VERITY_LDFLAGS) -I$(STAGING_DIR_HOSTPKG)/include  -L$(STAGING_DIR_HOSTPKG)/lib main.cpp  image.cpp  -o fec_utils  -lcrypto -lsparse -lbase -lz -lext4_utils -lcutils  -lpthread

clean:
	$(RM) bin
	$(RM) *.o
