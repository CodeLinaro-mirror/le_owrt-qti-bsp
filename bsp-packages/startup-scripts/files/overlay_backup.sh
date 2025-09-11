#!/bin/sh
#Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
#SPDX-License-Identifier: BSD-3-Clause-Clear

set -e

# Initialize slot variable
slot=""

# Check if the device is A/B
if [ -x /sbin/abctl ]; then
    echo "Device is A/B type."

    # Get the current boot slot
    slot_output="$(/sbin/abctl --boot_slot 2>/dev/null)"

    # Validate the output and switch the slot variable for backup
    if [ "$slot_output" = "_a" ]; then
        slot="_b"
        echo "Boot slot detected: $slot_output"
    elif [ "$slot_output" = "_b" ]; then
        slot="_a"
        echo "Boot slot detected: $slot_output"
    else
        echo "Error: Invalid boot slot output: '$slot_output'"
        exit 1
    fi
else
    echo "Device is non A/B type."
fi

# Construct the backup path
backup_source="/overlay/etc-upper${slot}/*"
backup_target="/data/etc_backup.tar.gz"

# Check if the source directory exists and is not empty
if [ -d "/overlay/etc-upper${slot}" ] && [ "$(ls -A /overlay/etc-upper${slot})" ]; then
    echo "Backing up from $backup_source to $backup_target..."
    tar -czpf "$backup_target" $backup_source
    echo "Backup completed successfully."
    chmod 600 "$backup_target"
else
    echo "Source directory /overlay/etc-upper${slot} is missing or empty. No Backup created."
fi

# Erase the non-running slot overlay to prepare for OTA, if A/B device
if [ -n "$slot" ]; then
    if [ -d "${backup_source%/*}" ]; then
        echo "Erasing contents of $backup_source..."
        rm -rf $backup_source
        echo "Erasure completed."
    else
        echo "Directory $backup_source does not exist. Nothing to erase."
    fi
fi

