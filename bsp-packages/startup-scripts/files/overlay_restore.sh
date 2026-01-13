#!/bin/sh

#Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
#SPDX-License-Identifier: BSD-3-Clause-Clear

# passing no argument to run this script will lead to
# restoration of backup after OTA on current running slot.
# passing the argument will copy the saved backup in non-running slot

set -e

update_permissions()
{
while [ 1 ]
do
        if [ -d /dev/block/bootdevice/by-name ]; then
                if [ -b /dev/block/bootdevice/by-name/recoveryinfo ]; then
                        chown root:disk /dev/block/bootdevice/by-name/recoveryinfo
                        chmod 0660 /dev/block/bootdevice/by-name/recoveryinfo

                        break
                else
                        break
                fi
        else
                sleep 1
        fi
done

#In case of MTD, change permissions for mtd block device
if [ -f /proc/mtd ] && [ `cat /proc/mtd | wc -l` -ge "2" ]; then
        mtd_block_number=`cat /proc/mtd | grep -i recoveryinfo | sed 's/^mtd//' | awk -F ':' '{print $1}'`
        chown system:disk /dev/mtd$mtd_block_number
        chmod 660 /dev/mtd$mtd_block_number
fi
}

# Get the current boot slot
current_slot=""
if [ -x /sbin/abctl ]; then
	current_slot="$(/sbin/abctl --boot_slot 2>/dev/null)"
fi

inactive_slot=""


target_path="/overlay/etc-upper$current_slot"
sync
#Restore after OTA
if [ $# -eq 0 ]; then
	backup_tar="/data/etc_backup.tar.gz"
	if [ ! -f "$backup_tar" ]; then
		echo "Nothing to restore."
		exit 0
	fi

    #If A/B and fallback scenario -> no Restoration required. Delete backup and exit.
    if [ -x /sbin/abctl ]; then 
         update_permissions
         # Get trial boot status
         trial_status="$(abctl --get_trialboot_status 2>/dev/null || echo __ERR__)"

         # Get current slot
         slot_str="$(abctl --boot_slot 2>/dev/null || echo __ERR__)"
         # Map _a ? 0, _b ? 1
         if [ "$slot_str" = "_a" ]; then
            slot_num=0
         elif [ "$slot_str" = "_b" ]; then
            slot_num=1
         fi

         # Get active status for current slot
         active_line="$(abctl --get_active_status "$slot_num" 2>/dev/null || echo __ERR__)"
         # Normalize spacing and case for robust matching
         active_lc="$(echo "$active_line" | tr 'A-Z' 'a-z')"
         # Detect keywords
         is_active=false
         case "$active_lc" in
             *" is active"* )
                 is_active=true
                 ;;
             *" is inactive"* )
                 is_active=false
                 ;;
             *)
                 is_active=false
                 ;;
         esac
         # check if it is fallback scenario
         if [ "$trial_status" -eq 1 ] && [ "$is_active" != true ]; then
            rm -rf "$backup_tar"
            echo "Fallback scenario. Other slot didnt boot. Backup file deleted." >> /dev/kmsg
            exit 0
         fi
    fi

    if tar -xzpf "$backup_tar" -C "$target_path"; then
        sync
        echo "Backup restored."

        #Delete backup tar at the end
        rm -rf "$backup_tar"
        echo "Backup file deleted."

	#remount
	mount -o remount,lowerdir=/etc,upperdir=/overlay/etc-upper$current_slot,workdir=/overlay/.etc-work$current_slot /etc
	echo "remount done "
    else
        echo "ERROR: Backup Restoration failed after OTA. " > /dev/kmsg
        if [ -x /sbin/abctl ]; then
            echo "Rebooting the device." > /dev/kmsg
            reboot
        fi
    fi
else
    # Copying to other slot for mirror copy feature
    # Validate the output and switch the slot variable for restoration
    echo "Mirror copy requested.."
    if [ "$current_slot" = "_a" ]; then
         inactive_slot="_b"
         echo "Boot slot detected: $current_slot"
    elif [ "$current_slot" = "_b" ]; then
        inactive_slot="_a"
        echo "Boot slot detected: $current_slot"
    else
        echo "Error: Invalid boot slot output: '$current_slot'"
        exit 1
    fi

    source_path="${target_path}/"
    dest_path="/overlay/etc-upper$inactive_slot"
    if [ -d "$dest_path" ]; then
            echo "Erasing contents of $dest_path.."
            rm -rf $dest_path
            echo "Erasure completed."
    fi
    mkdir -p "$dest_path"
    chcon -t file.conffile "$dest_path"

    echo "Copying contents from source to destination..."
    cp -acrpdf "${source_path}"* "$dest_path" || { echo "Copy failed."; exit 1; }
    echo "Copy completed.."
fi

