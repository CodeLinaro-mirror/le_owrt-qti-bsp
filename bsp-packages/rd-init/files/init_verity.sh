#!/bin/sh

#Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
#SPDX-License-Identifier: BSD-3-Clause-Clear

# OpenWrt dm-verity setup script
# Usage: ./setup_verity.sh <block_device>
# Example: ./setup_verity.sh /dev/mmcblk0p25


DEV="$1"
NAME="system"
META_FILE="/etc/verity_meta_data.txt"
ROOT_HASH_FILE="/etc/roothash.bin"
SIG_FILE="/etc/verity_sig.bin"

if [ -z "$DEV" ] || [ ! -f "$META_FILE" ] || [ ! -f "$ROOT_HASH_FILE" ]; then
    [ -z "$DEV" ] && echo "verity setup failed with $partition not available"
    [ ! -f "$META_FILE" ] && echo "Error: Metadata file $META_FILE not found."
    [ ! -f "$ROOT_HASH_FILE" ] && echo "Error: Root hash file $ROOT_HASH_FILE not found."
    /sbin/reboot "dm-verity device corrupted" -f
    exit 1
fi

DATABLOCKS=$(awk '/^Datablocks/ {print $2}' "$META_FILE")
BLOCK_SIZE=$(awk '/^Datablocksize/ {print $2}' "$META_FILE")
HASH_OFFSET=$(awk '/^hash_offset/ {print $2}' "$META_FILE")
SALT=$(awk '/^Salt/ {print $2}' "$META_FILE")
FEC_OFFSET_BLOCKS=$(awk '/^fec_offset/ {print $2}' "$META_FILE")
FEC_OFFSET_BYTES=$((FEC_OFFSET_BLOCKS * BLOCK_SIZE))
FEC_ROOTS=2

CMD="/usr/sbin/veritysetup open $DEV $NAME $DEV --root-hash-file=$ROOT_HASH_FILE --salt=$SALT --hash-offset=$HASH_OFFSET --data-block-size=$BLOCK_SIZE --data-blocks=$DATABLOCKS  --hash-block-size=$BLOCK_SIZE  --fec-device=$DEV --fec-offset=$FEC_OFFSET_BYTES --fec-roots=$FEC_ROOTS --root-hash-signature=$SIG_FILE --restart-on-corruption"

#echo "Command: $CMD"
$CMD
RET=$?

if [ $RET -eq 0 ]; then
    echo "Success: dm-verity device '/dev/mapper/$NAME' created." >/dev/kmsg
else
    echo "Failed: veritysetup returned error code $RET.">/dev/kmsg
    /sbin/reboot "dm-verity device corrupted" -f
    exit $RET
fi

/bin/ln -sf ../dm-0 /dev/mapper/"$MAPDEV"

if [ $? -ne 0 ]; then
    echo "error: symlink to /dev/mapper/$MAPDEV has failed." >/dev/kmsg
else
    echo "../dm-0 symlink to /dev/mapper/$MAPDEV is done" >/dev/kmsg
fi

/bin/mount -o ro /dev/mapper/system /mnt/system

if [ $? -ne 0 ]; then
    echo "error: Mount is failed." >/dev/kmsg
    /sbin/reboot "dm-verity device corrupted" -f
fi
