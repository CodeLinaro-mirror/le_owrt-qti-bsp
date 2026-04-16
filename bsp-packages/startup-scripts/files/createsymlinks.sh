#! /bin/sh

#Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
#SPDX-License-Identifier: BSD-3-Clause-Clear

source /usr/bin/mount-userdata.sh
FILES=/sys/class/block/
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

create_symlinks()
{
        for file in $FILES/$1*
        do
                blockname=`basename $file`
                if [  $1 == "mtd" ]; then
                        partition_name=`cat $file/device/name`
                else
                        partition_name=`cat $file/uevent | awk '{ for ( n=1; n<=NF; n++ ) if($n ~ "PARTNAME") print $n }' | awk '{split($0,a, "=");print a[2]}'`
                fi
                mkdir -p /dev/block/bootdevice/by-name/
                partition_name=/dev/block/bootdevice/by-name/$partition_name
                target_dev=/dev/$blockname
                ln -s $target_dev $partition_name
        done
}


if [ ! -d /firmware/image ]; then
        if [ -f /proc/mtd ] && [ `cat /proc/mtd | wc -l` -ge "2" ]; then
                mtd_block_number=`cat /proc/mtd | grep -i modem | sed 's/^mtd//' | awk -F ':' '{print $1}'`
                echo "MTD : Detected block device : firmware for modem "
                mkdir -p $dir

                ubiattach -m $mtd_block_number -d 1 /dev/ubi_ctrl
                device=/dev/ubi1_0
                while [ 1 ]
                do
                    if [ -c $device ]
					then
                        mount -t ubifs /dev/ubi1_0 /firmware  -o bulk_read,ro$firmware_context
                        break
					else
                        sleep 1
                    fi
                done
                create_symlinks mtd
        else
		mount /dev/mmcblk0p1 /firmware -o ro$firmware_context
                create_symlinks mmc
        fi
fi

echo -n "/firmware/image" > /sys/module/firmware_class/parameters/path

if [ -f /proc/mtd ] && [ `cat /proc/mtd | wc -l` -ge "2" ]; then
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

soc_id=`cat /sys/devices/soc0/soc_id`
if [ -f /proc/mtd ] && [ `cat /proc/mtd | wc -l` -ge "2" ]; then
        mount -t ubifs ubi0:cachefs /cache -o bulk_read$cache_context
        if [ $soc_id != "570" ] && [ $soc_id != "571" ] && [ $soc_id != "717" ] && [ $soc_id != "738" ]; then
            mount -t ubifs ubi0:systemrw /overlay -o bulk_read
        fi
        mount -t ubifs /dev/ubi0_1 /data -o bulk_read,rw
else
        mount -t ext4 /dev/block/bootdevice/by-name/cache /cache -o noatime,data=ordered,noauto_da_alloc,discard,noexec,nodev,nosuid,noauto$cache_context
        mount -t ext4 /dev/block/bootdevice/by-name/systemrw /overlay -o noatime,data=ordered,noauto_da_alloc,discard,noexec,nodev,nosuid,noauto
        mount -t ext4 /dev/block/bootdevice/by-name/persist /persist -o noatime,data=ordered,noauto_da_alloc,discard,noexec,nodev,nosuid,noauto$persist_context
        if [ $soc_id == "570" ] || [ $soc_id == "571" ] || [ $soc_id == "717" ] || [ $soc_id == "738" ]; then
            mount -t ext4 /dev/block/bootdevice/by-name/userdata /data
        fi

fi

if [ $soc_id == "570" ] || [ $soc_id == "571" ] || [ $soc_id == "717" ] || [ $soc_id == "738" ]; then
    mkdir -p /data/overlay-work
    mkdir -p /data/overlay-work/etc-upper
    mkdir -p /data/overlay-work/.etc-work
    chcon -t file.conffile /data/overlay-work/.etc-work
    mount -t overlay -o lowerdir=/etc,upperdir=/data/overlay-work/etc-upper,workdir=/data/overlay-work/.etc-work overlay /etc
else
    mkdir -p /overlay/etc-upper
    mkdir -p /overlay/.etc-work
    if [ "$prplos_build" -ne 1 ]; then
    chcon -t file.conffile /overlay/.etc-work
    fi
    mount -t overlay -o lowerdir=/etc,upperdir=/overlay/etc-upper,workdir=/overlay/.etc-work overlay /etc
    if [ -f /proc/mtd ] && [ `cat /proc/mtd | wc -l` -ge "2" ]; then
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
if [ "$prplos_build" -ne 1 ]; then
RESTORECON=/sbin/restorecon
${RESTORECON} -R  /etc -e /etc/rc.d

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
