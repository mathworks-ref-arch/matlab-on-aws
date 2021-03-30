# MATLAB on Amazon Web Services (Linux VM)

## Requirements
Before starting, you will need the following:
-   A MATLAB® license that is current on Software
    Maintenance Service (SMS). For more information, see [Configure MATLAB Licensing on the Cloud](https://www.mathworks.com/help/licensingoncloud/matlab-on-the-cloud.html).
-   An Amazon Web Services™ (AWS) account.
-   An SSH Key Pair for your AWS account in the appropriate region. For more information, see [Amazon EC2 Key Pairs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html).

## Costs
You are responsible for the cost of the AWS services used when you create cloud resources using this guide. Resource settings, such as instance type, will affect the cost of deployment. For cost estimates, see the pricing pages for each AWS service you will be using. Prices are subject to change.

## Introduction

The following guide will help you automate the process of running the MATLAB desktop on Amazon Web Services using a Linux virtual machine and connect to it using the Remote Desktop Protocol (RDP). The automation is accomplished using an AWS CloudFormation template. The template is a JSON file that defines the resources needed to run MATLAB on AWS. For information about the architecture of this solution, see [Architecture and Resources](#architecture-and-resources). For information about templates, see [AWS CloudFormation Templates](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-guide.html).


## Prepare your AWS Account

1. If you don't have an AWS account, create one at https://aws.amazon.com by following the on-screen instructions.
2. Use the regions selector in the navigation bar to choose the **US East (N. Virginia)** or **EU (Ireland)** region where you want to deploy MATLAB.
3. Create a [key pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) in that region.  The key pair is necessary as it is the only way to connect to the instance as an administrator.
4. If necessary, [request a service limit increase](https://console.aws.amazon.com/support/home#/case/create?issueType=service-limit-increase&limitType=service-code-) for the Amazon EC2 instance type or VPCs.  You might need to do this if you already have existing deployments that use that instance type or you think you might exceed the [default limit](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-resource-limits.html) with this deployment.

# Deployment Steps

The MATLAB Reference Architecture is released in lockstep with the bi-annual MATLAB releases.
Each reference architecture release has its own instructions as we continue to evolve it.
Select a release to continue:

| Linux | Windows |
| ------- | ------- |
| [R2021a](releases/R2021a/README.md) |[R2021a](https://github.com/mathworks-ref-arch/matlab-on-aws-win/tree/master/releases/R2021a) |
| [R2020b](releases/R2020b/README.md) |[R2020b](https://github.com/mathworks-ref-arch/matlab-on-aws-win/tree/master/releases/R2020b) |
| [R2020a](releases/R2020a/README.md) |
| [R2019b](releases/R2019b/README.md) |
| [R2019a\_and\_older](releases/R2019a_and_older/README.md) |


## Architecture and Resources

![MATLAB on AWS Reference Architecture](img/aws-matlab-diagram.png)

Deploying this reference architecture sets up a single AWS EC2 instance containing Linux and MATLAB, a private VPC with an internet gateway, a private subnet and a security group that opens the appropriate ports for SSH and RDP access.

To make deployment easy, we have prepared an Amazon Machine Image (AMI) running Ubuntu 16.04 with pre-installed drivers. The AMI contains the following software:
* MATLAB, Simulink, Toolboxes, and support for GPUs.
* Add-Ons: Deep Learning Toolbox(TM) Model for AlexNet Network, Deep Learning Toolbox Model for GoogLeNet Network, and Deep Learning Toolbox Model for ResNet-50 Network

### Resources

The following resources will be created as part of the CloudFormation Stack:

1. VPC w/Internet Gateway
1. Subnet
1. Security Group for SSH and RDP access
1. EC2 Instance

## FAQ

### How do I save my changes in the VM?
All your files and changes are stored locally on the virtual machine.  They will persist until you either terminate the virtual machine instance or delete the stack.  Stopping the instance does not destroy the data on the instance.  If you want your changes to persist  outside the stack or before you terminate an instance, you’ll need to:
* Copy your files to another location (*Example*: S3 or Mount an Amazon EBS volume and create a snapshot), or
* Create an image of the virtual machine.

### What happens to my data if I shut down the instance?
You may want to shut down the instance when you aren’t using it to save some money (you only pay for the storage used by the virtual machine when it is stopped).  To shut down an EC2 instance, locate it in the AWS web console, select the instance and choose “Instance State/Stop” from the “Actions” menu.  You can restart it from the same menu.  Any files or changes made to the virtual machine will persist when shutting down and will be there when you restart.  A side-effect of shutting down the virtual machine and restarting is that the public IP address and DNS name may change.  Inspecting the EC2 instance in the AWS console will reveal the new IP address and DNS name.

### How do I keep the same public IP address?
To avoid having to change the IP address between restarts, you can establish a static IP using AWS Elastic IP Address. For more information, see https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html.

### How do I save a VM image?
To save a VM image, locate the EC2 Instance in the AWS web console and select **Actions** > **Image** > **Create Image.**

### How do I copy the VM image to a different region?
You can copy the AMI for a certain MATLAB version to a target region of your choice.

* In the Releases folder of this repository, choose the MATLAB release that you want to copy. Download and open the CloudFormation template .json file for that release.
* Locate the Mappings section in the CloudFormation template. Copy the AMI ID for one of the existing regions, for example, us-east-1.
* To copy the AMI to your target region, [follow the instructions at Copying an AMI on the AWS documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/CopyingAMIs.html).
* In the Mappings section of the CloudFormation template, add a new RegionMap pair corresponding to your target region. Insert the new AMI ID of the AMI in the target region.
* In your AWS Console, change your region to your target region. In the CloudFormation menu, select Create Stack > With new resources option. Provide the modified CloudFormation template.

You can now deploy the AMI in your target region using the AMI that you copied.

### How do I customize the VM image?
You can customize a VM image by launching the reference architecture, applying any changes you want to the EC2 Instance (such as installing additional software, drivers, and files), and then saving an image of that instance using the AWS Console. For more information, see [How Do I save a VM image?](#how-do-i-save-a-vm-image). When you create a stack, replace the AMI ID in the CloudFormation template with the AMI ID of your customized image.

### How do I use a different license manager?
The VM image uses MathWorks Hosted License Manager by default. For information on how to use other license managers, see [Configure MATLAB Licensing on the Cloud](http://www.mathworks.com/support/cloud/configure-matlab-licensing-on-the-cloud.html).

# Technical Support
If you require assistance or have a request for additional features or capabilities, please contact [MathWorks Technical Support](https://www.mathworks.com/support/contact_us.html).