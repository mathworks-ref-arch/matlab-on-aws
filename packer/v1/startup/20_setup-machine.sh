#!/usr/bin/env bash
#
# Copyright 2023-2024 The MathWorks, Inc.

# Print commands for logging purposes.
set -x

if [[ -z ${USERNAME} ]]; then
    USERNAME=ubuntu
fi

if [[ -z ${GROUPNAME} ]]; then
    GROUPNAME=ubuntu
fi

# Set password for user
if [[ -n ${PASSWORD} ]]; then
    echo ${USERNAME}:"$(echo "${PASSWORD}" | base64 -d)" | chpasswd
fi

# Disable gnome setup window
echo "yes" >> /home/${USERNAME}/.config/gnome-initial-setup-done

# Start the fabric manager server for p4d instances
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 120")
INSTANCE_TYPE=$(curl -s -H "X-aws-ec2-metadata-token: ${TOKEN}" 169.254.169.254/latest/meta-data/instance-type)
if [[ ${INSTANCE_TYPE} == p4d* ]] ; then
    systemctl enable nvidia-fabricmanager
    systemctl start nvidia-fabricmanager
fi

# Enable all gpus
if [[ -d /proc/driver/nvidia/gpus ]]; then
    if [[ ${INSTANCE_TYPE} != p2* ]] ; then
        # Only for cards with compute capabilities greater than 3.0
        nvidia-xconfig --enable-all-gpus --preserve-busid
    fi
fi

chown -R ${USERNAME}:${GROUPNAME} /home/${USERNAME}/Desktop
