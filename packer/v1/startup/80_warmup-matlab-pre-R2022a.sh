#!/usr/bin/env bash
#
# Copyright 2023 The MathWorks Inc.

# Print commands for logging purposes, including timestamps.
PS4='+ [\d \t] '
set -x

if [[ -n ${MATLAB_ROOT} ]]; then
    /usr/bin/parallel -j64 -m --nice 10 --arg-file /usr/local/etc/msa/msa.ini /bin/cat "{}" >/dev/null 2>&1
    echo 'Warm up done.'
fi
