#!/usr/bin/env bash
#
# Copyright 2023 The MathWorks Inc.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail

# Toolbox cache generation is supported from R2021b onwards. 
if [[ $RELEASE > 'R2021a' ]]; then
    sudo rm -f "${MATLAB_ROOT}/toolbox/local/toolbox_cache-glnxa64.xml"
    sudo python3 /var/tmp/config/matlab/generate_toolbox_cache.py "$MATLAB_ROOT" "${MATLAB_ROOT}/toolbox/local"
    sudo chmod 664 "${MATLAB_ROOT}/toolbox/local/toolbox_cache-glnxa64.xml"
fi

