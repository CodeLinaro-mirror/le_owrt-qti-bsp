#! /bin/sh

# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause-Clear

source /usr/bin/mount-userdata.sh
FILES=/sys/class/block

# SELinux context options (cleared for prpl builds)
cache_context=",context=u:r:cache.miscfile"
firmware_context=",context=u:r:qcfirmware.miscfile"

# Determine if this is prplOS build
prplos_build=0
if [ -f /etc/os-release ] && grep -qi "prplOs" /etc/os-release 2>/dev/null; then
    prplos_build=1
    cache_context=""
    firmware_context=""
fi

CURRENT_SLOT=$(abctl --boot_slot)
exec >> /dev/kmsg 2>&1

echo "Current running slot is :$CURRENT_SLOT"
if [ -f /etc/scripts/partition-symlinks.sh ]; then
    source /etc/scripts/partition-symlinks.sh
fi

has_mtd=0
if [ -f /proc/mtd ] && [ "$(wc -l < /proc/mtd)" -ge 2 ]; then
        has_mtd=1
fi

read -r soc_id < /sys/devices/soc0/soc_id

is_overlay_on_data=0
case "$soc_id" in
        570|571) is_overlay_on_data=1 ;;
esac

get_mtd_num()
{
        awk -v name="$1" -F'[: ]+' '
        tolower($0) ~ tolower(name) { sub(/^mtd/, "", $1); print $1; exit }
        ' /proc/mtd
}

update_permission()
{
	#In case of MTD, change permissions for mtd block device
        if [ "$has_mtd" -eq 1 ]; then
                mtd_block_number=$(get_mtd_num "recoveryinfo")
                [ -n "$mtd_block_number" ] || return 0
                chown root:disk /dev/mtd$mtd_block_number
                chmod 660 /dev/mtd$mtd_block_number
        else
		 retry=0
		 while [ "$retry" -lt 10 ]
		 do
			if [ -b /dev/block/bootdevice/by-name/recoveryinfo ]; then
				chown root:disk /dev/block/bootdevice/by-name/recoveryinfo
				chmod 0660 /dev/block/bootdevice/by-name/recoveryinfo
				break
			fi
			[ -d /dev/block/bootdevice/by-name ] || sleep 1
			retry=$((retry + 1))
                done
	fi
}

create_symlinks()
{
        mkdir -p /dev/block/bootdevice/by-name/
        for file in $FILES/$1*
        do
                blockname=$(basename "$file")

                if [ $1 == "mtd" ]; then
                        read -r partition_name < "$file/device/name"
                else
                        partition_name=$(awk -F= '/^PARTNAME=/{print $2; exit}' "$file/uevent" 2>/dev/null)
                fi

                [ -n "$partition_name" ] || continue
                partition_name=/dev/block/bootdevice/by-name/$partition_name
                target_dev=/dev/$blockname
                ln -sf $target_dev $partition_name
        done

        if [ -f /etc/scripts/partition-symlinks.sh ]; then
            create_symlinks_ab "/dev/block/bootdevice/by-name/"
        fi
}

fail_reboot()
{
       create_symlinks $1
       update_permission
       TRIAL_BOOT_STATUS=$(abctl --get_trialboot_status)
       echo "Trial boot status: $TRIAL_BOOT_STATUS" > /dev/kmsg
       echo "Failed to mount modem partition for current running slot, rebooting the device.. " > /dev/kmsg
       if [ $TRIAL_BOOT_STATUS == 0 ]; then
               echo "Marking slot $CURRENT_SLOT as unbootable" > /dev/kmsg
               #set unbootable for current slot
               if [ $CURRENT_SLOT == "_a" ]; then
                       abctl --set_unbootable 0;
               else
                       abctl --set_unbootable 1;
               fi
       fi
       reboot -f
}

echo "Mounting starts"

if [ ! -d /firmware/image ]; then
        if [ "$has_mtd" -eq 1 ]; then
                if [ "$is_overlay_on_data" -eq 1 ]; then
                        mtd_block_number=$(get_mtd_num "modem_a")
                else
                        mtd_block_number=$(get_mtd_num "modem")
                fi

                echo "MTD : Detected block device : firmware for modem_a "
                ubiattach -m $mtd_block_number -d 1 /dev/ubi_ctrl
                st_1=$?

                mtd_block_number=$(get_mtd_num "modem_b")
                echo "MTD : Detected block device : firmware for modem_b "
                ubiattach -m $mtd_block_number -d 2 /dev/ubi_ctrl
		st_2=$?

                device=/dev/ubi1_0
                mtd=/dev/ubi1
                if [ "$CURRENT_SLOT" == "_b" ]; then
                        device=/dev/ubi2_0
			mtd=/dev/ubi2
                 fi
		 if [[ $CURRENT_SLOT == "_a" && $st_1 != 0 ]] || [[ $CURRENT_SLOT == "_b" && $st_2 != 0 ]]; then
			echo "ubiattach failed. Status: $st_1 $st_2" > /dev/kmsg
			fail_reboot mtd
		 fi

                retry=0
                while [ "$retry" -lt 10 ]; do
                    if [ -c "$device" ]; then
                        mount -t ubifs $device /firmware -o bulk_read,ro$firmware_context || fail_reboot mtd
                        break
                    else
                        sleep 1
			#check for volume information
			#In case of empty mtd, ubinfo of vol 0 will error out
			ubinfo $mtd -n 0 >/dev/null 2>&1 || fail_reboot mtd
                    fi
                    retry=$((retry + 1))
                 done
                 [ -c "$device" ] || fail_reboot mtd
		 create_symlinks mtd
        else
                if [ $CURRENT_SLOT == "_b" ]; then
                        mount /dev/mmcblk0p2 /firmware -o ro$firmware_context
                else
                        mount /dev/mmcblk0p1 /firmware -o ro$firmware_context
                fi

		st=$?
                echo "Modem mount status: $st" > /dev/kmsg
                if [[ $st != 0 ]]; then
			fail_reboot mmc
                fi
		create_symlinks mmc
        fi
fi

echo -n "/firmware/image" > /sys/module/firmware_class/parameters/path

if [ "$has_mtd" -eq 1 ]; then
        if [ ! -d /persist ]; then
                echo "creating /persist"
                mkdir -p /persist
        fi
        mount -t ubifs ubi0:persist /persist -o bulk_read
        echo "persist is mounted to /persist"
fi

#Mount cache
if [ ! -d /cache ]; then
        echo "creating /cache dir"
        mkdir -p /cache
fi

if [ "$has_mtd" -eq 1 ]; then
        mount -t ubifs ubi0:cachefs /cache -o bulk_read$cache_context
        mount -t ubifs ubi0:systemrw /overlay -o bulk_read
        mount -t ubifs ubi0:usrfs /data -o bulk_read,rw
else
        mount -t ext4 /dev/block/bootdevice/by-name/cache /cache -o noatime,data=ordered,noauto_da_alloc,discard,noexec,nodev,nosuid,noauto$cache_context
        mount -t ext4 /dev/block/bootdevice/by-name/systemrw /overlay -o noatime,data=ordered,noauto_da_alloc,discard,noexec,nodev,nosuid,noauto
        if [ "$is_overlay_on_data" -eq 1 ]; then
                mount -t ext4 /dev/block/bootdevice/by-name/userdata /data
        fi

fi

if [ "$is_overlay_on_data" -eq 1 ]; then
    mkdir -p "/data/overlay-work/etc-upper$CURRENT_SLOT" "/data/overlay-work/.etc-work$CURRENT_SLOT"
    chcon -t file.conffile "/data/overlay-work/.etc-work$CURRENT_SLOT"
    mount -t overlay \
        -o lowerdir=/etc,upperdir=/data/overlay-work/etc-upper$CURRENT_SLOT,workdir=/data/overlay-work/.etc-work$CURRENT_SLOT \
        overlay /etc
else
    mkdir -p "/overlay/etc-upper$CURRENT_SLOT" "/overlay/.etc-work$CURRENT_SLOT"
    if [ "$prplos_build" -ne 1 ]; then
        chcon -t file.conffile /overlay/.etc-work$CURRENT_SLOT
    fi
    mount -t overlay \
        -o lowerdir=/etc,upperdir=/overlay/etc-upper$CURRENT_SLOT,workdir=/overlay/.etc-work$CURRENT_SLOT \
        overlay /etc

    if [ "$has_mtd" -eq 1 ]; then
        echo "usrfs is a logical volume on ubi0"
    else
       : > "/cache/lvm.log"
    {
       create_lvm
       mount_userdata
    } >>"/cache/lvm.log" 2>&1
    setup_ext_bind_mount
    fi

fi

echo "Mounting completed"

if [ "$prplos_build" -ne 1 ]; then
# Need Restorecon for /persist & /firmware
RESTORECON=/sbin/restorecon
${RESTORECON} -R /etc/ -e /etc/rc.d

# For  Boot KPI we will call restorcon only  for the first boot
# any new files will get labeled on creation

if [ ! -f /persist/.autolabeled ]; then
     # Need Restorecon for /persist
     ${RESTORECON} -RF /persist
     touch  /persist/.autolabeled
fi

if [ ! -f /data/.autolabeled ]; then
        # Need Restorecon for /data
        ${RESTORECON} -RF /data
        touch  /data/.autolabeled
fi
fi
