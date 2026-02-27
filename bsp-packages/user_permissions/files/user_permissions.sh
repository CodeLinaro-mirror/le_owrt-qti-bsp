#! /bin/sh

#Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
#SPDX-License-Identifier: BSD-3-Clause-Clear

if [ -c /dev/kmsg ]; then
	chown root:kmsg /dev/kmsg
	chmod 0664 /dev/kmsg
fi
if [ -d /dev/dma_heap ]; then
	chown -R root:system /dev/dma_heap
	chmod -R 0770 /dev/dma_heap
fi
if [ -f /sys/power/wake_lock ]; then
        chown root:system /sys/power/wake_lock
        chmod 0660 /sys/power/wake_lock
fi
if [ -f /sys/power/wake_unlock ]; then
        chown root:system /sys/power/wake_unlock
        chmod 0660 /sys/power/wake_unlock
fi
if [ -d /mnt/sdcard ]; then
        chown root:sdcard /mnt/sdcard
        chmod 0755 /mnt/sdcard
fi

if [ -f /sys/kernel/boot_kpi/kpi_values ]; then
        chown root:radio /sys/kernel/boot_kpi/kpi_values
        chmod 0664 /sys/kernel/boot_kpi/kpi_values
fi

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

#Set disk group permission for eMMC block device so that abctl can open it.
if [ -b /dev/mmcblk0 ]; then
        chown root:disk /dev/mmcblk0
        chmod 0660 /dev/mmcblk0
fi

#Set disk group permission for UFS block devices (sda/sdb/sdc/sde)
# so that abctl(which run as uid=1000/gid=disk) can open them.
for dev in /dev/sda /dev/sdb /dev/sdc /dev/sde; do
        if [ -b "$dev" ]; then
                chown root:disk "$dev"
                chmod 0660 "$dev"
        fi
done

# UFS BSG device for Boot LUN switching
if [ -c /dev/bsg/ufs-bsg0 ]; then
        chown root:disk /dev/bsg/ufs-bsg0
        chmod 0660 /dev/bsg/ufs-bsg0
fi

#In case of MTD, change permissions for mtd block device
if [ -f /proc/mtd ] && [ `cat /proc/mtd | wc -l` -ge "2" ]; then
        mtd_block_number=`cat /proc/mtd | grep -i recoveryinfo | sed 's/^mtd//' | awk -F ':' '{print $1}'`
        chown system:disk /dev/mtd$mtd_block_number
        chmod 660 /dev/mtd$mtd_block_number
fi

if [ -f /proc/mtd ] && [ `cat /proc/mtd | wc -l` -ge "2" ]; then
        mtd_block_number=`cat /proc/mtd | grep -i misc | sed 's/^mtd//' | awk -F ':' '{print $1}'`
        chown system:disk /dev/mtd$mtd_block_number
        chmod 660 /dev/mtd$mtd_block_number
fi

if [ -f /sys/power/state ]; then
        chown root:system /sys/power/state
        chmod 0660 /sys/power/state
fi

if [ -f /sys/power/autosleep ]; then
        chown root:system /sys/power/autosleep
        chmod 0660 /sys/power/autosleep
fi

if [ -c /dev/input/event0 ]; then
        chown system:plugdev /dev/input/event0
        chmod 0664 /dev/input/event0
fi
