#! /bin/sh

#Copyright (c) 2021-2022 Qualcomm Innovation Center, Inc. All rights reserved.
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

FILES=/sys/class/block/

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
                        mount -t ubifs /dev/ubi1_0 /firmware -o bulk_read
                        break
					else
                        sleep 0.010
                    fi
                done
                create_symlinks mtd
        else
                mount /dev/mmcblk0p1 /firmware
                create_symlinks mmc
        fi
fi

echo -n "/firmware/image" > /sys/module/firmware_class/parameters/path
