include $(TOPDIR)/rules.mk

PKG_NAME:=bouncycastle
PKG_VERSION:=1.0
PKG_RELEASE:=${AUTORELEASE}
PKG_LICENSE:=MIT & BSD

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://git.codelinaro.org/clo/la/platform/external/bouncycastle.git
PKG_SOURCE_VERSION:=caf_migration/LA.AF.1.1.1
PKG_MIRROR_HASH:=6041b4c02eb2ff63080d9c3414202c7c6e00dccb9fecad2cd189f32d9ba3cb01
PKG_SOURCE:=$(PKG_SOURCE_SUBDIR).tar.xz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)


include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

define Package/bouncycastle
	SECTION:=QTI
	CATEGORY:=QTI-PACKAGES
	TITLE:=bouncycastle
	DEPENDS:=
endef

define Package/bouncycastle/Description
	Bouncy Castle is a collection of APIs used in cryptography and signing tools.
endef


define Build/Configure
	mkdir -p $(PKG_BUILD_DIR)/sources
	echo "Main-Class: com.android.verity.VeritySigner" > $(PKG_BUILD_DIR)/VeritySigner.mf
	echo "Main-Class: com.android.verity.BootSignature" > $(PKG_BUILD_DIR)/BootSignature.mf
	echo "Main-Class: com.android.verity.VerityVerifier" > $(PKG_BUILD_DIR)/VerityVerifier.mf
	echo "Main-Class: com.android.verity.BootKeystore" > $(PKG_BUILD_DIR)/KeystoreSigner.mf

	find $(PKG_BUILD_DIR)/bcprov/ -name "*.java" > $(PKG_BUILD_DIR)/sources/bcprov_java_source_list
	find $(PKG_BUILD_DIR)/bcpkix/ -name "*.java" > $(PKG_BUILD_DIR)/sources/bcpkix_java_source_list
endef


define Build/Compile
	rm -fr $(PKG_BUILD_DIR)/classes
	rm -fr $(PKG_BUILD_DIR)/libs

	mkdir -p $(PKG_BUILD_DIR)/classes
	mkdir -p $(PKG_BUILD_DIR)/libs

	/usr/bin/javac -J-Xmx1024M    -Xmaxerrs 9999999   -encoding UTF-8  -g    \
		-d $(PKG_BUILD_DIR)/classes  @$(PKG_BUILD_DIR)/sources/bcprov_java_source_list
	#--------------------------------
	# create bcprov JAR
	#--------------------------------
	/usr/bin/jar -cf $(PKG_BUILD_DIR)/libs/bcprov_jar.jar -C $(PKG_BUILD_DIR)/classes .

	#--------------------------------
	# compile bcpkix
	#--------------------------------
	/usr/bin/javac -J-Xmx1024M  -Xmaxerrs 9999999  -encoding UTF-8  -g  \
	-classpath $(PKG_BUILD_DIR)/libs/bcprov_jar.jar   -d $(PKG_BUILD_DIR)/classes \
	@$(PKG_BUILD_DIR)/sources/bcpkix_java_source_list

	#--------------------------------
	# create bcprov + bcpkix JAR
	#--------------------------------
	/usr/bin/jar -cf $(PKG_BUILD_DIR)/libs/bcprov_bcpkix_jar.jar -C $(PKG_BUILD_DIR)/classes .
	#--------------------------------
	# create Signer Utilities
	#--------------------------------
	find $(PKG_BUILD_DIR)  -name "*.java" > $(PKG_BUILD_DIR)/sources/VeritySigner_source
	/usr/bin/javac -J-Xmx1024M -Xmaxerrs 9999999 -encoding UTF-8  \
	-g -classpath $(PKG_BUILD_DIR)/libs/bcprov_bcpkix_jar.jar  \
	-d $(PKG_BUILD_DIR)/classes @$(PKG_BUILD_DIR)/sources/VeritySigner_source

	/usr/bin/jar -cfm $(PKG_BUILD_DIR)/VeritySigner.jar $(PKG_BUILD_DIR)/VeritySigner.mf -C $(PKG_BUILD_DIR)/classes .

	echo "#! /bin/sh " >> $(PKG_BUILD_DIR)/verity_signer
	echo "   "  >> $(PKG_BUILD_DIR)/verity_signer

	echo "java -Xmx512M -jar $(PKG_BUILD_DIR)/VeritySigner.jar   xxx@   " >> $(PKG_BUILD_DIR)/verity_signer
	sed  -i  s/xxx/`echo -e '\x24'`/ $(PKG_BUILD_DIR)/verity_signer
	#--------------------------------
	# create VerityVerifier JAR
	#--------------------------------
	    /usr/bin/jar -cfm $(PKG_BUILD_DIR)/libs/VerityVerifier.jar $(PKG_BUILD_DIR)/VerityVerifier.mf -C $(PKG_BUILD_DIR)/classes .

	#--------------------------------
	# create BootSignture JAR
	#--------------------------------
	    /usr/bin/jar -cfm  $(PKG_BUILD_DIR)/libs/BootSignature.jar  $(PKG_BUILD_DIR)/BootSignature.mf -C  $(PKG_BUILD_DIR)/classes .

	#--------------------------------
	# create VeritSigner JAR
	#--------------------------------
	    /usr/bin/jar -cfm  $(PKG_BUILD_DIR)/libs/VeritSigner.jar  $(PKG_BUILD_DIR)/VeritySigner.mf -C  $(PKG_BUILD_DIR)/classes .

	#--------------------------------
	# create BootKeystoreSigner JAR
	#--------------------------------
	    /usr/bin/jar -cfm  $(PKG_BUILD_DIR)/libs/BootKeystoreSigner.jar  $(PKG_BUILD_DIR)/KeystoreSigner.mf -C  $(PKG_BUILD_DIR)/classes .

endef

define Package/bouncycastle/install
	#----------------------
	#  install in host bin
	# ---------------------
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/verity_signer $(STAGING_DIR_HOSTPKG)/bin/
	 install -m 755 $(PKG_BUILD_DIR)/libs/VeritSigner.jar $(STAGING_DIR_HOSTPKG)/lib/VeritSigner.jar

endef

$(eval $(call BuildPackage,bouncycastle))
$(eval $(call HostBuild))
