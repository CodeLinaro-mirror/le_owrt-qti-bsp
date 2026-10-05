#! /bin/sh

#Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
#SPDX-License-Identifier: BSD-3-Clause-Clear

. /lib/functions.sh

log()
{
	logger -t secure-fscrypt "$*"
	echo "secure-fscrypt: $*"
}

is_mounted()
{
	mount | grep -q " $1 "
}

wait_for_path()
{
	path="$1"
	timeout="$2"
	i=0

	while [ "$i" -lt "$timeout" ]; do
		[ -e "$path" ] && return 0
		sleep 1
		i=$((i + 1))
	done

	return 1
}

wait_for_mount()
{
	mp="$1"
	timeout="$2"
	i=0

	while [ "$i" -lt "$timeout" ]; do
		is_mounted "$mp" && return 0
		sleep 1
		i=$((i + 1))
	done

	return 1
}

start_secure_fscrypt()
{
	local enabled mount_point enc_dir blob device timeout

	config_get_bool enabled cfg enabled 1
	config_get mount_point cfg mount "/lcm"
	config_get enc_dir cfg dir "/lcm/secure"
	config_get blob cfg blob "/data/wrapped_key.mbn"
	config_get device cfg device "/dev/fspapp_fscrypt"
	config_get timeout cfg timeout "30"

	[ "$enabled" = "1" ] || {
		log "disabled by config"
		return 0
	}

	log "waiting for mount $mount_point"
	if ! wait_for_mount "$mount_point" "$timeout"; then
		log "ERROR: mountpoint $mount_point not mounted"
		return 1
	fi

	log "waiting for device $device"
	if ! wait_for_path "$device" "$timeout"; then
		log "ERROR: device $device not found"
		return 1
	fi

	log "waiting for wrapped blob $blob"
	if ! wait_for_path "$blob" "$timeout"; then
		log "ERROR: wrapped blob $blob not found"
		return 1
	fi

	log "ensuring encrypted directory $enc_dir"

	/usr/bin/secure-fscryptctl \
		--ensure \
		--mount "$mount_point" \
		--dir "$enc_dir" \
		--blob "$blob" \
		--device "$device"

	rc=$?
	if [ "$rc" -ne 0 ]; then
		log "ERROR: secure-fscryptctl failed rc=$rc"
		return "$rc"
	fi

	log "encrypted directory ready: $enc_dir"
	return 0
}
