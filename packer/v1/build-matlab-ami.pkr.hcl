# Copyright 2023 The MathWorks Inc.

# The following variables may have different value across releases and 
# it is recommended to modify them via the release-specific configuration file.
# To learn the release-specific values, visit the configuration file
# under /packer/v1/release-config/ folder.
variable "PRODUCTS" {
  type        = string
  default     = "5G_Toolbox Antenna_Toolbox Aerospace_Blockset Mixed-Signal_Blockset Phased_Array_System_Toolbox AUTOSAR_Blockset Aerospace_Toolbox Audio_Toolbox Bioinformatics_Toolbox Bluetooth_Toolbox Simscape_Battery C2000_Microcontroller_Blockset Curve_Fitting_Toolbox Communications_Toolbox MATLAB_Compiler Control_System_Toolbox Simulink_Coverage Database_Toolbox DDS_Blockset Datafeed_Toolbox Deep_Learning_HDL_Toolbox Parallel_Computing_Toolbox Automated_Driving_Toolbox DSP_System_Toolbox Simulink_Design_Verifier MATLAB_Parallel_Server Medical_Imaging_Toolbox Embedded_Coder HDL_Verifier Econometrics_Toolbox Filter_Design_HDL_Coder Financial_Toolbox Fuzzy_Logic_Toolbox GPU_Coder Global_Optimization_Toolbox HDL_Coder DSP_HDL_Toolbox SoC_Blockset Image_Acquisition_Toolbox Instrument_Control_Toolbox System_Identification_Toolbox Image_Processing_Toolbox Financial_Instruments_Toolbox Simscape_Driveline Wireless_HDL_Toolbox Lidar_Toolbox LTE_Toolbox MATLAB_Coder Mapping_Toolbox MATLAB_Compiler_SDK MATLAB Model_Predictive_Control_Toolbox MATLAB_Report_Generator Simscape_Multibody Motor_Control_Blockset MATLAB_Web_App_Server Deep_Learning_Toolbox Navigation_Toolbox Optimization_Toolbox Industrial_Communication_Toolbox Partial_Differential_Equation_Toolbox Simulink_PLC_Coder Predictive_Maintenance_Toolbox Fixed-Point_Designer MATLAB_Production_Server Simscape_Electrical Powertrain_Blockset Radar_Toolbox RF_Blockset Robust_Control_Toolbox RF_Toolbox Risk_Management_Toolbox Reinforcement_Learning_Toolbox Robotics_System_Toolbox RF_PCB_Toolbox Requirements_Toolbox ROS_Toolbox Simulink_Coder SimBiology Simulink_Control_Design SimEvents Stateflow Signal_Processing_Toolbox Simscape_Fluids Satellite_Communications_Toolbox Simulink_Compiler Simulink Symbolic_Math_Toolbox Simulink_Design_Optimization Signal_Integrity_Toolbox Simulink_Report_Generator Simscape Statistics_and_Machine_Learning_Toolbox SerDes_Toolbox Simulink_Test Text_Analytics_Toolbox MATLAB_Test Sensor_Fusion_and_Tracking_Toolbox UAV_Toolbox Vehicle_Dynamics_Blockset Vehicle_Network_Toolbox Computer_Vision_Toolbox Simulink_3D_Animation Vision_HDL_Toolbox Simulink_Check Wavelet_Toolbox Wireless_Testbench WLAN_Toolbox Simulink_Real-Time System_Composer"
  description = "Target products to install in the machine image, e.g. MATLAB SIMULINK."

}

variable "RELEASE" {
  type        = string
  default     = "R2023a"
  description = "Target MATLAB release to install in the machine image, must start with \"R\"."

  validation {
    condition     = can(regex("^R20[0-9][0-9](a|b)(U[0-9])?$", var.RELEASE))
    error_message = "The RELEASE value must be a valid MATLAB release, starting with \"R\"."
  }
}

variable "BASE_AMI" {
  type        = string
  default     = "ami-0778521d914d23bc1"
  description = "Default AMI ID refers to the Ubuntu Server 20.04 image provided by Canonical."

  validation {
    condition     = substr(var.BASE_AMI, 0, 4) == "ami-"
    error_message = "The BASE_AMI must start with \"ami-\"."
  }
}

variable "BUILD_SCRIPTS" {
  type        = list(string)
  default     = ["install-startup-scripts.sh", "install-swap-desktop-solution.sh", "install-dependencies.sh", "install-ubuntu-desktop.sh", "install-mate.sh", "install-matlab.sh", "install-glibc-ubuntu2004.sh", "setup-startup-accelerator.sh", "install-fabric-manager-ubuntu2004.sh", "generate-toolbox-cache.sh", "cleanup.sh"]
  description = "The list of installation scripts Packer will use when building the image."
}

variable "STARTUP_SCRIPTS" {
  type        = list(string)
  default     = [".env", "10_setup-disks.sh", "20_setup-machine.sh", "30_setup-logging.sh", "40_setup-rdp.sh", "50_setup-nicedcv.sh", "60_setup-matlab.sh", "70_warmup-matlab.sh", "99_run-optional-user-command.sh"]
  description = "The list of startup scripts Packer will copy to the remote machine image builder, which can be used during the CloudFormation Stack creation."
}

variable "RUNTIME_SCRIPTS" {
  type        = list(string)
  default     = ["swap-desktop-solution.sh"]
  description = "The list of runtime scripts Packer will copy to the remote machine image builder, which can be used after the CloudFormation Stack creation."
}

variable "DCV_INSTALLER_URL" {
  type        = string
  default     = "https://d1uj6qtbmh3dt5.cloudfront.net/2022.2/Servers/nice-dcv-2022.2-13907-ubuntu2004-x86_64.tgz"
  description = "The URL to install NICE DCV, a remote display protocol to use."
}

variable "NVIDIA_DRIVER_VERSION" {
  type        = string
  default     = "515"
  description = "The version of target NVIDIA Driver to install."
}

variable "NVIDIA_CUDA_TOOLKIT" {
  type        = string
  default     = "https://developer.download.nvidia.com/compute/cuda/11.7.1/local_installers/cuda_11.7.1_515.65.01_linux.run"
  description = "The URL to install NVIDIA CUDA Toolkit into the target machine image. "
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

variable "TEMPORARY_SECURITY_GROUP_SOURCE_CIDRS" {
  type = list(string)
  default = ["144.212.0.0/16","172.30.0.0/15","172.31.0.0/16","121.244.0.0/16","195.99.0.0/16"]
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
    Name  = "Packer Build"
    Build = "MATLAB"
    Type  = "matlab-on-aws"
  }
  description = "The tags Packer adds to the resultant machine image."
}

variable "MANIFEST_OUTPUT_FILE" {
  type        = string
  default     = "manifest.json"
  description = "The name of the resultant manifest file."
}

# Set up local variables used by provisioners.
locals {
  timestamp       = regex_replace(timestamp(), "[- TZ:]", "")
  build_scripts   = [for s in var.BUILD_SCRIPTS : format("build/%s", s)]
  startup_scripts = [for s in var.STARTUP_SCRIPTS : format("startup/%s", s)]
  runtime_scripts = [for s in var.RUNTIME_SCRIPTS : format("runtime/%s", s)]
}

# Configure the EC2 instance that is used to build the machine image.
source "amazon-ebs" "AMI_Builder" {
  ami_name = "CustomPacker-${var.RELEASE}-${local.timestamp}"
  aws_polling {
    delay_seconds = 30
    max_attempts  = 300
  }
  instance_type = "g4dn.xlarge"
  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/sda1"
    volume_size           = 128
    volume_type           = "gp2"
  }
  region       = "us-east-1"
  source_ami   = "${var.BASE_AMI}"
  ssh_username = "ubuntu"
  run_tags     = "${var.INSTANCE_TAGS}"
  tags         = "${var.AMI_TAGS}"
  temporary_security_group_source_cidrs = "${var.TEMPORARY_SECURITY_GROUP_SOURCE_CIDRS}"
  subnet_filter {
    most_free = true
    random    = false
  }
  subnet_id = "${var.SUBNET_ID}"
  vpc_filter {
    filters = {
      isDefault = "true"
    }
  }
  vpc_id = "${var.VPC_ID}"
}

# Build the machine image.
build {
  sources = ["source.amazon-ebs.AMI_Builder"]

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
      "DCV_INSTALLER_URL=${var.DCV_INSTALLER_URL}",
      "NVIDIA_DRIVER_VERSION=${var.NVIDIA_DRIVER_VERSION}",
      "NVIDIA_CUDA_TOOLKIT=${var.NVIDIA_CUDA_TOOLKIT}",
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
      build_scripts      = join(", ", "${var.BUILD_SCRIPTS}")
    }
  }
}
