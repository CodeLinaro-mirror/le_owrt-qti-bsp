#!/bin/sh
#Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
#SPDX-License-Identifier: BSD-3-Clause-Clear

set -e

# Create backup of overlay/etc-upper of current running slot

# Auto-detect overlay base path from actual /etc overlay mount
OVERLAY_BASE=$(awk '/overlay \/etc/ {for(i=1;i<=NF;i++) if($i ~ /upperdir=/) print $i}' /proc/mounts | sed 's/.*upperdir=//;s|/etc-upper.*||')
if [ -z "$OVERLAY_BASE" ]; then
    # Fallback: check known paths
    if [ -d "/data/overlay-work" ]; then
        OVERLAY_BASE="/data/overlay-work"
    else
        OVERLAY_BASE="/overlay"
    fi
fi

# Initialize slot variable
slot=""
inactive_slot=""

# Check if the device is A/B
if [ -x /sbin/abctl ]; then
    echo "Device is A/B type."

    # Get the current boot slot
    slot_output="$(/sbin/abctl --boot_slot 2>/dev/null)"
    slot="$slot_output"
    # Validate the output
    if [ "$slot_output" = "_a" ]; then
	    inactive_slot="_b"
	    echo "Boot slot detected: $slot_output"
    elif [ "$slot_output" = "_b" ]; then
	    inactive_slot="_a"
	    echo "Boot slot detected: $slot_output"
    else
	    echo "Error: Invalid boot slot output: '$slot_output'"
	    exit 1
    fi
else
    echo "Device is non A/B type."
fi

# Construct the backup path
backup_source="${OVERLAY_BASE}/etc-upper${slot}/"
backup_target="/data/etc_backup.tar.gz"

# Check available space on /data before backup (warn if < 1MB free)
avail_kb=$(df /data 2>/dev/null | awk 'NR==2 {print $4}')
if [ -n "$avail_kb" ] && [ "$avail_kb" -lt 1024 ] 2>/dev/null; then
    echo "WARNING: Low free space on /data (${avail_kb}KB). Backup may fail."
fi

# Check if the source directory exists and is not empty
if [ -d "${OVERLAY_BASE}/etc-upper${slot}" ] && [ "$(ls -A ${OVERLAY_BASE}/etc-upper${slot})" ]; then
    echo "Backing up from $backup_source to $backup_target..."
    if tar -czpf "$backup_target" -C "$backup_source" .; then
        echo "Backup completed successfully."
        chmod 600 "$backup_target"
    else
        echo "Backup failed. Exiting.."
	if [ -f "$backup_target" ]; then
            rm -f "$backup_target"
        fi
        exit 1
    fi
else
    echo "Source directory ${OVERLAY_BASE}/etc-upper${slot} is missing or empty. No Backup created."
fi

#Inactive slot overlay
inactive_slot_path="${OVERLAY_BASE}/etc-upper${inactive_slot}/"
inactive_work_path="${OVERLAY_BASE}/.etc-work${inactive_slot}/"
# Erase the non-running slot overlay to prepare for OTA, if A/B device
if [ -n "$slot" ]; then
    if [ -d "$inactive_slot_path" ]; then
        echo "Erasing contents of $inactive_slot_path..."
        rm -rf $inactive_slot_path
        rm -rf $inactive_work_path
        echo "Erasure completed."
    else
        echo "Directory $inactive_slot_path does not exist. Nothing to erase."
    fi
fi
