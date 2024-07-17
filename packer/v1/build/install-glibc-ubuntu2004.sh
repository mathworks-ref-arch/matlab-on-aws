#!/usr/bin/env bash
#
# Copyright 2023-2024 The MathWorks, Inc.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail

# Install patched glibc fix - See https://github.com/mathworks/build-glibc-bz-19329-patch
cd /tmp 
mkdir glibc-packages && cd glibc-packages
wget --no-verbose https://github.com/mathworks/build-glibc-bz-19329-patch/releases/download/ubuntu-focal/all-packages.tar.gz 
tar -x -f all-packages.tar.gz --exclude glibc-*.deb --exclude libc6-dbg*.deb
sudo apt-get -qq install \
  libcrypt-dev \
  linux-libc-dev 
sudo apt-get -qq install --no-install-recommends ./*.deb
cd /tmp
sudo rm -rf glibc-packages
