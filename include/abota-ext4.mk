OTA_TARGET_FILES_EXT4_AB = "target-files-ext4-ab.zip"
OTA_TARGET_FILES_EXT4_AB_DEST = "target-files-ext4-dest-ab.zip"
OTA_FULL_UPDATE_EXT4_AB = "full_update_ext4_ab.zip"
IMAGE_SYSTEM_MOUNT_POINT_EXT4 = "/system"
OTA_TARGET_FILES_EXT4_AB_PATH = $(IMAGE_PRODUCTS_DIR)-ab/$(OTA_TARGET_FILES_EXT4_AB)
OTA_FULL_UPDATE_EXT4_AB_PATH = $(IMAGE_PRODUCTS_DIR)-ab/$(OTA_FULL_UPDATE_EXT4_AB)
OTA_TARGET_IMAGE_ROOTFS_EXT4_AB = ${BUILD_DIR}/OTA/ota-target-image-ext4-ab
MACHINE_FILESMAP_FULL_PATH_EXT4 = $(TOPDIR)/owrt-qti-bsp/conf/machine/filesmap/$(BOARD)-emmc-ab-filesmap

SIGN_OTA_PACKAGE = ""
MIRROR_SYNC = ""
ifeq ($(CONFIG_OTA_PACKAGE_VERIFICATION), y)
	SIGN_OTA_PACKAGE = "--sign"
endif

ifeq ($(CONFIG_TARGET_sdx75), y)
	MIRROR_SYNC = "--mirror_sync"
endif

define Ota/Build/gen_ota_full_zip_ext4_ab
	cd $(BUILD_DIR)/OTA/ota-scripts; \
	rm -rf update_ext4.zip; \
	./full_ota.sh ${OTA_TARGET_FILES_EXT4_AB_PATH} ${IMAGE_ROOTFS}-ab ext4 --block --system_path ${IMAGE_SYSTEM_MOUNT_POINT_EXT4} $(SIGN_OTA_PACKAGE) $(MIRROR_SYNC); \
	cp update_ext4.zip ${OTA_FULL_UPDATE_EXT4_AB_PATH}
endef

define Ota/Build/target-files-zip-ext4-ab
	rm -rf $(OTA_TARGET_IMAGE_ROOTFS_EXT4_AB)
	rm -rf $(OTA_TARGET_FILES_EXT4_AB_PATH)

	mkdir -p $(OTA_TARGET_IMAGE_ROOTFS_EXT4_AB)
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_EXT4_AB}/BOOTABLE_IMAGES
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_EXT4_AB}/DATA
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_EXT4_AB}/META
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_EXT4_AB}/OTA
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_EXT4_AB}/RECOVERY
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_EXT4_AB}/SYSTEM
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_EXT4_AB}/RADIO
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_EXT4_AB}/IMAGES
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_EXT4_AB}/DTBO
	mkdir -p  ${OTA_TARGET_IMAGE_ROOTFS_EXT4_AB}/BOOT/RAMDISK

	echo "base image rootfs: $(IMAGE_ROOTFS)-ab"
	#same as base image rootfs
	echo "recovery image rootfs: $(IMAGE_ROOTFS)-ab/../recovery/root-$(BOARD)"

	# if exists copy filesmap into RADIO directory
	[[ ! -z ${MACHINE_FILESMAP_FULL_PATH_EXT4} ]] && install -m 755 ${MACHINE_FILESMAP_FULL_PATH_EXT4} ${OTA_TARGET_IMAGE_ROOTFS_EXT4_AB}/RADIO/filesmap

	cp $(IMAGE_PRODUCTS_DIR)-ab/boot.img $(OTA_TARGET_IMAGE_ROOTFS_EXT4_AB)/BOOTABLE_IMAGES/boot.img
	cp $(IMAGE_PRODUCTS_DIR)-ab/boot.img $(OTA_TARGET_IMAGE_ROOTFS_EXT4_AB)/BOOTABLE_IMAGES/recovery.img
	cp $(IMAGE_PRODUCTS_DIR)-ab/system.img $(OTA_TARGET_IMAGE_ROOTFS_EXT4_AB)/IMAGES/system.img
	cp $(IMAGE_PRODUCTS_DIR)-ab/system.map $(OTA_TARGET_IMAGE_ROOTFS_EXT4_AB)/IMAGES/system.map
	cp $(IMAGE_PRODUCTS_DIR)-ab/userdata.img $(OTA_TARGET_IMAGE_ROOTFS_EXT4_AB)/IMAGES/userdata.img
	cp $(IMAGE_PRODUCTS_DIR)-ab/userdata.map $(OTA_TARGET_IMAGE_ROOTFS_EXT4_AB)/IMAGES/userdata.map

	# copy the contents of system rootfs
	cp -r $(IMAGE_ROOTFS)-ab/. $(OTA_TARGET_IMAGE_ROOTFS_EXT4_AB)/SYSTEM/.
	#cd $(OTA_TARGET_IMAGE_ROOTFS_EXT4_AB)/SYSTEM
	#rm -rf var/run
	#ln -snf ../run var/run

	# copy the contents of system overlayfs
	cp -r $(IMAGE_ROOTFS)-ab/overlay/. $(OTA_TARGET_IMAGE_ROOTFS_EXT4_AB)/DATA/.
	cp -r $(IMAGE_ROOTFS)-ab/. $(OTA_TARGET_IMAGE_ROOTFS_EXT4_AB)/RECOVERY/.

	#generate recovery.fstab which is used by the updater-script
	echo #mount point fstype device [device2] >> $(OTA_TARGET_IMAGE_ROOTFS_EXT4_AB)/RECOVERY/recovery.fstab
	echo /boot emmc /dev/block/bootdevice/by-name/boot >> $(OTA_TARGET_IMAGE_ROOTFS_EXT4_AB)/RECOVERY/recovery.fstab
	echo /overlay ext4 /dev/block/bootdevice/by-name/userdata >> $(OTA_TARGET_IMAGE_ROOTFS_EXT4_AB)/RECOVERY/recovery.fstab
	echo ${IMAGE_SYSTEM_MOUNT_POINT_EXT4} ext4 /dev/block/bootdevice/by-name/system >> $(OTA_TARGET_IMAGE_ROOTFS_EXT4_AB)/RECOVERY/recovery.fstab

	#Getting content for OTA folder
	mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_EXT4_AB}/OTA/bin
	cp ${OTA_TARGET_IMAGE_ROOTFS_EXT4_AB}/RECOVERY/usr/bin/applypatch ${OTA_TARGET_IMAGE_ROOTFS_EXT4_AB}/OTA/bin/.
	cp ${OTA_TARGET_IMAGE_ROOTFS_EXT4_AB}/RECOVERY/usr/bin/updater ${OTA_TARGET_IMAGE_ROOTFS_EXT4_AB}/OTA/bin/.

    # Pack releasetools.py into META folder itself.
    # This could also have been done by passing "--device_specific" to
    # ota_from_target_files.py but it would be hacky to find the absolute path there.
	cp ${TOPDIR}/src/OTA/device/qcom/common/releasetools.py ${OTA_TARGET_IMAGE_ROOTFS_EXT4_AB}/META/.

    # copy contents of META folder
    #recovery_api_version is from recovery module
	echo recovery_api_version=3 >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4_AB}/META/misc_info.txt

    #blocksize = BOARD_FLASH_BLOCK_SIZE
	echo blocksize=131072 >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4_AB}/META/misc_info.txt

    #mkyaffs2_extra_flags : -c $(BOARD_KERNEL_PAGESIZE) -s $(BOARD_KERNEL_SPARESIZE)
	echo mkyaffs2_extra_flags=-c 4096 -s 16 >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4_AB}/META/misc_info.txt

    #extfs_sparse_flag : definition in build
	echo extfs_sparse_flags=-s >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4_AB}/META/misc_info.txt

    #default_system_dev_certificate : Dummy location
	echo default_system_dev_certificate=build/abcd >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4_AB}/META/misc_info.txt

    # set block img diff version to v3
	echo "blockimgdiff_versions=3" >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4_AB}/META/misc_info.txt

	# Targets that support A/B boot do not need recovery(fs)-updater
	echo le_target_supports_ab=1 >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4_AB}/META/misc_info.txt

	cd ${OTA_TARGET_IMAGE_ROOTFS_EXT4_AB} && zip -qry ${OTA_TARGET_FILES_EXT4_AB_PATH} *

endef
