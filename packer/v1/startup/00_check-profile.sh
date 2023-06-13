#!/usr/bin/env bash
# This script checks if an instance profile has been attached to this instance. This needs to be run before any AWS API calls that would require IAM permissions for the instance.
# Copyright 2023 The MathWorks Inc.

response=""
until [ ! -z "$response" ]; do
    # Keep querying IMDS till a valid Instance profile ARN is obtained
    response=$(curl -s http://169.254.169.254/latest/meta-data/iam/info | grep InstanceProfileArn)
    sleep 2
done
echo "Found attached instance profile: ${response}"