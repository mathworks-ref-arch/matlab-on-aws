#!/usr/bin/env bash
#
# Copyright 2023 The MathWorks Inc.

# Print commands for logging purposes.
set -x

if [[ -n ${MLM_LICENSE_FILE} ]]; then
    echo "License MATLAB using Network License Manager"
    echo "export MLM_LICENSE_FILE='${MLM_LICENSE_FILE}'" >> /etc/profile.d/mlmlicensefile.sh
    if [[ -n ${MATLAB_ROOT} ]]; then
        # Disable online licensing
        rm -f "${MATLAB_ROOT}/licenses/license_info.xml"
    fi
else
    echo "License MATLAB using Online Licensing"
fi
