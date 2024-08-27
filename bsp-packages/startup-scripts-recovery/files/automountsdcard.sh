#!/bin/sh

#Copyright (c) 2023-2024 Qualcomm Innovation Center, Inc. All rights reserved.
#SPDX-License-Identifier: BSD-3-Clause-Clear

destdir=/mnt/sdcard/
device=/dev/${1}

umount_partition()
{
        umount -lf "${destdir}";
}

mount_partition()
{
        if [ ! -d "${destdir}" ]; then
                mkdir "${destdir}"
        fi

        if [ -e ${device} ]; then
                # Mounting sd-card with user "root" and group "sdcard" with proper umask permissions
                #so that non-root applications can access sdcard by adding to "sdcard" group.
                if ! mount -t auto "${device}" "${destdir}" -o  uid=0,gid=1015,umask=002,nodev,noexec,nosuid; then
                        # failed to mount
                        echo "Mounting sdcard failed !!!"
                        exit 1
                fi
        fi
}

case "${2}" in
add|"")
	umount_partition
	mount_partition
	;;
remove)
	umount_partition
	;;
esac
