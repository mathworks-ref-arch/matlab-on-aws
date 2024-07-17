#!/usr/bin/env bash
#
# Copyright 2023-2024 The MathWorks, Inc.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail

# Ensure noninteractive frontend is disabled
echo 'debconf debconf/frontend select dialog' | sudo debconf-set-selections

# Clear build configuration files
sudo rm -rf /var/tmp/config/

# Clear SSH host keys
sudo rm -f /etc/ssh/ssh_host_*_key*
# Clear SSH local config (including authorized keys)
sudo rm -rf ~/.ssh/ /root/.ssh/

# Clear command history
rm -f ~/.bash_history ~/.sudo*
