#!/usr/bin/env bash

# Sets up a devicemapper thin pool with loop devices in
# /var/lib/firecracker-containerd/snapshotter/devmapper

# In production we should likely not use loopback devices. But useful for experimenting and testing

set -ex

DATA_BLOCK_SIZE=128 # see https://www.kernel.org/doc/Documentation/device-mapper/thin-provisioning.txt
LOW_WATER_MARK=32768 # picked arbitrarily

DIR=${DEVMAPPER_DIR:-'/var/lib/firecracker-containerd/snapshotter/devmapper' }
POOL=${DEVPOOL:-'fc-dev-thinpool'}

mkdir -p $DIR

# Crate Data file. This will be for the data device
if [[ ! -f "${DIR}/data" ]]; then
touch "${DIR}/data"
truncate -s 5G "${DIR}/data"
fi

# Crate metadata file. This will be for the metadata device
if [[ ! -f "${DIR}/metadata" ]]; then
touch "${DIR}/metadata"
truncate -s 2G "${DIR}/metadata"
fi

# Find the loop device associated with the data, or create one
DATADEV="$(losetup --output NAME --noheadings --associated ${DIR}/data)"
if [[ -z "${DATADEV}" ]]; then
DATADEV="$(losetup --find --show ${DIR}/data)"
fi

# Find the loop device associated with the metadata, or create one
METADEV="$(losetup --output NAME --noheadings --associated ${DIR}/metadata)"
if [[ -z "${METADEV}" ]]; then
METADEV="$(losetup --find --show ${DIR}/metadata)"
fi

SECTORSIZE=512
DATASIZE="$(blockdev --getsize64 -q ${DATADEV})"
LENGTH_SECTORS=$(bc <<< "${DATASIZE}/${SECTORSIZE}")
THINP_TABLE="0 ${LENGTH_SECTORS} thin-pool ${METADEV} ${DATADEV} ${DATA_BLOCK_SIZE} ${LOW_WATER_MARK} 1 skip_block_zeroing"
echo "${THINP_TABLE}"

if ! $(dmsetup reload "${POOL}" --table "${THINP_TABLE}"); then
dmsetup create "${POOL}" --table "${THINP_TABLE}"
fi