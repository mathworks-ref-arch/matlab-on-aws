#!/usr/bin/env bash
#
# Copyright 2023 The MathWorks Inc.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail

# Install datacenter gpu manager and fabric manager for p4d.24xlarge instance.
# Required to support the use of A series GPUs on the specific instance type.

cd /tmp/ \
  && sudo wget --no-verbose https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb \
  && sudo dpkg -i cuda-keyring_1.0-1_all.deb \
  && sudo apt-get -qq update \
  && sudo apt-get -qq install datacenter-gpu-manager
sudo systemctl --now enable nvidia-dcgm

sudo apt-get -qq install "nvidia-fabricmanager-${NVIDIA_DRIVER_VERSION}"
