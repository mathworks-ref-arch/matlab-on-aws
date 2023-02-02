#!/usr/bin/env bash
#
# Copyright 2023 The MathWorks Inc.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail

# Ensure noninteractive frontend is disabled
echo 'debconf debconf/frontend select dialog' | sudo debconf-set-selections

# Clean up
sudo rm -rf ~/ubuntu/.bash_history ~/ubuntu/.sudo* ~/root/.bash_history
sudo rm -rf /etc/ssh/*_key /etc/ssh/*_key.pub ~/ubuntu/.ssh/* /root/.ssh/*
sudo rm -rf /home/packer/
sudo rm -rf /var/tmp/config/
