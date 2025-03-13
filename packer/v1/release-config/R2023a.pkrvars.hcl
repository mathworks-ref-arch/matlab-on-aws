# Copyright 2023-2024 The MathWorks, Inc.

// Use this Packer configuration file to build AMI with R2023a MATLAB installed.
// For more information on these variables, see /packer/v1/build-matlab-ami.pkr.hcl.
RELEASE       = "R2023a"
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
PRODUCTS                = "5G_Toolbox Antenna_Toolbox Aerospace_Blockset Mixed-Signal_Blockset Phased_Array_System_Toolbox AUTOSAR_Blockset Aerospace_Toolbox Audio_Toolbox Bioinformatics_Toolbox Bluetooth_Toolbox Simscape_Battery C2000_Microcontroller_Blockset Curve_Fitting_Toolbox Communications_Toolbox MATLAB_Compiler Control_System_Toolbox Simulink_Coverage Database_Toolbox DDS_Blockset Datafeed_Toolbox Deep_Learning_HDL_Toolbox Parallel_Computing_Toolbox Automated_Driving_Toolbox DSP_System_Toolbox Simulink_Design_Verifier Medical_Imaging_Toolbox Embedded_Coder HDL_Verifier Econometrics_Toolbox Filter_Design_HDL_Coder Financial_Toolbox Fuzzy_Logic_Toolbox GPU_Coder Global_Optimization_Toolbox HDL_Coder DSP_HDL_Toolbox SoC_Blockset Image_Acquisition_Toolbox Instrument_Control_Toolbox System_Identification_Toolbox Image_Processing_Toolbox Financial_Instruments_Toolbox Simscape_Driveline Wireless_HDL_Toolbox Lidar_Toolbox LTE_Toolbox MATLAB_Coder Mapping_Toolbox MATLAB_Compiler_SDK MATLAB Model_Predictive_Control_Toolbox MATLAB_Report_Generator Simscape_Multibody Motor_Control_Blockset MATLAB_Web_App_Server Deep_Learning_Toolbox Navigation_Toolbox Optimization_Toolbox Industrial_Communication_Toolbox Partial_Differential_Equation_Toolbox Simulink_PLC_Coder Predictive_Maintenance_Toolbox Fixed-Point_Designer MATLAB_Production_Server Simscape_Electrical Powertrain_Blockset Radar_Toolbox RF_Blockset Robust_Control_Toolbox RF_Toolbox Risk_Management_Toolbox Reinforcement_Learning_Toolbox Robotics_System_Toolbox RF_PCB_Toolbox Requirements_Toolbox ROS_Toolbox Simulink_Coder SimBiology Simulink_Control_Design SimEvents Stateflow Signal_Processing_Toolbox Simscape_Fluids Satellite_Communications_Toolbox Simulink_Compiler Simulink Symbolic_Math_Toolbox Simulink_Design_Optimization Signal_Integrity_Toolbox Simulink_Report_Generator Simscape Statistics_and_Machine_Learning_Toolbox SerDes_Toolbox Simulink_Test Text_Analytics_Toolbox MATLAB_Test Sensor_Fusion_and_Tracking_Toolbox UAV_Toolbox Vehicle_Dynamics_Blockset Vehicle_Network_Toolbox Computer_Vision_Toolbox Simulink_3D_Animation Vision_HDL_Toolbox Simulink_Check Wavelet_Toolbox Wireless_Testbench WLAN_Toolbox Simulink_Real-Time System_Composer"
SPKGS                   = "Deep_Learning_Toolbox_Model_for_AlexNet_Network Deep_Learning_Toolbox_Model_for_EfficientNet-b0_Network Deep_Learning_Toolbox_Model_for_GoogLeNet_Network Deep_Learning_Toolbox_Model_for_ResNet-101_Network Deep_Learning_Toolbox_Model_for_ResNet-18_Network Deep_Learning_Toolbox_Model_for_ResNet-50_Network Deep_Learning_Toolbox_Model_for_Inception-ResNet-v2_Network Deep_Learning_Toolbox_Model_for_Inception-v3_Network Deep_Learning_Toolbox_Model_for_DenseNet-201_Network Deep_Learning_Toolbox_Model_for_Xception_Network Deep_Learning_Toolbox_Model_for_MobileNet-v2_Network Deep_Learning_Toolbox_Model_for_Places365-GoogLeNet_Network Deep_Learning_Toolbox_Model_for_NASNet-Large_Network Deep_Learning_Toolbox_Model_for_NASNet-Mobile_Network Deep_Learning_Toolbox_Model_for_ShuffleNet_Network Deep_Learning_Toolbox_Model_for_DarkNet-19_Network Deep_Learning_Toolbox_Model_for_DarkNet-53_Network Deep_Learning_Toolbox_Model_for_VGG-16_Network Deep_Learning_Toolbox_Model_for_VGG-19_Network"
NVIDIA_CUDA_TOOLKIT     = "https://developer.download.nvidia.com/compute/cuda/12.2.2/local_installers/cuda_12.2.2_535.104.05_linux.run"
NVIDIA_DRIVER_VERSION   = "535"
NVIDIA_CUDA_KEYRING_URL = "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb"
DCV_INSTALLER_URL       = "https://d1uj6qtbmh3dt5.cloudfront.net/2023.0/Servers/nice-dcv-2023.0-15065-ubuntu2204-x86_64.tgz"
