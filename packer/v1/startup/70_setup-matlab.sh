#!/usr/bin/env bash
#
# Copyright 2023-2024 The MathWorks Inc.

# Print commands for logging purposes.
set -x

MLM_DEF_FILE=/etc/profile.d/mlm_def.sh

if [[ -n ${MLM_LICENSE_FILE} ]]; then
    echo "License MATLAB using Network License Manager"
    sed -i "s|^#export MLM_LICENSE_FILE=.*|export MLM_LICENSE_FILE='${MLM_LICENSE_FILE}'|" ${MLM_DEF_FILE}
else
    echo "License MATLAB using Online Licensing"
fi

# Setup MATLAB licensing in non-login shells
if [[ -z ${USERNAME} ]]; then
    USERNAME=ubuntu
fi

cat >> "/home/${USERNAME}/.bashrc" << EOF
# Setup MATLAB Licensing
. ${MLM_DEF_FILE}
EOF
