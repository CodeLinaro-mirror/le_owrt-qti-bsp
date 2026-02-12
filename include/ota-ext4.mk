.NOTPARALLEL:
OTA_TARGET_FILES_EXT4 = "target-files-ext4.zip"
OTA_TARGET_FILES_EXT4_DEST = "target-files-ext4-dest.zip"
OTA_FULL_UPDATE_EXT4 = "full_update_ext4.zip"
OTA_INCREMENTAL_UPDATE_EXT4 = "incremental_update_ext4.zip"
IMAGE_SYSTEM_MOUNT_POINT_EXT4 = "/system"
IMAGE_SYSTEMRW_MOUNT_POINT_EXT4 = "/overlay"
OTA_TARGET_FILES_EXT4_PATH = $(IMAGE_PRODUCTS_DIR)/$(OTA_TARGET_FILES_EXT4)
OTA_TARGET_FILES_EXT4_DEST_PATH = $(IMAGE_PRODUCTS_DIR)/$(OTA_TARGET_FILES_EXT4_DEST)
OTA_FULL_UPDATE_EXT4_PATH = $(IMAGE_PRODUCTS_DIR)/$(OTA_FULL_UPDATE_EXT4)
OTA_INCREMENTAL_UPDATE_EXT4_PATH = $(IMAGE_PRODUCTS_DIR)/$(OTA_INCREMENTAL_UPDATE_EXT4)
OTA_TARGET_IMAGE_ROOTFS_EXT4 = ${BUILD_DIR}/OTA/ota-target-image-ext4
MACHINE_FILESMAP_FULL_PATH_EXT4 = $(TOPDIR)/owrt-qti-bsp/conf/machine/filesmap/sdx75-emmc-filesmap
SIGN_OTA_PACKAGE = ""
SYSTEMRW_UPDATE = ""
ifeq ($(CONFIG_OTA_PACKAGE_VERIFICATION), y)
	SIGN_OTA_PACKAGE = "--sign"
endif

ifeq ($(CONFIG_TARGET_sdx75), y)
        SYSTEMRW_UPDATE = "--systemrw_update"
endif

ifeq ($(CONFIG_TARGET_sdx85), y)
        SYSTEMRW_UPDATE = "--systemrw_update"
endif

define Ota/Build/compute_sha1
	mkdir -p ${TARGET_DIR}/recoveryupgrade; \
	sha1sum ${IMAGE_PRODUCTS_DIR}/boot.img | cut -f 1 -d ' ' > ${TARGET_DIR}/recoveryupgrade/recoveryimg_sha1; \
	stat --printf="%s" ${IMAGE_PRODUCTS_DIR}/boot.img > ${TARGET_DIR}/recoveryupgrade/recoveryimg_length; \
	sha1sum ${IMAGE_PRODUCTS_DIR}/../recovery/recoveryfs.img | cut -f 1 -d ' ' > ${TARGET_DIR}/recoveryupgrade/recoveryfsimg_sha1; \
	stat --printf="%s" ${IMAGE_PRODUCTS_DIR}/../recovery/recoveryfs.img > ${TARGET_DIR}/recoveryupgrade/recoveryfsimg_length
endef

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
	  ifdef CONFIG_OTA_PACKAGE_VERIFICATION; \
		$(INSTALL_BIN) private.pem $(OTA_SCRIPTS_PATH); \
	  endif; \
	  cd -; \
	)
	$(INSTALL_BIN) $(TOPDIR)/src/OTA/device/qcom/common/releasetools.py $(OTA_SCRIPTS_PATH)
endef

define Ota/Build/gen_ota_full_zip_ext4
	(cd $(BUILD_DIR)/OTA/ota-scripts; \
	rm -rf update_ext4.zip; \
	./full_ota.sh ${OTA_TARGET_FILES_EXT4_PATH} ${IMAGE_ROOTFS} ext4 --block $(SYSTEMRW_UPDATE) --system_path ${IMAGE_SYSTEM_MOUNT_POINT_EXT4} $(SIGN_OTA_PACKAGE); \
	cp update_ext4.zip ${OTA_FULL_UPDATE_EXT4_PATH}; \
	mv ota_debug.txt ota_debug_ext4.txt; \
	)
endef

define Ota/Build/target-files-zip-ext4
	rm -rf $(OTA_TARGET_IMAGE_ROOTFS_EXT4)
	rm -rf $(OTA_TARGET_FILES_EXT4_PATH)

	mkdir -p $(OTA_TARGET_IMAGE_ROOTFS_EXT4)
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/BOOTABLE_IMAGES
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/DATA
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/META
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/OTA
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/RECOVERY
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/SYSTEM
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/RADIO
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/IMAGES
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/DTBO
	mkdir -p  ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/BOOT/RAMDISK

	echo "base image rootfs: $(IMAGE_ROOTFS)"
	echo "recovery image rootfs: ${IMAGE_ROOTFS}/../recovery/root-$(BOARD)"

	# if exists copy filesmap into RADIO directory
	[[ ! -z ${MACHINE_FILESMAP_FULL_PATH_EXT4} ]] && install -m 755 ${MACHINE_FILESMAP_FULL_PATH_EXT4} ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/RADIO/filesmap

	cp $(IMAGE_PRODUCTS_DIR)/boot.img $(OTA_TARGET_IMAGE_ROOTFS_EXT4)/BOOTABLE_IMAGES/boot.img
	stat --printf="boot_image_size=%s\n" ${IMAGE_PRODUCTS_DIR}/boot.img >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/META/misc_info.txt
	cp $(IMAGE_PRODUCTS_DIR)/boot.img $(OTA_TARGET_IMAGE_ROOTFS_EXT4)/BOOTABLE_IMAGES/recovery.img
	cp $(IMAGE_PRODUCTS_DIR)/system.img $(OTA_TARGET_IMAGE_ROOTFS_EXT4)/IMAGES/system.img
	stat --printf="system_image_size=%s\n" ${IMAGE_PRODUCTS_DIR}/system.img >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/META/misc_info.txt
	cp $(IMAGE_PRODUCTS_DIR)/system.map $(OTA_TARGET_IMAGE_ROOTFS_EXT4)/IMAGES/system.map
        cp $(IMAGE_PRODUCTS_DIR)/systemrw.img $(OTA_TARGET_IMAGE_ROOTFS_EXT4)/IMAGES/systemrw.img
        stat --printf="systemrw_image_size=%s\n" ${IMAGE_PRODUCTS_DIR}/systemrw.img >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/META/misc_info.txt
        if [ "$(CONFIG_TARGET_sdx75)" = "y" ]; then \
                cp $(IMAGE_PRODUCTS_DIR)/systemrw.map $(OTA_TARGET_IMAGE_ROOTFS_EXT4)/IMAGES/systemrw.map; \
        fi
        if [ "$(CONFIG_TARGET_sdx85)" = "y" ]; then \
                cp $(IMAGE_PRODUCTS_DIR)/systemrw.map $(OTA_TARGET_IMAGE_ROOTFS_EXT4)/IMAGES/systemrw.map; \
        fi
	cp $(IMAGE_PRODUCTS_DIR)/userdata.img $(OTA_TARGET_IMAGE_ROOTFS_EXT4)/IMAGES/userdata.img
	cp $(IMAGE_PRODUCTS_DIR)/userdata.map $(OTA_TARGET_IMAGE_ROOTFS_EXT4)/IMAGES/userdata.map

	if [ $(CONFIG_OTA_RECOVERY_UPDATE) == y ]; then \
		cp $(IMAGE_PRODUCTS_DIR)/../recovery/recoveryfs.img $(OTA_TARGET_IMAGE_ROOTFS_EXT4)/BOOTABLE_IMAGES/recovery-unsparsed.ext4; \
		echo recovery_upgrade_supported=1 >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/META/misc_info.txt; \
	fi

	# if dtbo.img file exist then copy
	if [ -f $(TOPDIR)/bin/targets/sdx65/dtbo.img ]; then \
	  cp $(TOPDIR)/bin/targets/sdx65/dtbo.img $(OTA_TARGET_IMAGE_ROOTFS_EXT4)/IMAGES/dtbo.img; \
	fi

	# copy the contents of system rootfs
	cp -r $(IMAGE_ROOTFS)/. $(OTA_TARGET_IMAGE_ROOTFS_EXT4)/SYSTEM/.
	#cd $(OTA_TARGET_IMAGE_ROOTFS_EXT4)/SYSTEM
	#rm -rf var/run
	#ln -snf ../run var/run

	# copy the contents of system overlayfs
	cp -r $(IMAGE_ROOTFS)/overlay/. $(OTA_TARGET_IMAGE_ROOTFS_EXT4)/DATA/.
	cp -r ${IMAGE_ROOTFS}/../recovery/root-$(BOARD)/. $(OTA_TARGET_IMAGE_ROOTFS_EXT4)/RECOVERY/.

	#generate recovery.fstab which is used by the updater-script
	echo #mount point fstype device [device2] >> $(OTA_TARGET_IMAGE_ROOTFS_EXT4)/RECOVERY/recovery.fstab
	echo /boot emmc /dev/block/bootdevice/by-name/boot >> $(OTA_TARGET_IMAGE_ROOTFS_EXT4)/RECOVERY/recovery.fstab
	echo /overlay ext4 /dev/block/bootdevice/by-name/userdata >> $(OTA_TARGET_IMAGE_ROOTFS_EXT4)/RECOVERY/recovery.fstab
	echo ${IMAGE_SYSTEM_MOUNT_POINT_EXT4} ext4 /dev/block/bootdevice/by-name/system >> $(OTA_TARGET_IMAGE_ROOTFS_EXT4)/RECOVERY/recovery.fstab
	echo ${IMAGE_SYSTEMRW_MOUNT_POINT_EXT4} ext4 /dev/block/bootdevice/by-name/systemrw >> $(OTA_TARGET_IMAGE_ROOTFS_EXT4)/RECOVERY/recovery.fstab

	#Getting content for OTA folder
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/OTA/bin
	cp ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/RECOVERY/usr/bin/applypatch ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/OTA/bin/.
	cp ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/RECOVERY/usr/bin/updater ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/OTA/bin/.

    # Pack releasetools.py into META folder itself.
    # This could also have been done by passing "--device_specific" to
    # ota_from_target_files.py but it would be hacky to find the absolute path there.
	cp ${TOPDIR}/src/OTA/device/qcom/common/releasetools.py ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/META/.

    # copy contents of META folder
    #recovery_api_version is from recovery module
	echo recovery_api_version=3 >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/META/misc_info.txt

    #blocksize = BOARD_FLASH_BLOCK_SIZE
	echo blocksize=131072 >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/META/misc_info.txt

	#cache_size = cache partition size
	echo cache_size=0x3200000 >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/META/misc_info.txt

    #mkyaffs2_extra_flags : -c $(BOARD_KERNEL_PAGESIZE) -s $(BOARD_KERNEL_SPARESIZE)
	echo mkyaffs2_extra_flags=-c 4096 -s 16 >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/META/misc_info.txt

    #extfs_sparse_flag : definition in build
	echo extfs_sparse_flags=-s >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/META/misc_info.txt

    #default_system_dev_certificate : Dummy location
	echo default_system_dev_certificate=build/abcd >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/META/misc_info.txt

    # set block img diff version to v3
	echo "blockimgdiff_versions=3" >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/META/misc_info.txt
	cd ${OTA_TARGET_IMAGE_ROOTFS_EXT4} && zip -qry ${OTA_TARGET_FILES_EXT4_PATH} *
endef

define Ota/Build/ext4
	$(call Ota/Build/target-files-zip-ext4)
	$(call Ota/Build/gen_ota_full_zip_ext4)
endef
