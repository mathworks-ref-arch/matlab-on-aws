#!/usr/bin/env bash
#
# Copyright 2021-2024 The MathWorks, Inc.

# Print commands for logging purposes, including timestamps.
PS4='+ [\d \t] '
set -x

if [[ -n ${CLOUD_LOG_NAME} ]]; then

    # Prepare cloudwatch config file
    cat > /opt/aws/amazon-cloudwatch-agent/bin/config.json << EOF
{
    "agent": {
        "metrics_collection_interval": 60
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/xrdp.log",
                        "log_group_name": "${CLOUD_LOG_NAME}",
                        "log_stream_name": "xrdp"
                    },
                    {
                        "file_path": "/var/log/mathworks/startup.log",
                        "log_group_name": "${CLOUD_LOG_NAME}",
                        "log_stream_name": "startup"
                    },
                    {
                        "file_path": "/tmp/mathworks_ubuntu.log",
                        "log_group_name": "${CLOUD_LOG_NAME}",
                        "log_stream_name": "matlab"
                    },
                    {
                        "file_path": "/var/log/mathworks/swap_desktop_solution.log",
                        "log_group_name": "${CLOUD_LOG_NAME}",
                        "log_stream_name": "desktop_swap"
                    },
                    {
                        "file_path": "/home/ubuntu/matlab_crash_dump*",
                        "log_group_name": "${CLOUD_LOG_NAME}",
                        "log_stream_name": "matlab_crashes"
                    },
                    {
                        "file_path": "/var/log/dcv/server.log*",
                        "log_group_name": "${CLOUD_LOG_NAME}",
                        "log_stream_name": "dcv_server"
                    },
                    {
                        "file_path": "/var/log/dcv/sessionlauncher.log*",
                        "log_group_name": "${CLOUD_LOG_NAME}",
                        "log_stream_name": "dcv_sessionlauncher"
                    },
                    {
                        "file_path": "/var/log/dcv/agent.*log*",
                        "log_group_name": "${CLOUD_LOG_NAME}",
                        "log_stream_name": "dcv_agent"
                    },
                    {
                        "file_path": "/var/log/syslog",
                        "log_group_name": "${CLOUD_LOG_NAME}",
                        "log_stream_name": "syslog"
                    },
                    {
                        "file_path": "/home/*/.MathWorks/mwrefarch/mwrefarch.log",
                        "log_group_name": "${CLOUD_LOG_NAME}",
                        "log_stream_name": "mwrefarch"
                    }
                ]
            }
        }
    }
}
EOF

    # In this command:
    #     -a fetch-config causes the agent to load the latest version of the CloudWatch agent configuration file;
    #     -m tells the agent the host is on ec2;
    #     -s starts the agent;
    #     -c points to the configuration file
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json
    systemctl enable amazon-cloudwatch-agent
fi
