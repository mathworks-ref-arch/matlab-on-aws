# Copyright 2026 The MathWorks, Inc.

import logging

from botocore.exceptions import WaiterError

logger = logging.getLogger(__name__)


def run_ssm_shell(ssm_client, instance_id, script, max_attempts=30, delay=5):
    """Run a shell command on an instance via SSM Run Command and wait for it."""
    response = ssm_client.send_command(
        InstanceIds=[instance_id],
        DocumentName="AWS-RunShellScript",
        Parameters={"commands": script.strip().splitlines()},
    )
    command_id = response["Command"]["CommandId"]

    waiter = ssm_client.get_waiter("command_executed")
    try:
        waiter.wait(
            CommandId=command_id,
            InstanceId=instance_id,
            WaiterConfig={"Delay": delay, "MaxAttempts": max_attempts},
        )
    except WaiterError as e:
        # A non-zero exit code also surfaces as a waiter failure, and the
        # invocation itself carries the useful detail, so fall through to it.
        logger.warning(f"SSM command did not complete cleanly: {e}")

    return ssm_client.get_command_invocation(
        CommandId=command_id,
        InstanceId=instance_id,
    )


def run_ssm_shell_checked(ssm_client, instance_id, script, **kwargs):
    """Run a shell command via SSM and return stdout, failing on error."""
    output = run_ssm_shell(ssm_client, instance_id, script, **kwargs)
    if output["Status"] != "Success":
        raise AssertionError(
            f"SSM command failed with status {output['Status']}: "
            f"{output.get('StandardErrorContent', '').strip()}"
        )
    return output.get("StandardOutputContent", "")
