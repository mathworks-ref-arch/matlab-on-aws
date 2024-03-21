#!/usr/bin/env bash
#
# Copyright 2023-2024 The MathWorks Inc.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail

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
  || (echo "MPM Installation Failure. See below for more information:" && cat /tmp/mathworks_root.log) \
  && sudo rm -f mpm /tmp/mathworks_root.log

GROUP=$(id -gn)
sudo chown -R ${USER}:${GROUP} "${MATLAB_ROOT}"
sudo rm -rf ${HOME}/.MathWorks
