#!/usr/bin/env bash
#
# Copyright 2023-2024 The MathWorks, Inc.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail

# Check if there are any support packages to install.
if [ -z "$SPKGS" ]; then
  echo "No support packages to install. Exiting script."
  exit 0
fi

cd /tmp/

# Install and setup mpm.
# https://github.com/mathworks-ref-arch/matlab-dockerfile/blob/main/MPM.md
sudo apt-get -qq install \
  unzip \
  wget \
  ca-certificates
sudo wget --no-verbose https://www.mathworks.com/mpm/glnxa64/mpm
sudo chmod +x mpm

doc_flag=""
if [[ $RELEASE < 'R2023a' ]]; then
  doc_flag="--doc"
fi

# Use mpm to install support packages in the SPKGS variable
# into the target location. The mpm installation is deleted afterwards.
# The SPKGS variable should be a space separated list of support packages, with no surrounding quotes.
# Use quotes around the destination argument if it contains spaces.
sudo HOME=${HOME} ./mpm install \
  ${doc_flag} \
  --release=${RELEASE} \
  --destination="${MATLAB_ROOT}" \
  --products ${SPKGS} \
  || (echo "MPM Installation Failure. See below for more information:" && cat /tmp/mathworks_root.log  && false)

sudo rm -f mpm /tmp/mathworks_root.log

# Make local user the owner of MATLAB_ROOT and the support packages root folders to enable support packages installation without root permissions.
# See: https://in.mathworks.com/help/matlab/ref/matlabshared.supportpkg.setsupportpackageroot.html#description
GROUP=$(id -gn)
DEFAULT_SPKG_ROOT="/home/${USER}/Documents/MATLAB/SupportPackages"

sudo chown -R ${USER}:${GROUP} "${MATLAB_ROOT}"
if [[ -d "${DEFAULT_SPKG_ROOT}" ]]; then
  sudo chown -R ${USER}:${GROUP} ${DEFAULT_SPKG_ROOT}	
fi

sudo rm -rf ${HOME}/.MathWorks