#!/usr/bin/env bash
#
# Copyright 2023 The MathWorks Inc.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail

cd /tmp
sudo apt-get -qq update

MATLAB_RELEASE_LOWER=$(echo "${RELEASE}" | awk '{print tolower($0)}')
UBUNTU_VERSION=$(lsb_release -rs)
DEPS_LIST="https://raw.githubusercontent.com/mathworks-ref-arch/container-images/main/matlab-deps/${MATLAB_RELEASE_LOWER}/ubuntu${UBUNTU_VERSION}/base-dependencies.txt"

touch base-dependencies.txt
wget -O base-dependencies.txt $DEPS_LIST || echo "Unable to find MATLAB ${RELEASE} dependencies file for Ubuntu ${UBUNTU_VERSION}."
sudo apt-get -qq install --no-install-recommends $(cat base-dependencies.txt)
rm base-dependencies.txt
