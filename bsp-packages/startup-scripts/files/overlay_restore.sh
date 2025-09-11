#!/bin/sh

#Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
#SPDX-License-Identifier: BSD-3-Clause-Clear

set -e

backup_tar="/data/etc_backup.tar.gz"

if [ ! -f "$backup_tar" ]; then
    echo "Nothing to restore."
    exit 0
fi

#Restore after OTA
cd /
tar -xzpf "$backup_tar"
sync
echo "Backup restored."

#Delete backup tar at the end
rm -rf "$backup_tar"
echo "Backup file deleted."

