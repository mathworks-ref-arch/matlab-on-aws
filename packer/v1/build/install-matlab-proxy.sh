#!/usr/bin/env bash
#
# Copyright 2024-2026 The MathWorks, Inc.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail

# Ubuntu 24.04 (noble) ships Python as a PEP 668 "externally managed environment",
# so a system-wide `pip install` is refused unless this override is set. (On 22.04
# this was not required.)
export PIP_BREAK_SYSTEM_PACKAGES=1

# install matlab-proxy python package
# "latest" installs the newest release; any other value is treated as an exact
# version to pin. An empty or unset value is not accepted (set -u makes an unset
# value fail here, and the Packer variable validation rejects an empty string),
# which keeps the behavior in line with the MATLAB_PROXY_VERSION error message.
if [[ "${MATLAB_PROXY_VERSION}" == "latest" ]]; then
  python3 -m pip install matlab-proxy
else
  python3 -m pip install matlab-proxy=="${MATLAB_PROXY_VERSION}"
fi
echo "Installed matlab-proxy version: $(python3 -m pip show matlab-proxy | grep '^Version:' | awk '{print $2}')"

# move the SSL certificate generator and launcher script to the right directory
RUNTIME_SOURCE=/tmp
CONFIG_SOURCE=/var/tmp/config/matlab-proxy

DESTINATION=/opt/mathworks/matlab-proxy
sudo mkdir -p $DESTINATION

sudo mv $RUNTIME_SOURCE/launch-matlab-proxy.sh $DESTINATION/launch-matlab-proxy.sh
sudo chmod +x $DESTINATION/launch-matlab-proxy.sh

# create a systemd service to start matlab-proxy
sudo mv $CONFIG_SOURCE/matlab-proxy.service /etc/systemd/system/matlab-proxy.service
sudo chown root:root /etc/systemd/system/matlab-proxy.service
echo "created matlab-proxy.service"

# update dependencies tree for systemd
sudo systemctl daemon-reload
