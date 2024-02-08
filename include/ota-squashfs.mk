.NOTPARALLEL:
OTA_TARGET_FILES_SQSH = "target-files-sqsh.zip"
OTA_TARGET_FILES_SQSH_DEST = "target-files-sqsh-dest.zip"
OTA_FULL_UPDATE_SQSH = "full_update_sqsh.zip"
OTA_INCREMENTAL_UPDATE_SQSH = "incremental_update_sqsh.zip"
IMAGE_SYSTEM_MOUNT_POINT_SQSH = "/system"
OTA_TARGET_FILES_SQSH_PATH = $(IMAGE_PRODUCTS_DIR)/$(OTA_TARGET_FILES_SQSH)
OTA_TARGET_FILES_SQSH_DEST_PATH = $(IMAGE_PRODUCTS_DIR)/$(OTA_TARGET_FILES_SQSH_DEST)
OTA_FULL_UPDATE_SQSH_PATH = $(IMAGE_PRODUCTS_DIR)/$(OTA_FULL_UPDATE_SQSH)
OTA_INCREMENTAL_UPDATE_SQSH_PATH = $(IMAGE_PRODUCTS_DIR)/$(OTA_INCREMENTAL_UPDATE_SQSH)
OTA_TARGET_IMAGE_ROOTFS_SQSH = ${BUILD_DIR}/OTA/ota-target-image-sqsh
MACHINE_FILESMAP_FULL_PATH_SQSH = $(TOPDIR)/owrt-qti-bsp/conf/machine/filesmap/sdx35-squashfs-filesmap

define Ota/Build/gen_ota_full_zip_sqsh
	(cd $(BUILD_DIR)/OTA/ota-scripts; \
	rm -rf update_sqsh.zip; \
	./full_ota.sh ${OTA_TARGET_FILES_SQSH_PATH} ${IMAGE_ROOTFS} squashfs --block --system_path ${IMAGE_SYSTEM_MOUNT_POINT_SQSH} ; \
	cp update_squashfs.zip ${OTA_FULL_UPDATE_SQSH_PATH}; \
	mv ota_debug.txt ota_debug_sqsh.txt; \
	)
endef

define Ota/Build/target-files-zip-sqsh
	rm -rf $(OTA_TARGET_IMAGE_ROOTFS_SQSH)
	rm -rf $(OTA_TARGET_FILES_SQSH_PATH)

	mkdir -p $(OTA_TARGET_IMAGE_ROOTFS_SQSH)
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/BOOTABLE_IMAGES
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/DATA
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/META
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/OTA
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/RECOVERY
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/SYSTEM
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/RADIO
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/IMAGES
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/DTBO
	mkdir -p  ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/BOOT/RAMDISK

	echo "base image rootfs: $(IMAGE_ROOTFS)"
	echo "recovery image rootfs: ${IMAGE_ROOTFS}/../recovery/root-$(BOARD)"

	# if exists copy filesmap into RADIO directory
	[[ ! -z ${MACHINE_FILESMAP_FULL_PATH_SQSH} ]] && install -m 755 ${MACHINE_FILESMAP_FULL_PATH_SQSH} ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/RADIO/filesmap

	cp $(IMAGE_PRODUCTS_DIR)/boot.img $(OTA_TARGET_IMAGE_ROOTFS_SQSH)/BOOTABLE_IMAGES/boot.img
	img2simg $(IMAGE_PRODUCTS_DIR)/sysfs-2k.squashfs $(OTA_TARGET_IMAGE_ROOTFS_SQSH)/IMAGES/system.img

	# copy the contents of system rootfs
	cp -r $(IMAGE_ROOTFS)/. $(OTA_TARGET_IMAGE_ROOTFS_SQSH)/SYSTEM/.
	#cd $(OTA_TARGET_IMAGE_ROOTFS_SQSH)/SYSTEM
	#rm -rf var/run
	#ln -snf ../run var/run

	# copy the contents of system overlayfs
	cp -r $(IMAGE_ROOTFS)/overlay/. $(OTA_TARGET_IMAGE_ROOTFS_SQSH)/DATA/.
	cp -r ${IMAGE_ROOTFS}/../recovery/root-$(BOARD)/. $(OTA_TARGET_IMAGE_ROOTFS_SQSH)/RECOVERY/.

	#generate recovery.fstab which is used by the updater-script
	echo #mount point fstype device [device2] >> $(OTA_TARGET_IMAGE_ROOTFS_SQSH)/RECOVERY/recovery.fstab
	echo /boot mtd boot >> $(OTA_TARGET_IMAGE_ROOTFS_SQSH)/RECOVERY/recovery.fstab
	echo ${IMAGE_SYSTEM_MOUNT_POINT_SQSH} squashfs /dev/block/bootdevice/by-name/rootfs >> $(OTA_TARGET_IMAGE_ROOTFS_SQSH)/RECOVERY/recovery.fstab

	#Getting content for OTA folder
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/OTA/bin
	cp ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/RECOVERY/usr/bin/applypatch ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/OTA/bin/.
	cp ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/RECOVERY/usr/bin/updater ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/OTA/bin/.

    # Pack releasetools.py into META folder itself.
    # This could also have been done by passing "--device_specific" to
    # ota_from_target_files.py but it would be hacky to find the absolute path there.
	cp ${TOPDIR}/src/OTA/device/qcom/common/releasetools.py ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/META/.

    # copy contents of META folder
    #recovery_api_version is from recovery module
	echo recovery_api_version=3 >> ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/META/misc_info.txt

    #blocksize = BOARD_FLASH_BLOCK_SIZE
	echo blocksize=131072 >> ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/META/misc_info.txt

    #cache_size = cache partition size
	echo cache_size=0x00800000 >> ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/META/misc_info.txt

    #mkyaffs2_extra_flags : -c $(BOARD_KERNEL_PAGESIZE) -s $(BOARD_KERNEL_SPARESIZE)
	echo mkyaffs2_extra_flags=-c 4096 -s 16 >> ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/META/misc_info.txt

    #extfs_sparse_flag : definition in build
	echo extfs_sparse_flags=-s >> ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/META/misc_info.txt

    #default_system_dev_certificate : Dummy location
	echo default_system_dev_certificate=build/abcd >> ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/META/misc_info.txt

    # set block img diff version to v3
	echo "blockimgdiff_versions=3" >> ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/META/misc_info.txt

    # set owrt_target_supports_squashfs to 1
	echo "owrt_target_supports_squashfs=1" >> ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/META/misc_info.txt
	cd ${OTA_TARGET_IMAGE_ROOTFS_SQSH} && zip -qry ${OTA_TARGET_FILES_SQSH_PATH} *
endef

define Ota/Build/ubi_squash
	$(call Ota/Build/target-files-zip-sqsh)
	$(call Ota/Build/gen_ota_full_zip_sqsh)
endef
