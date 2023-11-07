#! /bin/sh

# Copyright (c) 2023 Qualcomm Innovation Center, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause-Clear

FILES=/sys/class/block/

CURRENT_SLOT=$(abctl --boot_slot)
echo "$CURRENT_SLOT"

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


soc_id=`cat /sys/devices/soc0/soc_id`
if [ ! -d /firmware/image ]; then
        if [ -f /proc/mtd ] && [ `cat /proc/mtd | wc -l` -ge "2" ]; then
                  if [ $soc_id == "570" ] || [ $soc_id == "571" ]; then
                    mtd_block_number=`cat /proc/mtd | grep -i -w modem_a | sed 's/^mtd//' | awk -F ':' '{print $1}'`
                  else
                    mtd_block_number=`cat /proc/mtd | grep -i -w modem | sed 's/^mtd//' | awk -F ':' '{print $1}'`
                  fi
                  echo "MTD : Detected block device : firmware for modem_a "

                  ubiattach -m $mtd_block_number -d 1 /dev/ubi_ctrl

                  mtd_block_number=`cat /proc/mtd | grep -i modem_b | sed 's/^mtd//' | awk -F ':' '{print $1}'`
                  echo "MTD : Detected block device : firmware for modem_b "

                  ubiattach -m $mtd_block_number -d 2 /dev/ubi_ctrl

                 device=/dev/ubi1_0
                 if [ $CURRENT_SLOT == "_b" ]; then
                        device=/dev/ubi2_0
                 fi

                 while [ 1 ]
                 do
                    if [ -c $device ];then
                        mount -t ubifs $device /firmware  -o bulk_read,ro,context=u:r:qcfirmware.miscfile
                        break
                    else
                        sleep 1
                    fi
                 done
                create_symlinks mtd
        else

                if [ $CURRENT_SLOT == "_b" ]; then
                        mount /dev/mmcblk0p2 /firmware
                else
                        mount /dev/mmcblk0p1 /firmware
                fi
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
if [ -f /proc/mtd ] && [ `cat /proc/mtd | wc -l` -ge "2" ]; then
        mount -t ubifs ubi0:cachefs /cache -o bulk_read,context=u:r:cache.miscfile
        mount -t ubifs ubi0:systemrw /overlay -o bulk_read
        mount -t ubifs ubi0:usrfs /data -o bulk_read,rw
else
        mount -t ext4 /dev/block/bootdevice/by-name/cache /cache -o noatime,data=ordered,noauto_da_alloc,discard,noexec,nodev,nosuid,noauto,context=u:r:cache.miscfile
        mount -t ext4 /dev/block/bootdevice/by-name/systemrw /overlay -o noatime,data=ordered,noauto_da_alloc,discard,noexec,nodev,nosuid,noauto
        mount -t ext4 /dev/block/bootdevice/by-name/userdata /data
fi

if [ $soc_id == "570" ] || [ $soc_id == "571" ]; then
    mkdir -p /data/overlay-work
    mkdir -p /data/overlay-work/etc-upper$CURRENT_SLOT
    mkdir -p /data/overlay-work/.etc-work$CURRENT_SLOT
    mount -t overlay -o lowerdir=/etc,upperdir=/data/overlay-work/etc-upper$CURRENT_SLOT,workdir=/data/overlay-work/.etc-work$CURRENT_SLOT overlay /etc
else
    mkdir -p /overlay/etc-upper$CURRENT_SLOT
    mkdir -p /overlay/.etc-work$CURRENT_SLOT
    mount -t overlay -o lowerdir=/etc,upperdir=/overlay/etc-upper$CURRENT_SLOT,workdir=/overlay/.etc-work$CURRENT_SLOT overlay /etc
fi

# Need Restorecon for /persist & /firmware
RESTORECON=/sbin/restorecon
${RESTORECON} -RF /persist /data
${RESTORECON} -R /etc/ -e /etc/rc.d
