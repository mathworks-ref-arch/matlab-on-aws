#!/usr/bin/env bash
#
# Copyright 2023-2024 The MathWorks, Inc.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail

LOCAL_USER=ubuntu

# Create MATLAB Home directory in ~/Documents,
# which was created in during the MATE setup.
mkdir -p /home/${LOCAL_USER}/Documents/MATLAB/

# Configure MATLAB_ROOT directory
sudo mkdir -p "${MATLAB_ROOT}"
sudo chmod -R 755 "${MATLAB_ROOT}"

# Install and setup mpm.
# https://github.com/mathworks-ref-arch/matlab-dockerfile/blob/main/MPM.md
sudo apt-get -qq install \
  unzip \
  wget \
  ca-certificates
sudo wget --no-verbose https://www.mathworks.com/mpm/glnxa64/mpm
sudo chmod +x mpm

# The mpm --doc flag is supported in R2022b and older releases only.
# To install doc for offline use, follow the steps in
# https://www.mathworks.com/help/releases/R2023a/install/ug/install-documentation-on-offline-machines.html
doc_flag=""
if [[ $RELEASE < 'R2023a' ]]; then
  doc_flag="--doc"
fi

# If a source URL is provided, then use it to install MATLAB and toolboxes.
release_arguments=""
source_arguments=""
if [ -n "${MATLAB_SOURCE_URL}" ]; then
    curl "${MATLAB_SOURCE_URL}" -o matlab.zip
    unzip -q matlab.zip -d /tmp/matlab_source
    rm matlab.zip
    chmod -R 755 /tmp/matlab_source
    source_arguments="--source=/tmp/matlab_source/dvd/archives"
else
    release_arguments="--release=${RELEASE}"
fi

# Run mpm to install MATLAB and toolboxes in the PRODUCTS variable
# into the target location. The mpm installation is deleted afterwards.
# The PRODUCTS variable should be a space separated list of products, with no surrounding quotes.
# Use quotes around the destination argument if it contains spaces.
sudo ./mpm install \
  ${doc_flag} \
  ${release_arguments} \
  ${source_arguments} \
  --destination="${MATLAB_ROOT}" \
  --products ${PRODUCTS} \
  || (echo "MPM Installation Failure. See below for more information:" && cat /tmp/mathworks_root.log && false) \
  && sudo rm -f mpm /tmp/mathworks_root.log

# If a source URL was provided, delete the unzipped archive.
if [ -n "${MATLAB_SOURCE_URL}" ]; then
    rm -r /tmp/matlab_source
fi

# Add symlink to MATLAB
sudo ln -s "${MATLAB_ROOT}/bin/matlab" /usr/local/bin

# Set keyboard settings to windows flavor for any new user.
sudo mkdir -p "/etc/skel/.matlab/${RELEASE}"
sudo cp /var/tmp/config/matlab/matlab.prf  "/etc/skel/.matlab/${RELEASE}/"

# Set keyboard settings to windows flavor for the local user.
sudo mkdir -p "/home/${LOCAL_USER}/.matlab/${RELEASE}"
sudo cp /var/tmp/config/matlab/matlab.prf "/home/${LOCAL_USER}/.matlab/${RELEASE}/"
sudo chown -R ${LOCAL_USER}:${LOCAL_USER} "/home/${LOCAL_USER}/.matlab"

# Enable DDUX collection by default for the VM
cd "${MATLAB_ROOT}/bin/glnxa64"
sudo ./ddux_settings -s -c

# Config license setting
sudo cp /var/tmp/config/matlab/mlm_def.sh /etc/profile.d/

sudo mkdir -p "${MATLAB_ROOT}/licenses"
sudo chmod 777 "${MATLAB_ROOT}/licenses"

# Config MHLM Client setting
sudo cp /var/tmp/config/matlab/mhlmvars.sh /etc/profile.d/

# Config DDUX context tag setting
sudo cp /var/tmp/config/matlab/mw_context_tag.sh /etc/profile.d/

# Copy license file to root of the image
sudo cp /var/tmp/config/matlab/thirdpartylicenses.txt /
