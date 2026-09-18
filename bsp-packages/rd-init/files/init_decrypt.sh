#!/bin/sh

#Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
#SPDX-License-Identifier: BSD-3-Clause-Clear

# OpenWrt decyprion using cryptseup

DEV="$1"
DEC_NAME="cryptroot"
sectors="$2"

TABLE="0 $sectors crypt aes-xts-plain64 :64:logon:crypt:rootfs_key 0 $DEV 0"

if [ -z "$DEV" ]; then
    [ -z "$DEV" ] && echo "Device $DEV not available"
    /sbin/reboot "decryption failed" -f
    exit 1
fi

/sbin/dmsetup create "$DEC_NAME" --table "$TABLE"
RET=$?

if [ $RET -eq 0 ]; then
    echo "Success: decrypted device '/dev/mapper/$DEC_NAME' created." >/dev/kmsg
else
    echo "Failed: dmsetup returned error code $RET." >/dev/kmsg
    /sbin/reboot "decryption failed/corrupted" -f
    exit $RET
fi
