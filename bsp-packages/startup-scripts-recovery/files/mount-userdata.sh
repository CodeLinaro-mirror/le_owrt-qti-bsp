#!/bin/sh
#Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
#SPDX-License-Identifier: BSD-3-Clause-Clear

STATUS_FILE="/cache/recovery/ota_status"
LOG_FILE="/cache/lvm.log"

log() { echo "[lvm] $*" >&2; }

create_link()
{
       mkdir -p /dev/block/bootdevice/by-name/
       partition_name=/dev/block/bootdevice/by-name/${2}
       target_dev=/dev/${1}/${2}
       ln -s $target_dev $partition_name
}


activate_lv()
{
        until lvscan 2>/dev/null | grep -q "^  ACTIVE.*'/dev/${1}/${2}'"; do
               vgscan #>/dev/null 2>&1
               vgchange -ay #>/dev/null 2>&1
        done

}

mount_overlay()
{
    mount_partition="$1"

    mkdir -p /$mount_partition/overlay-work-rec
    mkdir -p /$mount_partition/overlay-work-rec/etc-upper
    mkdir -p /$mount_partition/overlay-work-rec/.etc-work
    #mount -t overlay -o lowerdir=/etc,upperdir=/$mount_partition/overlay-work-rec/etc-upper,workdir=/$mount_partition/overlay-work-rec/.etc-work overlay /etc

    if [ "$mount_partition" = "cache" ]; then
      mount -t overlay -o lowerdir=/etc/lvm,upperdir=/$mount_partition/overlay-work-rec/etc-upper,workdir=/$mount_partition/overlay-work-rec/.etc-work lvm /etc/lvm
    else
      mount -t overlay -o lowerdir=/etc,upperdir=/$mount_partition/overlay-work-rec/etc-upper,workdir=/$mount_partition/overlay-work-rec/.etc-work overlay /etc
    fi

}

mount_userdata() 
{
 SYMLINK="/dev/block/bootdevice/by-name/userdata"
 BLK_NODE=$(readlink -f "$SYMLINK")
 SRC_DIR="/data"
 LV_NAME="usrfs"
 VG_NAME="vgdata"

 if [ ! -b "$BLK_NODE" ]; then
    log "Block device not found!"
    return
 fi
 FS_INFO=$(file -s "$BLK_NODE")
 log "Detected: $FS_INFO"
 case "$FS_INFO" in
    *"ext4 filesystem"*)
        mount -t ext4 /dev/block/bootdevice/by-name/userdata "$SRC_DIR"
        log "Userdata partition mounted on /data "
        mount_overlay data
        return 0
        ;;
    *"LVM2"*)
        log "Found LVM metadata. Mounting usrfs LV"
        mount_overlay cache
        activate_lv ${VG_NAME} ${LV_NAME}
        create_link $VG_NAME $LV_NAME
        mount -t ext4 "/dev/$VG_NAME/$LV_NAME" "$SRC_DIR" -o relatime,data=ordered,noauto_da_alloc,discard
        log "Usrfs logical volume mounted successfully."
        mount_overlay data
        return 1
        ;;
    *"data"*)
        log "Empty partition, boot to mission mode first and setup LVM..."
        ;;
    *)
        log "Unknown type, aborting." 
        ;;
 esac
 return 0
}

