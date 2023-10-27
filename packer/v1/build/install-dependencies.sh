#!/usr/bin/env bash
#
# Copyright 2023 The MathWorks Inc.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail

# Initialise apt
echo 'debconf debconf/frontend select noninteractive' | sudo debconf-set-selections
sudo apt-get -qq update
sudo apt-get -qq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

# Ensure essential utilities are installed
sudo apt-get -qq install gcc make unzip wget

cd /tmp

# Install AWS CLI
# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
curl --show-error --silent "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -qq awscliv2.zip && rm awscliv2.zip
sudo ./aws/install
rm -rf aws

# Download and install CloudWatch agent package
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/download-cloudwatch-agent-commandline.html
wget --no-verbose https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
rm amazon-cloudwatch-agent.deb

# Install pip
sudo apt-get -qq install python3-pip

# Install NVIDIA CUDA Toolkit
if [[ -n "${NVIDIA_CUDA_TOOLKIT}" ]]; then
  wget --no-verbose "${NVIDIA_CUDA_TOOLKIT}"
  chmod +x cuda*.run
  sudo bash cuda*.run --silent --override --toolkit --samples --toolkitpath=/usr/local/cuda-toolkit --samplespath=/usr/local/cuda --no-opengl-libs
  sudo ln -s /usr/local/cuda-toolkit /usr/local/cuda
  echo "export PATH=\"$PATH:/usr/local/cuda-toolkit/bin\"" >> set_cuda_on_path.sh
  sudo cp set_cuda_on_path.sh /etc/profile.d/
  rm cuda*.run
fi

# Install CloudFormation helper scripts
# https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-helper-scripts-reference.html
wget --no-verbose https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-py3-latest.tar.gz
AWS_CFN_INSTALL_DIR=aws-cfn-bootstrap-latest
mkdir $AWS_CFN_INSTALL_DIR
tar -xzf aws-cfn-bootstrap-py3-latest.tar.gz -C $AWS_CFN_INSTALL_DIR --strip-components=1
(
  cd $AWS_CFN_INSTALL_DIR
  sudo python3 setup.py -q install --install-scripts /opt/aws/bin
)
sudo rm -rf aws-cfn-bootstrap-*

# Install Firefox to ensure a web browser is available
sudo apt-get -qq install firefox
