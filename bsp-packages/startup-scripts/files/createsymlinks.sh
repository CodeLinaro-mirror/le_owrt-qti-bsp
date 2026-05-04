#! /bin/sh

#Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
#SPDX-License-Identifier: BSD-3-Clause-Clear

source /usr/bin/mount-userdata.sh
FILES=/sys/class/block
exec >> /dev/kmsg 2>&1

# SELinux context options (cleared for prpl builds)
cache_context=",context=u:r:cache.miscfile"
persist_context=",context=u:r:persist.miscfile"
firmware_context=",context=u:r:qcfirmware.miscfile"

# Determine if this is prplOS build
prplos_build=0
if [ -f /etc/os-release ] && grep -qi "prplOs" /etc/os-release 2>/dev/null; then
    prplos_build=1
    cache_context=""
    persist_context=""
    firmware_context=""
fi

has_mtd=0
if [ -f /proc/mtd ]; then
    mtd_lines=$(wc -l < /proc/mtd)
    [ "$mtd_lines" -ge 2 ] && has_mtd=1
fi

soc_id=$(cat /sys/devices/soc0/soc_id 2>/dev/null)

is_overlay_on_data=0
case "$soc_id" in
    570|571|717|738) is_overlay_on_data=1 ;;
esac

get_mtd_num()
{
        awk -v name="$1" -F'[: ]+' '
        tolower($0) ~ tolower(name) { sub(/^mtd/, "", $1); print $1; exit }
        ' /proc/mtd
}

create_symlinks()
{
        mkdir -p /dev/block/bootdevice/by-name
        for file in $FILES/$1*
        do
                blockname=$(basename "$file")

                if [ $1 == "mtd" ]; then
                       read -r partition_name < "$file/device/name"
                else
                       partition_name=$(
                       awk -F= '/^PARTNAME=/{print $2; exit}' "$file/uevent" 2>/dev/null
                       )
                fi

                [ -n "$partition_name" ] || continue
                ln -sf "/dev/$blockname" "/dev/block/bootdevice/by-name/$partition_name"
        done
}


if [ ! -d /firmware/image ]; then
        if [ "$has_mtd" -eq 1 ]; then
                mtd_block_number=$(get_mtd_num "modem")
                echo "MTD : Detected block device : firmware for modem"

                ubiattach -m $mtd_block_number -d 1 /dev/ubi_ctrl
                device=/dev/ubi1_0

                retry=0
                while [ ! -c "$device" ] && [ "$retry" -lt 10 ]; do
                sleep 1
                retry=$((retry + 1))
                done

                if [ -c $device ]; then
                        mount -t ubifs $device /firmware -o bulk_read,ro$firmware_context
                fi

                create_symlinks mtd
        else
		mount /dev/mmcblk0p1 /firmware -o ro$firmware_context
                create_symlinks mmc
        fi
fi

echo -n "/firmware/image" > /sys/module/firmware_class/parameters/path

if [ "$has_mtd" -eq 1 ]; then
	[ -d /persist ] || mkdir -p /persist
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

        if [ "$is_overlay_on_data" -ne 1 ]; then
            mount -t ubifs ubi0:systemrw /overlay -o bulk_read
        fi
        mount -t ubifs /dev/ubi0_1 /data -o bulk_read,rw
else
        mount -t ext4 /dev/block/bootdevice/by-name/cache /cache -o noatime,data=ordered,noauto_da_alloc,discard,noexec,nodev,nosuid,noauto$cache_context
        mount -t ext4 /dev/block/bootdevice/by-name/systemrw /overlay -o noatime,data=ordered,noauto_da_alloc,discard,noexec,nodev,nosuid,noauto
        mount -t ext4 /dev/block/bootdevice/by-name/persist /persist -o noatime,data=ordered,noauto_da_alloc,discard,noexec,nodev,nosuid,noauto$persist_context
        if [ "$is_overlay_on_data" -eq 1 ]; then
            mount -t ext4 /dev/block/bootdevice/by-name/userdata /data
        fi

fi

if [ "$is_overlay_on_data" -eq 1 ]; then
    mkdir -p /data/overlay-work/etc-upper /data/overlay-work/.etc-work
    chcon -t file.conffile /data/overlay-work/.etc-work
    mount -t overlay -o lowerdir=/etc,upperdir=/data/overlay-work/etc-upper,workdir=/data/overlay-work/.etc-work overlay /etc
else
    mkdir -p /overlay/etc-upper /overlay/.etc-work

    if [ "$prplos_build" -ne 1 ]; then
    chcon -t file.conffile /overlay/.etc-work
    fi

    mount -t overlay -o lowerdir=/etc,upperdir=/overlay/etc-upper,workdir=/overlay/.etc-work overlay /etc

    if [ "$has_mtd" -ne 1 ]; then
        : > /cache/lvm.log
        {
            create_lvm
            mount_userdata
        } >> /cache/lvm.log 2>&1
        setup_ext_bind_mount
    else
        echo "usrfs is a logical volume on ubi0"
    fi
fi

if [ "$prplos_build" -ne 1 ]; then
    RESTORECON=/sbin/restorecon
    "$RESTORECON" -R /etc -e /etc/rc.d

# For  Boot KPI we will call restorcon only  for the first boot
# any new files will get labeled on creation

    if [ ! -f /persist/.autolabeled ]; then
        "$RESTORECON" -RF /persist
        touch /persist/.autolabeled
    fi

    if [ ! -f /data/.autolabeled ]; then
        "$RESTORECON" -RF /data
        touch /data/.autolabeled
    fi
fi
