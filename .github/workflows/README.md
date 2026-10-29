# Build pipeline configuration

[build.yml](build.yml) builds this reference architecture. It creates a machine image using Packer, generates the CloudFormation template containing the resultant AMI, deploys it and runs the tests.

Start a run from the **Actions** tab: choose **Multi-version Build Pipeline**, then
**Run workflow**. The `matlab_versions` input takes a comma separated list such as
`R2025a,R2024b`. Leaving it empty builds the latest five releases, one job each.

## Repository variables

Settings > Secrets and variables > Actions > Variables.

`AWS_REGION`, `TEMPLATE_STAGING_BUCKET` and `EC2_KEY_NAME` have to be set. Everything else is optional and falls back to the value shown.

| Variable | Default | Purpose |
| --- | --- | --- |
| `AWS_REGION` | none, must be set | Region the build runs in. |
| `TEMPLATE_STAGING_BUCKET` | none, must be set | Bucket in `AWS_REGION` that the template is staged in before deploying. Give it a lifecycle rule that expires the `cfn-staging/` prefix. |
| `EC2_KEY_NAME` | none, must be set | Existing EC2 key pair in `AWS_REGION`, used for `SSHKeyName` on the deployed stack. |
| `REFARCH_TYPE` | `matlab-linux` | Selects the template generation behaviour. |
| `PACKER_DIR` | `./packer/v1` | Directory the Packer build runs in. |
| `METATEMPLATE_FILE_PATH` | `src/aws-matlab-template.json` | Template source recompiled on every run. |
| `S3_BUCKET_URL` | `https://matlab-on-aws.s3.amazonaws.com` | Bucket referenced from the release notes. |
| `DUAL_REPO_URL` | `https://github.com/mathworks-ref-arch/matlab-on-aws-win` | Companion repository linked from the release. |
| `RELEASE_NAME` | `MATLAB on AWS` | Product name the release title starts with, as in `MATLAB on AWS build October 2026: R2026b`. |
| `RELEASE_TAG` | the month the run started, e.g. `2026-10` | Tag the release is created under. Later runs that month get `2026-10.2`, `2026-10.3`; a re-run updates its own release. |
| `SKIP_BUILD` | unset | `true` reuses the image already recorded in the per-release template instead of building one. |
| `SKIP_TEST` | unset | `true` skips deployment and the tests, leaving only the image build. |
| `IS_SUPPLEMENTARY_BUILD` | `true` | `false` lets the run publish its output. Leave unset unless that is intended. |
| `GENERATE_ATTESTATIONS` | enabled | `false` turns off build provenance attestations. |
| `TARGET_REGIONS` | unset | Release regions, comma separated or JSON. |
| `AWS_ROLE_DURATION_SECONDS` | `7200` | Length of the credential session. Runs take over an hour, so a longer value avoids it expiring near the end. |
| `PACKER_VERSION` | `1.15.4` | Packer version the run installs. |
| `PACKER_TIMEOUT_MINUTES` | `120` | Time limit in minutes for the Packer build job. |
| `PACKER_BUILDER_INSTANCE_PROFILE` | unset | Existing instance profile for the Packer build instance. Unset keeps the template's default. |
| `AMI_RETENTION_DAYS` | unset | Tags the built AMI and its snapshots with `MinimumRetentionPeriod` set to this many days. Mock builds are not tagged. A whole number greater than 0; any other value fails the run. |
| `PYTHON_VERSION` | `3.11` | Python version used to run the tests. |

----

Copyright 2026 The MathWorks, Inc.

----
