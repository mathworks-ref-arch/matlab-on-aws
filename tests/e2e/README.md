# End-to-End Tests

This directory contains the end-to-end test suite for the MATLAB on AWS
(Linux) reference architecture that run against a live CloudFormation stack.

## What Is Tested

- The instance runs the image this build produced (skipped on a mock build)
- MATLAB is installed and reports the release under test

The tests do not start MATLAB, so no license is needed.

## Prerequisites

- A deployed CloudFormation stack from this reference architecture.
- AWS credentials with access to the stack, EC2, and SSM. These are read from the
  environment by boto3 (for example, supplied to a CI runner via OIDC).
- The instance must be registered with SSM (a managed instance) so Run Command can
  reach it.

## Configuration

Each value can be provided as a CLI option or an environment variable. When both
are set, the CLI option wins.

| Setting       | CLI option      | Environment variable    | Default     | Notes                                  |
| ------------- | --------------- | ----------------------- | ----------- | ---------------------------------------|
| Stack name    | `--stack-name`  | `STACK_NAME`            | _required_  | CloudFormation stack to test against.  |
| AWS region    | `--aws-region`  | `AWS_REGION`            | _required_  | Region the stack is deployed in.       |
| MATLAB release | | `MATLAB_VERSION` | from the stack name | Release under test, used when the stack name does not contain one. |
| Built image | | `EXPECTED_AMI_ID` | unset | Image this build produced. The image check skips when it is unset or `MOCK_BUILD` is `true`. |

## Setup

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Running

```bash
pytest --stack-name my-matlab-stack --aws-region us-east-1
```

Equivalently, using environment variables:

```bash
export STACK_NAME=my-matlab-stack
export AWS_REGION=us-east-1

pytest
```

## Notes
- Logs are captured and pytest replays them only for failing tests.

----

Copyright 2026 The MathWorks, Inc.

----
