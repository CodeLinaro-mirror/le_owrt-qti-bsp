#! /bin/sh

#Copyright (c) 2023 Qualcomm Innovation Center, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause-Clear.



create_symlinks_ab()
{
while [ 1 ]
do
     if [[ -d "$1" ]]; then
      echo "directory is exits"
       break
     else
      echo "waiting for directory to create"
     fi
done
cd $1
devices=$(ls)
 # Create _a symlinks only when _b exists
for device in $devices;do

                        if [ "$(echo "$device" | grep "_b$")" ]; then
                                length=${#device}
                                if [ ${length} -le 2 ]; then
                                        continue
                                fi
                                partition="${device%_b}"
                                if [ -e "$partition" ] && [ -e "$partition_b" ] && [ ! -e "$partition_a" ]; then
                                        ln -s "$partition" "${partition}_a"
                                fi
                        fi
done
}
