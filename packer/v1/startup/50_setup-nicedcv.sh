#!/usr/bin/env bash
#
# Copyright 2023-2024 The MathWorks, Inc.

# Print commands for logging purposes.
set -x

if [[ ${ACCESS_PROTOCOL} == 'NICE DCV' ]]; then
    systemctl set-default graphical.target
    systemctl isolate graphical.target

    systemctl enable dcvserver
    systemctl start dcvserver
fi
