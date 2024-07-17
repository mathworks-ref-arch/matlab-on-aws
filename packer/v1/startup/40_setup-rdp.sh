#!/usr/bin/env bash
#
# Copyright 2023-2024 The MathWorks, Inc.

# Print commands for logging purposes.
set -x

if [[ ${ACCESS_PROTOCOL} == RDP ]]; then
    systemctl enable xrdp
    systemctl start xrdp
fi
