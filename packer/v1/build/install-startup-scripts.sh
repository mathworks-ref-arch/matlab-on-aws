#!/usr/bin/env bash
#
# Copyright 2023 The MathWorks Inc.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail

sudo mkdir -p /opt/mathworks/
sudo mv /tmp/startup/ /opt/mathworks/
chmod +x /opt/mathworks/startup/*.sh
