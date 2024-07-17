#!/usr/bin/env bash
#
# Copyright 2023-2024 The MathWorks, Inc.

# Print commands for logging purposes, including timestamps.
PS4='+ [\d \t] '
set -x

# Make EBS volumes available (including NVMe instance store volumes)
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-using-volumes.html

FSTYPE=xfs

i=0
for DISK in $(lsblk -dpn -o NAME); do

    echo "${DISK}"
    # Find disks with no file system
    if [[ $(file -bs "${DISK}") == 'data' ]]; then

        echo "Create file system"
        mkfs -t ${FSTYPE} "${DISK}"
        partprobe "${DISK}"

        MOUNTPOINT=/data${i}
        i=$((i+1))
        echo "Mount at ${MOUNTPOINT}"
        mkdir -p ${MOUNTPOINT}
        mount "${DISK}" ${MOUNTPOINT}
        chmod 1777 ${MOUNTPOINT}

        echo "Mount after reboot"
        UUID=$(blkid -o value -s UUID "${DISK}")
        echo "UUID=${UUID} ${MOUNTPOINT} ${FSTYPE} defaults,nofail 0 2" >> /etc/fstab

    fi
done
