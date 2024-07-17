#!/usr/bin/env bash
#
# Copyright 2024 The MathWorks, Inc.

# Print commands for logging purposes.
set -x

matlabProxyFiles="/opt/mathworks/matlab-proxy"

# generate a SSL ceritificate for matlab-proxy to use
certFile="/etc/ssl/certs/matlab-proxy_certificate.pem"
keyFile="/etc/ssl/certs/matlab-proxy_private-key.pem"

# If either file does not exist
if [[ ! -f $certFile || ! -f $keyFile ]]; then
    rm -f $certFile
    rm -f $keyFile

    # Since one or both files were missing or have been removed, generate new ones
    python3 $matlabProxyFiles/generate-certificate.py
    mv $matlabProxyFiles/certificate.pem $certFile
    mv $matlabProxyFiles/private_key.pem $keyFile
fi

# set the password for matlab-proxy to use token-authentication
if [[ -n $PASSWORD ]]; then
    launchFile="$matlabProxyFiles/launch-matlab-proxy.sh"
    passwordDec="\$(echo '$PASSWORD' | base64 -d)"
    sed -i "s/# export MWI_AUTH_TOKEN=/export MWI_AUTH_TOKEN=$passwordDec/g" "$launchFile"
fi

# starting the service that runs matlab-proxy
if [[ ${ENABLE_MATLAB_PROXY} == Yes ]]; then
    systemctl enable matlab-proxy.service
    systemctl start matlab-proxy.service
fi
