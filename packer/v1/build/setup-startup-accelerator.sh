#!/usr/bin/env bash
#
# Copyright 2023 The MathWorks Inc.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail

# Move msa.ini file
sudo mkdir -p /usr/local/etc/msa

#755 - owner can read/write/execute, group/others can read/execute.
sudo chmod 755 /usr/local/etc/msa
sudo mv "/var/tmp/config/matlab/startup-accelerator/${RELEASE}/msa.ini" /usr/local/etc/msa/msa.ini

#664 - owner can read/write, group/others can read only. Execute permissions not needed for msa.ini.
sudo chmod 664 /usr/local/etc/msa/msa.ini
