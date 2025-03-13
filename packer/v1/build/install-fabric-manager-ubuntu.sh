#!/usr/bin/env bash
#
# Copyright 2023-2025 The MathWorks, Inc.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail

# Install datacenter gpu manager and fabric manager for p4d.24xlarge instance.
# Required to support the use of A series GPUs on the specific instance type.

cd /tmp/ \
  && sudo wget --no-verbose ${NVIDIA_CUDA_KEYRING_URL} \
  && sudo dpkg -i $(basename ${NVIDIA_CUDA_KEYRING_URL}) \
  && sudo apt-get -qq update \
  && sudo apt-get -qq install datacenter-gpu-manager
sudo systemctl --now enable nvidia-dcgm

if [[ -n "${NVIDIA_DRIVER_VERSION}" ]]; then
  sudo apt-get -qq install "nvidia-fabricmanager-${NVIDIA_DRIVER_VERSION}"
fi
