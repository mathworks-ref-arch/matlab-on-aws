#!/usr/bin/env bash
#
# Copyright 2023 The MathWorks Inc.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail

# Prepare swap-desktop-solution script
sudo mv /tmp/swap-desktop-solution.sh /usr/local/bin/swap-desktop-solution.sh
sudo chmod +x /usr/local/bin/swap-desktop-solution.sh
