# Copyright 2023-2025 The MathWorks, Inc.

packer {
  required_plugins {
    amazon = {
      version = ">= 1.3.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# The following variables may have different value across releases and 
# it is recommended to modify them via the release-specific configuration file.
# To learn the release-specific values, visit the configuration file
# under /packer/v1/release-config/ folder.

variable "PRODUCTS" {
  type        = string
  default     = "5G_Toolbox AUTOSAR_Blockset Aerospace_Blockset Aerospace_Toolbox Antenna_Toolbox Audio_Toolbox Automated_Driving_Toolbox Bioinformatics_Toolbox Bluetooth_Toolbox C2000_Microcontroller_Blockset Communications_Toolbox Computer_Vision_Toolbox Control_System_Toolbox Curve_Fitting_Toolbox DDS_Blockset DSP_HDL_Toolbox DSP_System_Toolbox Database_Toolbox Datafeed_Toolbox Deep_Learning_HDL_Toolbox Deep_Learning_Toolbox Econometrics_Toolbox Embedded_Coder Filter_Design_HDL_Coder Financial_Instruments_Toolbox Financial_Toolbox Fixed-Point_Designer Fuzzy_Logic_Toolbox GPU_Coder Global_Optimization_Toolbox HDL_Coder HDL_Verifier Image_Acquisition_Toolbox Image_Processing_Toolbox Industrial_Communication_Toolbox Instrument_Control_Toolbox LTE_Toolbox Lidar_Toolbox MATLAB MATLAB_Coder MATLAB_Compiler MATLAB_Compiler_SDK MATLAB_Production_Server MATLAB_Report_Generator MATLAB_Test MATLAB_Web_App_Server Mapping_Toolbox Medical_Imaging_Toolbox Mixed-Signal_Blockset Model_Predictive_Control_Toolbox Motor_Control_Blockset Navigation_Toolbox Optimization_Toolbox Parallel_Computing_Toolbox Partial_Differential_Equation_Toolbox Phased_Array_System_Toolbox Powertrain_Blockset Predictive_Maintenance_Toolbox RF_Blockset RF_PCB_Toolbox RF_Toolbox ROS_Toolbox Radar_Toolbox Reinforcement_Learning_Toolbox Requirements_Toolbox Risk_Management_Toolbox Robotics_System_Toolbox Robust_Control_Toolbox Satellite_Communications_Toolbox Sensor_Fusion_and_Tracking_Toolbox SerDes_Toolbox Signal_Integrity_Toolbox Signal_Processing_Toolbox SimBiology SimEvents Simscape Simscape_Battery Simscape_Driveline Simscape_Electrical Simscape_Fluids Simscape_Multibody Simulink Simulink_3D_Animation Simulink_Check Simulink_Coder Simulink_Compiler Simulink_Control_Design Simulink_Coverage Simulink_Design_Optimization Simulink_Design_Verifier Simulink_Desktop_Real-Time Simulink_Fault_Analyzer Simulink_PLC_Coder Simulink_Real-Time Simulink_Report_Generator Simulink_Test SoC_Blockset Stateflow Statistics_and_Machine_Learning_Toolbox Symbolic_Math_Toolbox System_Composer System_Identification_Toolbox Text_Analytics_Toolbox UAV_Toolbox Vehicle_Dynamics_Blockset Vehicle_Network_Toolbox Vision_HDL_Toolbox WLAN_Toolbox Wavelet_Toolbox Wireless_HDL_Toolbox Wireless_Testbench"
  description = "Target products to install in the machine image, e.g. MATLAB SIMULINK."
}

variable "SPKGS" {
  type        = string
  default     = "Deep_Learning_Toolbox_Model_for_AlexNet_Network Deep_Learning_Toolbox_Model_for_EfficientNet-b0_Network Deep_Learning_Toolbox_Model_for_GoogLeNet_Network Deep_Learning_Toolbox_Model_for_ResNet-101_Network Deep_Learning_Toolbox_Model_for_ResNet-18_Network Deep_Learning_Toolbox_Model_for_ResNet-50_Network Deep_Learning_Toolbox_Model_for_Inception-ResNet-v2_Network Deep_Learning_Toolbox_Model_for_Inception-v3_Network Deep_Learning_Toolbox_Model_for_DenseNet-201_Network Deep_Learning_Toolbox_Model_for_Xception_Network Deep_Learning_Toolbox_Model_for_MobileNet-v2_Network Deep_Learning_Toolbox_Model_for_Places365-GoogLeNet_Network Deep_Learning_Toolbox_Model_for_NASNet-Large_Network Deep_Learning_Toolbox_Model_for_NASNet-Mobile_Network Deep_Learning_Toolbox_Model_for_ShuffleNet_Network Deep_Learning_Toolbox_Model_for_DarkNet-19_Network Deep_Learning_Toolbox_Model_for_DarkNet-53_Network Deep_Learning_Toolbox_Model_for_VGG-16_Network Deep_Learning_Toolbox_Model_for_VGG-19_Network"
  description = "Target support packages to install in the machine image, e.g. Deep_Learning_Toolbox_Model_for_AlexNet_Network."
}

variable "RELEASE" {
  type        = string
  default     = "R2025b"
  description = "Target MATLAB release to install in the machine image, must start with \"R\"."

  validation {
    condition     = can(regex("^R20[0-9][0-9](a|b)$", var.RELEASE))
    error_message = "The RELEASE value must be a valid MATLAB release, starting with \"R\"."
  }
}

variable "BASE_AMI_NAME" {
  type        = string
  default     = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
  description = "Default AMI name refers to the Ubuntu Server 22.04 image provided by Canonical."
}

variable "BUILD_SCRIPTS" {
  type        = list(string)
  default     = ["install-startup-scripts.sh", "install-swap-desktop-solution.sh", "install-dependencies.sh", "install-matlab-proxy.sh", "install-matlab-dependencies-ubuntu.sh", "install-ubuntu-desktop.sh", "install-mate.sh", "install-matlab.sh", "install-support-packages.sh", "setup-startup-accelerator.sh", "install-fabric-manager-ubuntu.sh", "generate-toolbox-cache.sh", "cleanup.sh"]
  description = "The list of installation scripts Packer will use when building the image."
}

variable "STARTUP_SCRIPTS" {
  type        = list(string)
  default     = [".env", "10_setup-disks.sh", "20_setup-machine.sh", "30_setup-logging.sh", "40_setup-rdp.sh", "50_setup-nicedcv.sh", "60_setup-matlab-proxy.sh", "70_setup-matlab.sh", "80_warmup-matlab.sh", "85_warmup-mathworks-service-host.sh", "99_run-optional-user-command.sh"]
  description = "The list of startup scripts Packer will copy to the remote machine image builder, which can be used during the CloudFormation Stack creation."
}

variable "RUNTIME_SCRIPTS" {
  type        = list(string)
  default     = ["swap-desktop-solution.sh", "launch-matlab-proxy.sh", "generate-certificate.py"]
  description = "The list of runtime scripts Packer will copy to the remote machine image builder, which can be used after the CloudFormation Stack creation."
}

variable "DCV_INSTALLER_URL" {
  type        = string
  default     = "https://d1uj6qtbmh3dt5.cloudfront.net/2023.0/Servers/nice-dcv-2023.0-15065-ubuntu2204-x86_64.tgz"
  description = "The URL to install NICE DCV, a remote display protocol to use."
}

variable "NVIDIA_DRIVER_VERSION" {
  type        = string
  default     = "535"
  description = "The version of target NVIDIA Driver to install."
}

variable "NVIDIA_CUDA_TOOLKIT" {
  type        = string
  default     = "https://developer.download.nvidia.com/compute/cuda/12.2.2/local_installers/cuda_12.2.2_535.104.05_linux.run"
  description = "The URL to install NVIDIA CUDA Toolkit into the target machine image. "
}

variable "NVIDIA_CUDA_KEYRING_URL" {
  type        = string
  default     = "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb"
  description = "NVIDIA CUDA keyring url."
}

variable "MATLAB_PROXY_VERSION" {
  type        = string
  description = "Version of matlab-proxy to pull from PyPI."
  default     = "0.10.0"
  validation {
    condition     = length(var.MATLAB_PROXY_VERSION) > 0
    error_message = "A valid version must be provided to install matlab-proxy."
  }
}

variable "MSA_URL" {
  type        = string
  description = "URL pointing to a valid MATLAB Startup Accelerator file. If left unset, a default URL will be constructed based on the RELEASE variable."
  default     = null
}

variable "MATLAB_SOURCE_URL" {
  type        = string
  default     = ""
  description = "Optional URL from which to download a MATLAB and toolbox source file, for use with the mpm --source option."
}

# The following variables share the same setup across all MATLAB releases.
variable "VPC_ID" {
  type        = string
  default     = ""
  description = "The target AWS VPC to be used by Packer. If not specified, Packer will use default VPC."

  validation {
    condition     = length(var.VPC_ID) == 0 || substr(var.VPC_ID, 0, 4) == "vpc-"
    error_message = "The VPC_ID must start with \"vpc-\"."
  }
}

variable "SUBNET_ID" {
  type        = string
  default     = ""
  description = "The target subnet to be used by Packer. If not specified, Packer will use the subnet that has the most free IP addresses."

  validation {
    condition     = length(var.SUBNET_ID) == 0 || substr(var.SUBNET_ID, 0, 7) == "subnet-"
    error_message = "The SUBNET_ID must start with \"subnet-\"."
  }
}

variable "SECURITY_GROUP_ID" {
  type        = string
  default     = ""
  description = "(Optional) The target security group to be used by Packer. If not specified, Packer will create a temporary security group."
}

variable "AWS_INSTANCE_PROFILE" {
  type        = string
  default     = ""
  description = "Name of the IAM instance profile to attach to the Packer builder EC2 instance."
}

variable "INSTANCE_TAGS" {
  type = map(string)
  default = {
    Name  = "Packer Builder"
    Build = "MATLAB"
  }
  description = "The tags Packer adds to the machine image builder."
}

variable "AMI_TAGS" {
  type = map(string)
  default = {
    Name          = "Packer Build"
    Build         = "MATLAB"
    Type          = "matlab-on-aws"
    Base_AMI_ID   = "{{ .SourceAMI }}"
    Base_AMI_Name = "{{ .SourceAMIName }}"
  }
  description = "The tags Packer adds to the resultant machine image."
}

variable "MANIFEST_OUTPUT_FILE" {
  type        = string
  default     = "manifest.json"
  description = "The name of the resultant manifest file."
}

# Optional parameters to setup a SSH Bastion for Packer Build
variable "SSH_BASTION_HOST" {
  type        = string
  default     = ""
  description = "(Optional) A bastion host to use for the actual SSH connection."
}

variable "SSH_INTERFACE" {
  type        = string
  default     = "public_ip"
  description = "Specifies the type of network interface address used by Packer for SSH connections. Acceptable values are 'public_ip', 'private_ip', 'public_dns', or 'private_dns'."
}

variable "SSH_BASTION_USERNAME" {
  type        = string
  default     = ""
  description = "(Optional) The username to connect to the bastion host."
}

variable "SSH_BASTION_PRIVATE_KEY_FILE" {
  type        = string
  default     = ""
  description = "(Optional) Path to a PEM encoded private key file to use to authenticate with the bastion host."
}

# Set up local variables used by provisioners.
locals {
  timestamp        = regex_replace(timestamp(), "[- TZ:]", "")
  build_scripts    = [for s in var.BUILD_SCRIPTS : format("build/%s", s)]
  startup_scripts  = [for s in var.STARTUP_SCRIPTS : format("startup/%s", s)]
  runtime_scripts  = [for s in var.RUNTIME_SCRIPTS : format("runtime/%s", s)]
  use_temp_sg_rule = var.SECURITY_GROUP_ID == "" ? true : false
  # This local variable decides which URL to use.
  # If var.MSA_URL is not null (meaning the user provided an override), use that value.
  # Otherwise, construct the URL using var.RELEASE.
  effective_msa_url = var.MSA_URL != null ? var.MSA_URL : "https://raw.githubusercontent.com/mathworks-ref-arch/iac-building-blocks/refs/heads/main/common/artifacts/msa/${var.RELEASE}/Linux/msa.ini"
}

# Configure the EC2 instance that is used to build the machine image.
source "amazon-ebs" "AMI_Builder" {
  # Communicator setup
  ssh_username  = "ubuntu"
  ssh_interface = "${var.SSH_INTERFACE}"

  # Optional bastion host configuration
  ssh_bastion_host             = "${var.SSH_BASTION_HOST}"
  ssh_bastion_username         = "${var.SSH_BASTION_USERNAME}"
  ssh_bastion_private_key_file = "${var.SSH_BASTION_PRIVATE_KEY_FILE}"

  # Networking configuration
  vpc_id    = "${var.VPC_ID}"
  subnet_id = "${var.SUBNET_ID}"

  # If VPC/subnet not set, Packer will choose VPC and Subnet according to these filters
  vpc_filter {
    filters = {
      isDefault = true
    }
  }
  subnet_filter {
    most_free = true
    random    = false
  }

  # Optional: Provide ID of an existing security group
  security_group_id = "${var.SECURITY_GROUP_ID}"

  # If no security group provided, allow Packer to create a temporary security group
  # that allows SSH access from the host's public IP
  temporary_security_group_source_public_ip = "${local.use_temp_sg_rule}"

  # Packer EC2 build instance setup
  ami_name             = "CustomPacker-${var.RELEASE}-${local.timestamp}"
  region               = "us-east-1"
  iam_instance_profile = "${var.AWS_INSTANCE_PROFILE}"
  instance_type        = "g4dn.xlarge"
  aws_polling {
    delay_seconds = 30
    max_attempts  = 300
  }
  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/sda1"
    volume_size           = 128
    volume_type           = "gp2"
  }
  source_ami_filter {
    filters = {
      "virtualization-type" = "hvm"
      "name"                = "${var.BASE_AMI_NAME}"
      "root-device-type"    = "ebs"
    }
    owners      = ["099720109477"] # Canonical's owner ID https://documentation.ubuntu.com/aws/en/latest/aws-how-to/instances/find-ubuntu-images/
    most_recent = true
  }
  run_tags = "${var.INSTANCE_TAGS}"
  tags     = "${var.AMI_TAGS}"
}

# Build the machine image.
build {
  sources = ["source.amazon-ebs.AMI_Builder"]

  provisioner "shell" {
    inline = ["/usr/bin/cloud-init status --wait"]
  }

  provisioner "shell" {
    inline = ["mkdir /tmp/startup"]
  }

  provisioner "file" {
    destination = "/var/tmp/"
    source      = "build/config"
  }

  provisioner "file" {
    destination = "/tmp/startup/"
    sources     = "${local.startup_scripts}"
  }

  provisioner "file" {
    destination = "/tmp/"
    sources     = "${local.runtime_scripts}"
  }

  provisioner "shell" {
    environment_vars = [
      "RELEASE=${var.RELEASE}",
      "PRODUCTS=${var.PRODUCTS}",
      "SPKGS=${var.SPKGS}",
      "MATLAB_PROXY_VERSION=${var.MATLAB_PROXY_VERSION}",
      "DCV_INSTALLER_URL=${var.DCV_INSTALLER_URL}",
      "NVIDIA_DRIVER_VERSION=${var.NVIDIA_DRIVER_VERSION}",
      "NVIDIA_CUDA_TOOLKIT=${var.NVIDIA_CUDA_TOOLKIT}",
      "NVIDIA_CUDA_KEYRING_URL=${var.NVIDIA_CUDA_KEYRING_URL}",
      "MATLAB_SOURCE_URL=${var.MATLAB_SOURCE_URL}",
      "MSA_URL=${local.effective_msa_url}",
      "MATLAB_ROOT=/usr/local/matlab"
    ]
    expect_disconnect = true
    scripts           = "${local.build_scripts}"
  }

  post-processor "manifest" {
    output     = "${var.MANIFEST_OUTPUT_FILE}"
    strip_path = true
    custom_data = {
      release            = "MATLAB ${var.RELEASE}"
      specified_products = "${var.PRODUCTS}"
      specified_spkgs    = "${var.SPKGS}"
      build_scripts      = join(", ", "${var.BUILD_SCRIPTS}")
      base_ami_id        = "{{ .SourceAMI }}"
      base_ami_name      = "{{ .SourceAMIName }}"
    }
  }
}
