# Copyright 2024 The MathWorks, Inc.

// Use this Packer configuration file to build AMI with R2024b MATLAB installed.
// For more information on these variables, see /packer/v1/build-matlab-ami.pkr.hcl.
// Source for NVIDIA CUDA toolkit: https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=24.04&target_type=runfile_local

RELEASE       = "R2024b"
BASE_AMI_NAME = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
STARTUP_SCRIPTS = [
  ".env",
  "10_setup-disks.sh",
  "20_setup-machine.sh",
  "30_setup-logging.sh",
  "40_setup-rdp.sh",
  "50_setup-nicedcv.sh",
  "60_setup-matlab-proxy.sh",
  "70_setup-matlab.sh",
  "80_warmup-matlab.sh",
  "85_warmup-mathworks-service-host.sh",
  "99_run-optional-user-command.sh"
]
RUNTIME_SCRIPTS = [
  "swap-desktop-solution.sh",
  "launch-matlab-proxy.sh",
  "generate-certificate.py"
]
BUILD_SCRIPTS = [
  "install-startup-scripts.sh",
  "install-swap-desktop-solution.sh",
  "install-dependencies.sh",
  "install-matlab-proxy.sh",
  "install-matlab-dependencies-ubuntu.sh",
  "install-ubuntu-desktop.sh",
  "install-mate.sh",
  "install-matlab.sh",
  "install-support-packages.sh",
  "setup-startup-accelerator.sh",
  "install-fabric-manager-ubuntu.sh",
  "generate-toolbox-cache.sh",
  "cleanup.sh"
]
PRODUCTS                = "5G_Toolbox AUTOSAR_Blockset Aerospace_Blockset Aerospace_Toolbox Antenna_Toolbox Audio_Toolbox Automated_Driving_Toolbox Bioinformatics_Toolbox Bluetooth_Toolbox C2000_Microcontroller_Blockset Communications_Toolbox Computer_Vision_Toolbox Control_System_Toolbox Curve_Fitting_Toolbox DDS_Blockset DSP_HDL_Toolbox DSP_System_Toolbox Database_Toolbox Datafeed_Toolbox Deep_Learning_HDL_Toolbox Deep_Learning_Toolbox Econometrics_Toolbox Embedded_Coder Filter_Design_HDL_Coder Financial_Instruments_Toolbox Financial_Toolbox Fixed-Point_Designer Fuzzy_Logic_Toolbox GPU_Coder Global_Optimization_Toolbox HDL_Coder HDL_Verifier Image_Acquisition_Toolbox Image_Processing_Toolbox Industrial_Communication_Toolbox Instrument_Control_Toolbox LTE_Toolbox Lidar_Toolbox MATLAB MATLAB_Coder MATLAB_Compiler MATLAB_Compiler_SDK MATLAB_Report_Generator MATLAB_Test Mapping_Toolbox Medical_Imaging_Toolbox Mixed-Signal_Blockset Model_Predictive_Control_Toolbox Motor_Control_Blockset Navigation_Toolbox Optimization_Toolbox Parallel_Computing_Toolbox Partial_Differential_Equation_Toolbox Phased_Array_System_Toolbox Powertrain_Blockset Predictive_Maintenance_Toolbox RF_Blockset RF_PCB_Toolbox RF_Toolbox ROS_Toolbox Radar_Toolbox Reinforcement_Learning_Toolbox Requirements_Toolbox Risk_Management_Toolbox Robotics_System_Toolbox Robust_Control_Toolbox Satellite_Communications_Toolbox Sensor_Fusion_and_Tracking_Toolbox SerDes_Toolbox Signal_Integrity_Toolbox Signal_Processing_Toolbox SimBiology SimEvents Simscape Simscape_Battery Simscape_Driveline Simscape_Electrical Simscape_Fluids Simscape_Multibody Simulink Simulink_3D_Animation Simulink_Check Simulink_Coder Simulink_Compiler Simulink_Control_Design Simulink_Coverage Simulink_Design_Optimization Simulink_Design_Verifier Simulink_Desktop_Real-Time Simulink_Fault_Analyzer Simulink_PLC_Coder Simulink_Real-Time Simulink_Report_Generator Simulink_Test SoC_Blockset Stateflow Statistics_and_Machine_Learning_Toolbox Symbolic_Math_Toolbox System_Composer System_Identification_Toolbox Text_Analytics_Toolbox UAV_Toolbox Vehicle_Dynamics_Blockset Vehicle_Network_Toolbox Vision_HDL_Toolbox WLAN_Toolbox Wavelet_Toolbox Wireless_HDL_Toolbox Wireless_Testbench"
SPKGS                   = "Deep_Learning_Toolbox_Model_for_AlexNet_Network Deep_Learning_Toolbox_Model_for_EfficientNet-b0_Network Deep_Learning_Toolbox_Model_for_GoogLeNet_Network Deep_Learning_Toolbox_Model_for_ResNet-101_Network Deep_Learning_Toolbox_Model_for_ResNet-18_Network Deep_Learning_Toolbox_Model_for_ResNet-50_Network Deep_Learning_Toolbox_Model_for_Inception-ResNet-v2_Network Deep_Learning_Toolbox_Model_for_Inception-v3_Network Deep_Learning_Toolbox_Model_for_DenseNet-201_Network Deep_Learning_Toolbox_Model_for_Xception_Network Deep_Learning_Toolbox_Model_for_MobileNet-v2_Network Deep_Learning_Toolbox_Model_for_Places365-GoogLeNet_Network Deep_Learning_Toolbox_Model_for_NASNet-Large_Network Deep_Learning_Toolbox_Model_for_NASNet-Mobile_Network Deep_Learning_Toolbox_Model_for_ShuffleNet_Network Deep_Learning_Toolbox_Model_for_DarkNet-19_Network Deep_Learning_Toolbox_Model_for_DarkNet-53_Network Deep_Learning_Toolbox_Model_for_VGG-16_Network Deep_Learning_Toolbox_Model_for_VGG-19_Network"
NVIDIA_CUDA_TOOLKIT     = "https://developer.download.nvidia.com/compute/cuda/12.2.2/local_installers/cuda_12.2.2_535.104.05_linux.run"
NVIDIA_DRIVER_VERSION   = "535"
NVIDIA_CUDA_KEYRING_URL = "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb"
DCV_INSTALLER_URL       = "https://d1uj6qtbmh3dt5.cloudfront.net/2023.0/Servers/nice-dcv-2023.0-15065-ubuntu2204-x86_64.tgz"
