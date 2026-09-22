#!/usr/bin/env bash
#
# Copyright 2024-2026 The MathWorks, Inc.

# Print commands for logging purposes.
set -x

matlabProxyFiles="/opt/mathworks/matlab-proxy"

# set the password for matlab-proxy to use token-authentication
if [[ -n $PASSWORD ]]; then
    launchFile="$matlabProxyFiles/launch-matlab-proxy.sh"
    passwordDec="\$(echo '$PASSWORD' | base64 -d)"
    sed -i "s/# export MWI_AUTH_TOKEN=/export MWI_AUTH_TOKEN=$passwordDec/g" "$launchFile"
fi

# Create the matlab-proxy log file alongside the other MathWorks logs and hand it
# to the service user. This script runs as root at startup, so the service (which
# runs unprivileged) does not need to create the file itself.
matlabProxyLog="/var/log/mathworks/matlab-proxy.log"
mkdir -p "$(dirname "$matlabProxyLog")"
touch "$matlabProxyLog"
chown ubuntu "$matlabProxyLog"

# starting the service that runs matlab-proxy
if [[ ${ENABLE_MATLAB_PROXY} == Yes ]]; then
    systemctl enable matlab-proxy.service
    systemctl start matlab-proxy.service
fi
