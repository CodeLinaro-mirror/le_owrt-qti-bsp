#! /bin/sh

#Copyright (c) 2023 Qualcomm Innovation Center, Inc. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted (subject to the limitations in the
# disclaimer below) provided that the following conditions are met:
#
#   * Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#
#   * Redistributions in binary form must reproduce the above
#     copyright notice, this list of conditions and the following
#     disclaimer in the documentation and/or other materials provided
#     with the distribution.
#
#   * Neither the name of Qualcomm Innovation Center, Inc. nor the names of its
#     contributors may be used to endorse or promote products derived
#     from this software without specific prior written permission.
#
# NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE
# GRANTED BY THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT
# HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

if [ -c /dev/kmsg ]; then
	chown root:kmsg /dev/kmsg
	chmod 0664 /dev/kmsg
fi
if [ -d /dev/dma_heap ]; then
	chown -R root:system /dev/dma_heap
	chmod -R 0760 /dev/dma_heap
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
        chown radio:radio /sys/kernel/boot_kpi/kpi_values
        chmod 0660 /sys/kernel/boot_kpi/kpi_values
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

#In case of MTD, change permissions for mtd block device
if [ -f /proc/mtd ] && [ `cat /proc/mtd | wc -l` -ge "2" ]; then
        mtd_block_number=`cat /proc/mtd | grep -i recoveryinfo | sed 's/^mtd//' | awk -F ':' '{print $1}'`
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
