#!/usr/bin/env bash
#
# Copyright 2024-2026 The MathWorks, Inc.

set -x
echo "Starting matlab-proxy-app"

function setup_matlab_proxy_env(){
    export PATH="${PATH}:/home/ubuntu/.local/bin"

    export MWI_APP_PORT='8123'
    export MWI_ENABLE_SSL='true'
    export MWI_ENABLE_TOKEN_AUTH='true'
    # this line exists to set the auth token for matlab-proxy using string replacement
    # it is commented only because we prefer not having the env variable over unsetting it
    # you should not need to modify this line
    # export MWI_AUTH_TOKEN=
    export MWI_PROCESS_START_TIMEOUT='300'

    # Source DDUX context tags (systemd does not source /etc/profile.d/)
    if [[ -r /etc/profile.d/mw_context_tag.sh ]]; then
        source /etc/profile.d/mw_context_tag.sh
    fi
    export MW_CONTEXT_TAGS=${MW_CONTEXT_TAGS:-MATLAB:AWS:V1}
    export MW_DDUX_FORCE_ENABLE=true

    # Write the matlab-proxy log to the common MathWorks log location.
    export MWI_LOG_FILE="/var/log/mathworks/matlab-proxy.log"

    # Start MATLAB in the user's Documents folder.
    MATLAB_STARTUP_FOLDER="/home/${USER}/Documents"
    mkdir -p "${MATLAB_STARTUP_FOLDER}"
    export MWI_MATLAB_STARTUP_SCRIPT="cd ${MATLAB_STARTUP_FOLDER}"
}

function main(){
    setup_matlab_proxy_env
    matlab-proxy-app
}

main "$@"
