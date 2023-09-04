OTA_SCRIPTS_PATH = ${BUILD_DIR}/OTA/ota-scripts
RELEASE_TOOLS_PATH = $(TOPDIR)/src/OTA/build/tools/releasetools

define Ota/Build/releasetools-native
	rm -rf $(BUILD_DIR)/OTA
	mkdir -p $(OTA_SCRIPTS_PATH)
	( cd $(RELEASE_TOOLS_PATH); \
	  $(INSTALL_BIN) full_ota.sh $(OTA_SCRIPTS_PATH); \
	  $(INSTALL_BIN) incremental_ota.sh $(OTA_SCRIPTS_PATH); \
	  $(INSTALL_BIN) blockimgdiff.py $(OTA_SCRIPTS_PATH); \
	  $(INSTALL_BIN) common.py $(OTA_SCRIPTS_PATH); \
	  $(INSTALL_BIN) edify_generator.py $(OTA_SCRIPTS_PATH); \
	  $(INSTALL_BIN) img_from_target_files $(OTA_SCRIPTS_PATH); \
	  $(INSTALL_BIN) add_img_to_target_files.py  $(OTA_SCRIPTS_PATH); \
	  $(INSTALL_BIN) build_image.py $(OTA_SCRIPTS_PATH); \
	  $(INSTALL_BIN) ota_from_target_files $(OTA_SCRIPTS_PATH); \
	  $(INSTALL_BIN) rangelib.py $(OTA_SCRIPTS_PATH); \
	  $(INSTALL_BIN) sparse_img.py $(OTA_SCRIPTS_PATH); \
	  $(CP) images_to_upgrade.txt $(OTA_SCRIPTS_PATH); \
	  ifdef CONFIG_OTA_PACKAGE_VERIFICATION; \
		$(INSTALL_BIN) private.pem $(OTA_SCRIPTS_PATH); \
	  endif; \
	  cd -; \
	)
	$(INSTALL_BIN) $(TOPDIR)/src/OTA/device/qcom/common/releasetools.py $(OTA_SCRIPTS_PATH)
endef
