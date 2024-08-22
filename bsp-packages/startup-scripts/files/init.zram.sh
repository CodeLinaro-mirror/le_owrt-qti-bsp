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

enable_zram_config()
{
    #Enable ZRAM based on RAM size
    echo 100 > /proc/sys/vm/swappiness
    if [ -d /sys/block/zram0 ]; then
        MemTotalStr=$(grep -m1 MemTotal /proc/meminfo)
        MemTotal=${MemTotalStr:16:8}
        if [ $MemTotal -gt $((512*1024)) ]; then
            echo $((256*1024*1024)) > /sys/block/zram0/disksize
        elif [ $MemTotal -gt $((256*1024)) ]; then
            echo $((128*1024*1024)) > /sys/block/zram0/disksize
        elif [ $MemTotal -gt $((128*1024)) ]; then
            echo $((64*1024*1024)) > /sys/block/zram0/disksize
        else
            echo $((16*1024*1024)) > /sys/block/zram0/disksize
        fi
        mkswap /dev/zram0
        swapon /dev/zram0 -p 32758
    fi
}

enable_zram_config
