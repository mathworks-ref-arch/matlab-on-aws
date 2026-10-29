# Copyright 2026 The MathWorks, Inc.

"""
End-to-end smoke tests that check the deployed instance.
"""

import os
import xml.etree.ElementTree as ET

import pytest

from helpers import run_ssm_shell_checked

# Set by the pipeline when the AMI came from a previous release rather than a
# build in this run, and to the AMI it deployed.
MOCK_BUILD = os.environ.get("MOCK_BUILD", "").lower() == "true"
EXPECTED_AMI_ID = os.environ.get("EXPECTED_AMI_ID", "")

# /usr/local/bin/matlab links to <matlabroot>/bin/matlab; print <matlabroot>/VersionInfo.xml.
VERSION_INFO = """
set -e
root=$(dirname "$(dirname "$(readlink -e /usr/local/bin/matlab)")")
cat "$root/VersionInfo.xml"
"""


@pytest.mark.skipif(
    MOCK_BUILD, reason="a mock build deploys an AMI this run did not produce"
)
@pytest.mark.skipif(not EXPECTED_AMI_ID, reason="EXPECTED_AMI_ID is not set")
def test_instance_booted_the_image_this_build_produced(ec2_client, instance_id):
    """The instance is running the image this build produced."""
    image_id = ec2_client.describe_instances(InstanceIds=[instance_id])[
        "Reservations"
    ][0]["Instances"][0]["ImageId"]
    assert image_id == EXPECTED_AMI_ID, (
        f"Instance runs {image_id}, but this build produced {EXPECTED_AMI_ID}"
    )


def test_matlab_is_installed(ssm_client, instance_id, matlab_version):
    """The image carries the MATLAB release under test."""
    version_info = run_ssm_shell_checked(ssm_client, instance_id, VERSION_INFO)
    release = ET.fromstring(version_info.strip()).findtext("release")
    assert release == matlab_version, (
        f"Image reports MATLAB {release!r}, expected {matlab_version}"
    )
