include $(TOPDIR)/owrt-qti-bsp/include/ota-common.mk

OTA_TARGET_FILES_UBI = "target-files-ubi.zip"
OTA_TARGET_FILES_UBI_2k = "target-files-ubi-2k.zip"
IMAGE_SYSTEM_MOUNT_POINT_UBI = "/system"
OTA_TARGET_IMAGE_ROOTFS_UBI = ${BUILD_DIR}/OTA/ota-target-image-ubi
IMAGE_ROOTFS_UBI = $(IMAGE_ROOTFS)
OTA_TARGET_FILES_UBI_PATH = $(IMAGE_PRODUCTS_DIR)/$(OTA_TARGET_FILES_UBI)
OTA_TARGET_FILES_UBI_PATH_2k = $(IMAGE_PRODUCTS_DIR)/$(OTA_TARGET_FILES_UBI_2k)
MACHINE_FILESMAP_FULL_PATH_UBI = $(TOPDIR)/owrt-qti-bsp/conf/machine/filesmap/$(BOARD)-nand-filesmap
OTA_FULL_UPDATE_UBI = "full_update_ubi.zip"
OTA_FULL_UPDATE_UBI_PATH = $(IMAGE_PRODUCTS_DIR)/$(OTA_FULL_UPDATE_UBI)
OTA_FULL_UPDATE_UBI_2k = "full_update_ubi-2k.zip"
OTA_FULL_UPDATE_UBI_PATH_2k = $(IMAGE_PRODUCTS_DIR)/$(OTA_FULL_UPDATE_UBI_2k)
SIGN_OTA_PACKAGE = ""
IMAGE_BY_IMAGE = ""
ifeq ($(CONFIG_OTA_PACKAGE_VERIFICATION), y)
	SIGN_OTA_PACKAGE = "--sign"
endif

ifeq ($(CONFIG_TARGET_sdx35), y)
	IMAGE_BY_IMAGE = "--img_by_img"
endif

define Ota/Build/gen_ota_full_zip_ubi
	(cd $(BUILD_DIR)/OTA/ota-scripts; \
	rm -rf update_ubi.zip; \
	if [ $(1) == 2k ]; then \
		./full_ota.sh ${OTA_TARGET_FILES_UBI_PATH_2k} ${IMAGE_ROOTFS_UBI} ubi --block $(IMAGE_BY_IMAGE) --system_path ${IMAGE_SYSTEM_MOUNT_POINT_UBI} $(SIGN_OTA_PACKAGE); \
		$(CP) update_ubi.zip ${OTA_FULL_UPDATE_UBI_PATH_2k}; \
		mv ota_debug.txt ota_debug_ubi_2k.txt; \
	else \
		./full_ota.sh ${OTA_TARGET_FILES_UBI_PATH} ${IMAGE_ROOTFS_UBI} ubi --block $(IMAGE_BY_IMAGE) --system_path ${IMAGE_SYSTEM_MOUNT_POINT_UBI} $(SIGN_OTA_PACKAGE); \
		$(CP) update_ubi.zip ${OTA_FULL_UPDATE_UBI_PATH}; \
		mv ota_debug.txt ota_debug_ubi.txt; \
	fi; \
	)
endef

define Ota/Build/target-files-zip-ubi
	rm -rf $(OTA_TARGET_IMAGE_ROOTFS_UBI); \

	if [ $(1) == 2k ]; then \
		rm -rf $(OTA_TARGET_FILES_UBI_PATH_2k); \
	else \
		rm -rf $(OTA_TARGET_FILES_UBI_PATH); \
	fi

	mkdir -p $(OTA_TARGET_IMAGE_ROOTFS_UBI)
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_UBI}/BOOTABLE_IMAGES
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_UBI}/OTA
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_UBI}/SYSTEM
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RADIO
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_UBI}/IMAGES
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_UBI}/BOOT/RAMDISK

	echo "base image rootfs: $(IMAGE_ROOTFS)"
	echo "recovery image rootfs: ${IMAGE_ROOTFS}/../recovery/root-$(BOARD)"

	# if exists copy filesmap into RADIO directory
	[[ ! -z ${MACHINE_FILESMAP_FULL_PATH_UBI} ]] && install -m 755 ${MACHINE_FILESMAP_FULL_PATH_UBI} ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RADIO/filesmap

	cp $(IMAGE_PRODUCTS_DIR)/boot.img $(OTA_TARGET_IMAGE_ROOTFS_UBI)/BOOTABLE_IMAGES/boot.img
	cp $(IMAGE_PRODUCTS_DIR)/boot.img $(OTA_TARGET_IMAGE_ROOTFS_UBI)/BOOTABLE_IMAGES/recovery.img
	if echo $(1) | grep -q "2k"; then \
		cp $(IMAGE_PRODUCTS_DIR)/sysfs-$(1).ubifs $(OTA_TARGET_IMAGE_ROOTFS_UBI)/BOOTABLE_IMAGES/system.img; \
	else \
		cp $(IMAGE_PRODUCTS_DIR)/sysfs.ubifs $(OTA_TARGET_IMAGE_ROOTFS_UBI)/BOOTABLE_IMAGES/system.img; \
	fi
	echo dm_verity_nand=1 >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt
	if [ $(CONFIG_OTA_RECOVERY_UPDATE) == y ]; then \
		cp $(IMAGE_PRODUCTS_DIR)/../recovery/recoveryfs.ubi $(OTA_TARGET_IMAGE_ROOTFS_UBI)/BOOTABLE_IMAGES/recoveryfs.ubi; \
		echo recovery_upgrade_supported=1 >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt; \
	fi

	# copy the contents of system rootfs
	cp -r $(IMAGE_ROOTFS)/. $(OTA_TARGET_IMAGE_ROOTFS_UBI)/SYSTEM/.
	#cd $(OTA_TARGET_IMAGE_ROOTFS_UBI)/SYSTEM
	#rm -rf var/run
	#ln -snf ../run var/run

	# copy the contents of recovery rootfs
	cp -r ${IMAGE_ROOTFS}/../recovery/root-$(BOARD)/. $(OTA_TARGET_IMAGE_ROOTFS_UBI)/RECOVERY/.

	#generate recovery.fstab which is used by the updater-script
	#echo #mount point fstype device [device2] >> $(OTA_TARGET_IMAGE_ROOTFS_UBI)/RECOVERY/recovery.fstab
	echo /boot     mtd     boot >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/recovery.fstab
	echo /cache    ubifs  cache >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/recovery.fstab
	echo /data     ubifs  userdata >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/recovery.fstab
	echo /recovery mtd    recovery >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/recovery.fstab

	#Getting content for OTA folder
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_UBI}/OTA/bin
	cp ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/usr/bin/applypatch ${OTA_TARGET_IMAGE_ROOTFS_UBI}/OTA/bin/.
	cp ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/usr/bin/updater ${OTA_TARGET_IMAGE_ROOTFS_UBI}/OTA/bin/.

	echo /system   ubifs  system >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/recovery.fstab

    # Pack releasetools.py into META folder itself.
    # This could also have been done by passing "--device_specific" to
    # ota_from_target_files.py but it would be hacky to find the absolute path there.
	cp ${TOPDIR}/src/OTA/device/qcom/common/releasetools.py ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/.

    # copy contents of META folder
    #recovery_api_version is from recovery module
	echo recovery_api_version=3 >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt

    #blocksize = BOARD_FLASH_BLOCK_SIZE
	echo blocksize=131072 >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt

    #mkyaffs2_extra_flags : -c $(BOARD_KERNEL_PAGESIZE) -s $(BOARD_KERNEL_SPARESIZE)
	echo mkyaffs2_extra_flags=-c 4096 -s 16 >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt

    #extfs_sparse_flag : definition in build
	echo extfs_sparse_flags=-s >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt

    #default_system_dev_certificate : Dummy location
	echo default_system_dev_certificate=build/abcd >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt

	if [ $(1) == 2k ]; then \
		cd ${OTA_TARGET_IMAGE_ROOTFS_UBI} && zip -qry ${OTA_TARGET_FILES_UBI_PATH_2k} *; \
	else \
		cd ${OTA_TARGET_IMAGE_ROOTFS_UBI} && zip -qry ${OTA_TARGET_FILES_UBI_PATH} *; \
	fi
endef

define Ota/Build/ubi
	$(call Ota/Build/target-files-zip-ubi,$(1))
	$(call Ota/Build/gen_ota_full_zip_ubi,$(1))
endef
