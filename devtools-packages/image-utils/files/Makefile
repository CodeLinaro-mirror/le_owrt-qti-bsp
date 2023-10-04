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


all:  append2simg  simg2img  img2simg

append2simg:
	 $(CXX)  --static $(VERITY_CFLAGS)  $(VERITY_LDFLAGS) -I$(STAGING_DIR_HOSTPKG)/include  -L$(STAGING_DIR_HOSTPKG)/lib  append2simg.c  -o append2simg   -lcrypto -lsparse  -lz

simg2img:
	 $(CXX)   $(VERITY_CFLAGS)  $(VERITY_LDFLAGS) -I$(STAGING_DIR_HOSTPKG)/include  -L$(STAGING_DIR_HOSTPKG)/lib  simg2img.c  -o simg2img   -lcrypto -lsparse  -lz

img2simg:
	$(CXX)  $(VERITY_LDFLAGS) -I$(STAGING_DIR_HOSTPKG)/include  -L$(STAGING_DIR_HOSTPKG)/lib img2simg.c -o img2simg  -lcrypto -lsparse   -lz

simg2simg:
	$(CXX)  $(VERITY_CFLAGS)  $(VERITY_LDFLAGS) -I$(STAGING_DIR_HOSTPKG)/include  -L$(STAGING_DIR_HOSTPKG)/lib simg2simg.c   -o simg2simg -lcrypto -lsparse -lbase -lz

clean:
	$(RM) bin
	$(RM) *.o
