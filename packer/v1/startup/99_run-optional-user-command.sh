#!/bin/bash
#
# Copyright 2023 The MathWorks Inc.

PS4='+ [\d \t] '
set -x

echo "Optional user command - script started."

# Check whether the value of the parameter optional user command is empty.
if [[ -z "${OPTIONAL_USER_COMMAND}" ]]
then
    echo "No optional user command was passed."
else
    echo "The passed string is an inline shell command."
    eval "${OPTIONAL_USER_COMMAND}"
fi

echo "Optional user command - script completed."
