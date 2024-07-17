#####################
# mlm_def
# This file contains the definitions and the defaults for MATLAB licensing.
# The file is read when starting a shell session.
####################

# Copyright 2024 The MathWorks, Inc.

# MLM_LICENSE_FILE: License MATLAB using a license file.
# Change this line to license MATLAB with:
#  - a network license manager, or
#  - a license file
#export MLM_LICENSE_FILE=

# MLM_WEB_LICENSE: License MATLAB using online licensing.
# This mode is used by default when no license file is provided.
if [ -z "${MLM_LICENSE_FILE}" ]; then
    # Use online licensing
    export MLM_WEB_LICENSE="true"
fi
