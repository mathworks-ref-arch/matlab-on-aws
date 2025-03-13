#!/usr/bin/env bash
#
# Copyright 2023-2025 The MathWorks, Inc.

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
if [[ -n "${MATLAB_SOURCE_URL}" ]]; then
    source /var/tmp/config/matlab/mount-data-drive-utils.sh

    source_dir="/mnt/matlab_source"
    mount_device_name="/dev/sdf"
    # This creates and mounts additional vol to the instance
    mount_data_drive "${source_dir}" "${mount_device_name}"

    # This downloads the source artifacts to the mounted vol
    retrieve_artifacts "${MATLAB_SOURCE_URL}" "${source_dir}"
    # Source directory must contain an archives folder that mpm uses for installing products
    archives_path=$(find "${source_dir}" -type d -name "archives" -print -quit)
    
    source_arguments="--source=${archives_path}"
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
  || (echo "MPM Installation Failure. See below for more information:" && cat /tmp/mathworks_root.log && false)

sudo rm -f mpm /tmp/mathworks_root.log

# If a source URL was provided, delete the source archive.
if [[ -n "${MATLAB_SOURCE_URL}" ]]; then
    remove_data_drive "${source_dir}" "${mount_device_name}"
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
