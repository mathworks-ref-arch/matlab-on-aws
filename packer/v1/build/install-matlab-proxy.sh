#!/usr/bin/env bash
#
# Copyright 2024 The MathWorks Inc.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail

# install matlab-proxy python package
python3 -m pip install matlab-proxy==$MATLAB_PROXY_VERSION
echo "installed matlab-proxy"

# move the SSL certificate generator and launcher script to the right directory
RUNTIME_SOURCE=/tmp
CONFIG_SOURCE=/var/tmp/config/matlab-proxy

DESTINATION=/opt/mathworks/matlab-proxy
sudo mkdir -p $DESTINATION

sudo mv $RUNTIME_SOURCE/launch-matlab-proxy.sh $DESTINATION/launch-matlab-proxy.sh
sudo chmod +x $DESTINATION/launch-matlab-proxy.sh

sudo mv $RUNTIME_SOURCE/generate-certificate.py $DESTINATION/generate-certificate.py

# create a systemd service to start matlab-proxy
sudo mv $CONFIG_SOURCE/matlab-proxy.service /etc/systemd/system/matlab-proxy.service
sudo chown root:root /etc/systemd/system/matlab-proxy.service
echo "created matlab-proxy.service"

# update dependencies tree for systemd
sudo systemctl daemon-reload
