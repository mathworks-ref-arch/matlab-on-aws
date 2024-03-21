#!/usr/bin/env bash

set -x
echo "Starting matlab-proxy-app"
export PATH=${PATH}:/home/ubuntu/.local/bin

export MWI_APP_PORT=8123
export MWI_SSL_CERT_FILE=/etc/ssl/certs/matlab-proxy_certificate.pem
export MWI_SSL_KEY_FILE=/etc/ssl/certs/matlab-proxy_private-key.pem
export MWI_ENABLE_TOKEN_AUTH=true
# this line exists to set the auth token for matlab-proxy using string replacement
# it is commented only because we prefer not having the env variable over unsetting it
# you should not need to modify this line
# export MWI_AUTH_TOKEN=
export MWI_PROCESS_START_TIMEOUT=300

matlab-proxy-app
