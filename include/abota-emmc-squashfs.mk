.NOTPARALLEL:
OTA_TARGET_FILES_EMMC_SQSH_AB = "target-files-emmc-sqsh-ab.zip"
OTA_TARGET_FILES_EMMC_SQSH_AB_DEST = "target-files-emmc-sqsh-dest-ab.zip"
OTA_FULL_UPDATE_EMMC_SQSH_AB = "full_update_emmc_sqsh_ab.zip"
OTA_INCREMENTAL_UPDATE_EMMC_SQSH_AB = "incremental_update_emmc_sqsh_ab.zip"
IMAGE_SYSTEM_MOUNT_POINT_EMMC_SQSH_AB = "/system"
OTA_TARGET_FILES_EMMC_SQSH_AB_PATH = $(IMAGE_PRODUCTS_DIR)-ab/$(OTA_TARGET_FILES_EMMC_SQSH_AB)
OTA_TARGET_FILES_EMMC_SQSH_AB_DEST_PATH = $(IMAGE_PRODUCTS_DIR)-ab/$(OTA_TARGET_FILES_EMMC_SQSH_AB_DEST)
OTA_FULL_UPDATE_EMMC_SQSH_AB_PATH = $(IMAGE_PRODUCTS_DIR)-ab/$(OTA_FULL_UPDATE_EMMC_SQSH_AB)
OTA_INCREMENTAL_UPDATE_EMMC_SQSH_AB_PATH = $(IMAGE_PRODUCTS_DIR)-ab/$(OTA_INCREMENTAL_UPDATE_EMMC_SQSH_AB)
OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB = ${BUILD_DIR}/OTA/ota-target-image-emmc-sqsh-ab
MACHINE_FILESMAP_FULL_PATH_EMMC_SQSH_AB = $(TOPDIR)/owrt-qti-bsp/conf/machine/filesmap/sdx85-emmc-ab-squashfs-filesmap

SIGN_OTA_PACKAGE = ""
MIRROR_SYNC = ""
ifeq ($(CONFIG_OTA_PACKAGE_VERIFICATION), y)
        SIGN_OTA_PACKAGE = "--sign"
endif

ifeq ($(CONFIG_TARGET_sdx75), y)
        MIRROR_SYNC = "--mirror_sync"
endif

ifeq ($(CONFIG_TARGET_sdx85), y)
        MIRROR_SYNC = "--mirror_sync"
endif

define Ota/Build/gen_ota_full_zip_emmc_sqsh_ab
	(cd $(BUILD_DIR)/OTA/ota-scripts; \
	rm -rf update_emmc_sqsh_ab.zip; \
	./full_ota.sh ${OTA_TARGET_FILES_EMMC_SQSH_AB_PATH} ${IMAGE_ROOTFS}-ab squashfs --block --system_path ${IMAGE_SYSTEM_MOUNT_POINT_EMMC_SQSH_AB} $(SIGN_OTA_PACKAGE) $(MIRROR_SYNC); \
	cp update_squashfs.zip ${OTA_FULL_UPDATE_EMMC_SQSH_AB_PATH}; \
	mv ota_debug.txt ota_debug_emmc_sqsh_ab.txt; \
	)
endef

define Ota/Build/target-files-zip-emmc-sqsh-ab
	rm -rf $(OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB)
	rm -rf $(OTA_TARGET_FILES_EMMC_SQSH_AB_PATH)

	mkdir -p $(OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB)
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB}/BOOTABLE_IMAGES
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB}/DATA
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB}/META
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB}/OTA
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB}/RECOVERY
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB}/SYSTEM
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB}/RADIO
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB}/IMAGES
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB}/DTBO
	mkdir -p  ${OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB}/BOOT/RAMDISK

	echo "base image rootfs: $(IMAGE_ROOTFS)-ab"
	#same as base image rootfs
	echo "recovery image rootfs: $(IMAGE_ROOTFS)-ab/../recovery/root-$(BOARD)"

	# if exists copy filesmap into RADIO directory
	[[ ! -z ${MACHINE_FILESMAP_FULL_PATH_EMMC_SQSH_AB} ]] && install -m 755 ${MACHINE_FILESMAP_FULL_PATH_EMMC_SQSH_AB} ${OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB}/RADIO/filesmap

	cp $(IMAGE_PRODUCTS_DIR)-ab/boot.img $(OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB)/BOOTABLE_IMAGES/boot.img
	stat --printf="boot_image_size=%s\n" ${IMAGE_PRODUCTS_DIR}-ab/boot.img >> ${OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB}/META/misc_info.txt
	squashfs2sparse $(IMAGE_PRODUCTS_DIR)-ab/system.squashfs $(OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB)/IMAGES/system.img
	stat --printf="system_image_size=%s\n" $(OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB)/IMAGES/system.img >> ${OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB}/META/misc_info.txt
	# copy the contents of system rootfs
	cp -r $(IMAGE_ROOTFS)-ab/. $(OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB)/SYSTEM/.
	#cd $(OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB)/SYSTEM
	#rm -rf var/run
	#ln -snf ../run var/run

	# copy the contents of system overlayfs
	cp -r $(IMAGE_ROOTFS)-ab/overlay/. $(OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB)/DATA/.
	cp -r $(IMAGE_ROOTFS)-ab/. $(OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB)/RECOVERY/.

	#generate recovery.fstab which is used by the updater-script
	echo #mount point fstype device [device2] >> $(OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB)/RECOVERY/recovery.fstab
	echo /boot emmc /dev/block/bootdevice/by-name/boot >> $(OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB)/RECOVERY/recovery.fstab
	echo ${IMAGE_SYSTEM_MOUNT_POINT_EMMC_SQSH_AB} squashfs /dev/block/bootdevice/by-name/system >> $(OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB)/RECOVERY/recovery.fstab

	#Getting content for OTA folder
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB}/OTA/bin
	cp ${OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB}/RECOVERY/usr/bin/applypatch ${OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB}/OTA/bin/.
	cp ${OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB}/RECOVERY/usr/bin/updater ${OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB}/OTA/bin/.

    # Pack releasetools.py into META folder itself.
    # This could also have been done by passing "--device_specific" to
    # ota_from_target_files.py but it would be hacky to find the absolute path there.
	cp ${TOPDIR}/src/OTA/device/qcom/common/releasetools.py ${OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB}/META/.

    # copy contents of META folder
    #recovery_api_version is from recovery module
	echo recovery_api_version=3 >> ${OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB}/META/misc_info.txt

    #blocksize = BOARD_FLASH_BLOCK_SIZE
	echo blocksize=131072 >> ${OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB}/META/misc_info.txt

    #cache_size = cache partition size
	echo cache_size=0x00800000 >> ${OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB}/META/misc_info.txt

    #mkyaffs2_extra_flags : -c $(BOARD_KERNEL_PAGESIZE) -s $(BOARD_KERNEL_SPARESIZE)
	echo mkyaffs2_extra_flags=-c 4096 -s 16 >> ${OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB}/META/misc_info.txt

    #extfs_sparse_flag : definition in build
	echo extfs_sparse_flags=-s >> ${OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB}/META/misc_info.txt

    #default_system_dev_certificate : Dummy location
	echo default_system_dev_certificate=build/abcd >> ${OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB}/META/misc_info.txt

    # set block img diff version to v3
	echo "blockimgdiff_versions=3" >> ${OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB}/META/misc_info.txt

	# Targets that support A/B boot do not need recovery(fs)-updater
	echo le_target_supports_ab=1 >> ${OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB}/META/misc_info.txt

    # set owrt_target_supports_squashfs to 1
	echo "owrt_target_supports_squashfs=1" >> ${OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB}/META/misc_info.txt

    # Copy lvm_conf.json to META directory
	cp ${TOPDIR}/owrt-qti-bsp/bsp-packages/startup-scripts/files/lvm_conf.json ${OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB}/META/.

	cd ${OTA_TARGET_IMAGE_ROOTFS_EMMC_SQSH_AB} && zip -qry ${OTA_TARGET_FILES_EMMC_SQSH_AB_PATH} *
endef

define Ota/Build/emmc_squash_ab
	$(call Ota/Build/target-files-zip-emmc-sqsh-ab)
	$(call Ota/Build/gen_ota_full_zip_emmc_sqsh_ab)
endef
