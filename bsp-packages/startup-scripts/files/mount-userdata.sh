#!/bin/sh
#Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
#SPDX-License-Identifier: BSD-3-Clause-Clear


STATUS_FILE="/cache/recovery/ota_status"
CONFIG_JSON="${1:-/etc/lvm_ota.json}"
UPDATER_BIN="/usr/bin/recovery"
LOG_FILE="/cache/lvm.log"
FWUPDATE_PACKAGE_PATH="/cache/recovery/update_package_path"

# Create new volumes in same group: lcm_data: 1GB, cfg: 16M, mfgdata: 4M
# Reduce existing volume to accomodate all above volumes (To be reduced: 1G+16M+4M=1044M)
#Sizes to be aligned with PE size i,e 4MB
prpl_volumes_size=1044M

#Physical extent size in MB
PE_MB=4


# ---------- Using jshn (libubox) ----------
. /usr/share/libubox/jshn.sh

create_links()
{
    mkdir -p /dev/block/bootdevice/by-name/ || return 1

    # List all LVs as "VG LV" (no header)
    lvs --noheadings -o vg_name,lv_name --separator ' ' 2>/dev/null |
    while read -r vg lv; do
        [ -n "$vg" ] && [ -n "$lv" ] || continue
        src=/dev/${vg}/${lv}
        dst=/dev/block/bootdevice/by-name/${lv}
        # Force-create/overwrite the symlink
        ln -sfn $src $dst
    done

}


activate_lv()
{
        until lvscan 2>/dev/null | grep -q "^  ACTIVE.*'/dev/${1}/${2}'"; do
               vgscan #>/dev/null 2>&1
               vgchange -ay #>/dev/null 2>&1
        done

}

scan_part()
{
    lvmdevices --adddev "${1}"
    lvm vgscan --mknodes --devices "${1}" --ignorelockingfailure || :
    vgchange -aly --devices "${1}" --ignorelockingfailure || :
}

# ---------- Helpers ----------
# Convert human size (e.g., 20G, 512M, 4096K, 123B, or plain number in bytes) to bytes
to_bytes() {
    s="$1"
    case "$s" in
        *[bB]) n="${s%[bB]}"; echo "$n" ;;
        *[kK]) n="${s%[kK]}"; expr "$n" \* 1024 ;;
        *[mM]) n="${s%[mM]}"; expr "$n" \* 1048576 ;;
        *[gG]) n="${s%[gG]}"; expr "$n" \* 1073741824 ;;
        *[tT]) n="${s%[tT]}"; expr "$n" \* 1099511627776 ;;
        *) echo "$s" ;;
    esac
}


# Return 0 if LV exists, else non-zero
lv_exists() {
    lvs "$1" >/dev/null 2>&1
}


log() { echo "[lvm] $*" >&2; }

# Get current LV size in bytes (no units/suffix, trimmed)
lv_size_bytes() {
    lvs -o lv_size --units B --nosuffix --noheadings "$1" 2>/dev/null | xargs
}


process_config()
{
# ---------- Pre-check: OTA status ----------
status="$(cat "$STATUS_FILE" 2>/dev/null || echo "")"
if [ "$status" != "PHYSICAL_PARTITION_WRITE_SUCCESS" ]; then
    return
fi

# create tmp file in start of the process and delete at the end when OTA is successful
# If process fails in between, tmp file can be checked to confirm the failure.
echo "1" > /tmp/lvm_vol_progress

# ---------- Validate JSON ----------
json_init
if ! json_load "$(cat "$CONFIG_JSON" 2>/dev/null)"; then
    log "Invalid JSON: $CONFIG_JSON"
    echo "OTA_FAILED" > "$STATUS_FILE"
    return
fi


# Extract only real keys (ignore sample_)
json_get_keys _topkeys
REAL_KEYS=""
for _k in $_topkeys; do
    case "$_k" in
        sample_*) : ;;
        *) REAL_KEYS="${REAL_KEYS}${REAL_KEYS:+ }${_k}" ;;
    esac
done

if [[ -z "$REAL_KEYS" ]]; then
  log "No real configuration found. Doing nothing."
  echo "OTA_FAILED" > "$STATUS_FILE"
  return
fi


# ---------- Get VG ----------
VG=""
json_get_var VG vg
[ -n "$VG" ] || { log "ERROR: no 'vg' in config"; echo "OTA_FAILED" > "$STATUS_FILE"; return; }


# ---------- Delete volumes ----------
if json_select delete 2>/dev/null; then
       json_get_keys _idxs
       for i in $_idxs; do
           json_select "$i"
           name=""
           json_get_var name volume_name
           if [ -n "$name" ]; then
              if lv_exists "/dev/$VG/$name"; then
                log "Deleting LV: /dev/$VG/$name"
                lvremove -y "/dev/$VG/$name" || { log "lvremove failed for $name"; echo "OTA_FAILED" > "$STATUS_FILE"; return; }
              else
                log "WARNING: Delete: vol - $name doesnt exist"
              fi
           else
               log "WARNING: missing delete[$i].volume_name"
           fi
           json_select ..
       done
       json_select ..
fi



# ---------- Resize volumes ----------
    if json_select resize 2>/dev/null; then
        json_get_keys _idxs
        for i in $_idxs; do
            json_select "$i"
            name=""; target=""
            json_get_var name volume_name
            json_get_var target size

            if [ -z "$name" ] || [ -z "$target" ]; then
                log "ERROR: resize[$i] missing 'volume_name' or 'size'"
                echo "OTA_FAILED" > "$STATUS_FILE"; json_select ..; return
            fi

            current="$(lv_size_bytes "/dev/$VG/$name")"
            [ -n "$current" ] || { log "ERROR: cannot read current size for $name"; echo "OTA_FAILED" > "$STATUS_FILE"; json_select ..; return; }

            tgt_bytes="$(to_bytes "$target")"
            [ -n "$tgt_bytes" ] || { log "ERROR: cannot parse target size '$target'"; echo "OTA_FAILED" > "$STATUS_FILE"; json_select ..; return; }

            diff="$(expr "$tgt_bytes" - "$current" 2>/dev/null || echo 0)"

            if [ "$diff" -gt 0 ]; then
                log "Extending /dev/$VG/$name to $target"
                lvextend -y -L "$target" "/dev/$VG/$name" || { log "lvextend failed for $name"; echo "OTA_FAILED" > "$STATUS_FILE"; json_select ..; return; }
		e2fsck -fy "/dev/$VG/$name"
		resize2fs -f "/dev/$VG/$name" "$target"
                # NOTE: grow filesystem here if needed (e.g., for ext4: resize2fs /mountpoint)
            elif [ "$diff" -lt 0 ]; then
                log "Reducing /dev/$VG/$name to $target"
		e2fsck -fy "/dev/$VG/$name"
		resize2fs -f "/dev/$VG/$name" "$target" || { log "resize2fs failed for $name"; echo "OTA_FAILED" > "$STATUS_FILE"; json_select ..; return; }
                lvreduce -y -L "$target" "/dev/$VG/$name" || { log "lvreduce failed for $name"; echo "OTA_FAILED" > "$STATUS_FILE"; json_select ..; return; }
                e2fsck -fy "/dev/$VG/$name"
            else
                log "No change for /dev/$VG/$name (current size equals target)"
            fi

            json_select ..
        done
        json_select ..
    fi


# ---------- Create volumes ----------
    if json_select create 2>/dev/null; then
        json_get_keys _idxs
        for i in $_idxs; do
            json_select "$i"
            name=""; target=""
            json_get_var name volume_name
            json_get_var target size

            if [ -z "$name" ] || [ -z "$target" ]; then
                log "ERROR: create[$i] missing 'volume_name' or 'size'"
                echo "OTA_FAILED" > "$STATUS_FILE"; json_select ..; return
            fi

            if lv_exists "/dev/$VG/$name"; then
                log "LV already exists, skipping create: /dev/$VG/$name"
                json_select ..; continue
            fi

            tgt_bytes="$(to_bytes "$target")"
            if [ -z "$tgt_bytes" ]; then
                log "ERROR: cannot parse create size '$target' for $name"
                echo "OTA_FAILED" > "$STATUS_FILE"; json_select ..; return
            fi

            log "Creating LV: name='$name' size='$target' vg='$VG'"
            lvcreate -y -L "$target" -n "$name" "$VG" || {
                log "lvcreate failed for $name"
                echo "OTA_FAILED" > "$STATUS_FILE"; json_select ..; return
            }

            json_select ..
        done
        json_select ..
    fi

# ---------- Call updater if there are files to update ----------
    upd_len=0
    if json_select update 2>/dev/null; then
        json_get_keys _idxs
        for _ in $_idxs; do upd_len=$((upd_len+1)); done
        json_select ..
    fi

    if [ "$upd_len" -gt 0 ]; then
        if [ -x "$UPDATER_BIN" ]; then
            # Set status and call updater after mounting usrfs
            echo "OTA_UPDATEVOL" > "$STATUS_FILE"; return;
        else
            log "WARNING: updater binary not found/executable at $UPDATER_BIN"
            echo "OTA_FAILED" > "$STATUS_FILE"; return;
        fi
    fi

# ---------- Success ----------
echo "OTA_SUCCESS" > "$STATUS_FILE"
rm -f /tmp/lvm_vol_progress
log "All operations completed; OTA_SUCCESS written."
return
}

update_vol()
{
 # ---------- Pre-check: OTA status ----------
 status="$(cat "$STATUS_FILE" 2>/dev/null || echo "")"
 if [ "$status" != "OTA_UPDATEVOL" ]; then
     return
 fi
 log "Calling updater script.."
  
 # Extract the firmware update zip file path
 UPDATE_PACKAGE=$(sed -n 's/.*--update_package=\([^;]*\).*/\1/p' $FWUPDATE_PACKAGE_PATH)
 if [ -x /sbin/abctl ]; then
    "$UPDATER_BIN" "--update_package=$UPDATE_PACKAGE;--lvm_updation" || { log "updater failed"; echo "OTA_FAILED" > "$STATUS_FILE"; return; }
 else
    "$UPDATER_BIN" "--update_package=$UPDATE_PACKAGE;--lvm_updation" --update_binary_from_device || { log "updater failed"; echo "OTA_FAILED" > "$STATUS_FILE"; return; }
 fi

 status="$(cat "$STATUS_FILE" 2>/dev/null || echo "")"
 if [ "$status" != "OTA_VOL_SUCCESS" ]; then
     log "recovery bin failed"; echo "OTA_FAILED" > "$STATUS_FILE"; return;
 fi

 # ---------- Success ----------
 echo "OTA_SUCCESS" > "$STATUS_FILE"
 rm -f /tmp/lvm_vol_progress
 log "All operations completed; OTA_SUCCESS written."
 return
}


create_lvm() 
{
 SYMLINK="/dev/block/bootdevice/by-name/userdata"
 BLK_NODE=$(readlink -f "$SYMLINK")
 OUT_MOUNT="/data_tmp"
 SRC_DIR="/data"
 LV_NAME="usrfs"
 VG_NAME="vgdata"
 LV_lcm="lcm_data"
 LV_cfg="securestore"
 LV_mfg="mfgdata"

 if [ ! -b "$BLK_NODE" ]; then
    log "Block device not found!"
    return
 fi
 FS_INFO=$(file -s "$BLK_NODE")
 log "Detected: $FS_INFO"
 case "$FS_INFO" in
    *"ext4 filesystem"*)
        log "Already EXT4 filesystem, nothing to do, just mount the partition"
        ;;
    *"LVM2"*)
        log "Already LVM metadata present."
        lvmdevices --adddev "$BLK_NODE"
        activate_lv ${VG_NAME} ${LV_NAME}
        if [[ -f /etc/os-release ]] && grep -qi "prplOs" /etc/os-release 2>/dev/null; then
            # Check if only 1 volume present, means new volumes need to be created for prpl
            count=$(lvs --noheadings --options lv_name "$VG_NAME" | wc -l)
            log "prpl build. Count = $count"
            if [ "$count" -eq 1 ]; then
              # Create new volumes in same group: lcm_data: 1GB, cfg: 16M, mfgdata: 1M
              # Reduce existing volume to accomodate all above volumes (To be reduced: 1G+16M+1M=1041M)
              current_size="$(lv_size_bytes "/dev/${VG_NAME}/${LV_NAME}")"
              reduce_bytes="$(to_bytes "$prpl_volumes_size")"
              new_size="$(expr "$current_size" - "$reduce_bytes" 2>/dev/null)"
              new_size_MiB=$(( $new_size / 1048576 ))
              #align to PE
              new_size_MiB=$(( ($new_size_MiB / $PE_MB) * $PE_MB ))
              e2fsck -fy "/dev/${VG_NAME}/${LV_NAME}"
              resize2fs -f "/dev/${VG_NAME}/${LV_NAME}" "$new_size_MiB"M
              lvreduce -L "$new_size_MiB"M "/dev/${VG_NAME}/${LV_NAME}"
              e2fsck -fy "/dev/${VG_NAME}/${LV_NAME}"
              #create new volumes
              lvcreate -n "$LV_lcm" -L 1G "$VG_NAME"
              lvcreate -n "$LV_cfg" -L 16M "$VG_NAME"
              lvcreate -n "$LV_mfg" -L 4M "$VG_NAME"
              log "New volumes created for prplOS."
              activate_lv ${VG_NAME} ${LV_NAME}
              mkfs.ext4 "/dev/$VG_NAME/$LV_lcm"
              mkfs.ext4 "/dev/$VG_NAME/$LV_cfg"
           fi
           process_config
      fi
        ;;
    *"data"*)
        log "Empty partition, setting up LVM..."
        lvmdevices --adddev "$BLK_NODE"
        pvcreate "$BLK_NODE"
        vgcreate "$VG_NAME" "$BLK_NODE"
        if [[ -f /etc/os-release ]] && grep -qi "prplOs" /etc/os-release 2>/dev/null; then
            lvcreate -n "$LV_lcm" -L 1G "$VG_NAME"
            lvcreate -n "$LV_cfg" -L 16M "$VG_NAME"
            lvcreate -n "$LV_mfg" -L 1M "$VG_NAME"
        fi
        lvcreate -n "$LV_NAME" -l 100%FREE "$VG_NAME"

        log "usrfs logical volume created"
        activate_lv ${VG_NAME} ${LV_NAME}

        mkfs.ext4 "/dev/$VG_NAME/$LV_NAME"
        if [[ -f /etc/os-release ]] && grep -qi "prplOs" /etc/os-release 2>/dev/null; then
            mkfs.ext4 "/dev/$VG_NAME/$LV_lcm"
            mkfs.ext4 "/dev/$VG_NAME/$LV_cfg"
        fi
        if [ -d "$OUT_MOUNT" ]; then
            mount "/dev/$VG_NAME/$LV_NAME" "$OUT_MOUNT"
            if [ -d "$SRC_DIR" ]; then
                log "Copying contents from $SRC_DIR to $OUT_MOUNT..."
                busybox cp -a "$SRC_DIR"/* "$OUT_MOUNT"/
            else
                log "Source directory $SRC_DIR does not exist!"
            fi
            # Unmount after copy
            umount -f "$OUT_MOUNT"
        else
            log "Mount point $OUT_MOUNT does not exist!"
        fi
        ;;
    *)
        log "Unknown type, aborting."
        ;;
 esac
}


mount_userdata()
{
 SYMLINK="/dev/block/bootdevice/by-name/userdata"
 BLK_NODE=$(readlink -f "$SYMLINK")
 SRC_DIR="/data"
 LV_NAME="usrfs"
 VG_NAME="vgdata"
 LV_lcm="lcm_data"
 LV_cfg="securestore"

 FS_INFO=$(file -s "$BLK_NODE")
 case "$FS_INFO" in
    *"ext4 filesystem"*)
        mount -t ext4 /dev/block/bootdevice/by-name/userdata "$SRC_DIR"
        log "Userdata mounted on userdata partition"
        ;;
    *"LVM2"*)
        create_links
        mount -t ext4 "/dev/$VG_NAME/$LV_NAME" "$SRC_DIR"
        log "Userdata mounted successfully on usrfs logical volume."
        if [[ -f /etc/os-release ]] && grep -qi "prplOs" /etc/os-release 2>/dev/null; then
          update_vol
          mount -t ext4 "/dev/$VG_NAME/$LV_lcm" /lcm
          mount -t ext4 "/dev/$VG_NAME/$LV_cfg" /cfg
          # Consider volume processing failed if /tmp/lvm_vol_progress exists
          # ToDo: Set ota_status to OTA_FAILED and fallback to previous slot 
          if [ -x /sbin/abctl ]; then
             if [ -f /tmp/lvm_vol_progress ]; then
                echo "OTA_FAILED" > "$STATUS_FILE"
                echo "Logical volume processing failed. Will fallback to previous slot in future builds.." >> /dev/kmsg
                log "Logical volume processing failed. Will fall back to previous slot in future builds.."
             fi
          fi
        fi
        ;;
    *"data"*)
        log "Found Empty userdata partition with no filesystem / lvm setup"
        log "Unable to mount userdata!"
        ;;
    *)
        log "Unknown type, aborting."
        ;;
 esac
}
