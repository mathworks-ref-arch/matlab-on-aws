# MATLAB on Amazon Web Services

This repository shows how to deploy MATLAB&reg; on an Amazon EC2&reg; instance using your Amazon&reg; Web Services (AWS&reg;) account and connect to it using the Remote Desktop Protocol (RDP), SSH, or NICE DCV. The automation uses an AWS CloudFormation template. 

For information about the architecture of this solution, see [Learn about Architecture](#learn-about-architecture). For information about templates, see [AWS CloudFormation Templates](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-guide.html).

This reference architecture has been reviewed and qualified by AWS.

![AWS Qualified Software badge](img/aws-qualified-software.png)


## Requirements
You need:
* A MATLAB license. For more information, see [License Requirements for MATLAB on Cloud Platforms](https://www.mathworks.com/help/install/license/licensing-for-mathworks-products-running-on-the-cloud.html).
* An [Amazon Web Services (AWS)](https://aws.amazon.com) account.
* A key pair for your AWS account, in the appropriate region. For more information, see [Amazon EC2 Key Pairs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html).

## Costs
You are responsible for the cost of the AWS services used when you create cloud resources using this guide. Resource settings, such as instance type, affect the cost of deployment. For cost estimates, see the pricing pages for each AWS service you will be using. Prices are subject to change.

# Deployment Steps
By default, the MATLAB reference architectures below launch prebuilt machine images, described in [Learn about Architecture](#learn-about-architecture).
Using a prebuilt machine image is the easiest way to deploy a MATLAB reference architecture.
Prebuilt images are provided for the five most recent MATLAB releases.
Alternatively, to build your own machine image,
see [Build and Deploy Your Own Machine Image](#build-and-deploy-your-own-machine-image).
You can also use this workflow to install an earlier MATLAB release.

## Deploy Prebuilt Machine Image
To view instructions for deploying the MATLAB reference architecture, select a MATLAB release:

| Linux | Windows | Status |
| ----- | ------- | ------- |
| [R2025b](releases/R2025b/README.md) |  | ✅ Prebuilt available. |
| [R2025a](releases/R2025a/README.md) |  | ✅ Prebuilt available. |
| [R2024b](releases/R2024b/README.md) |  | ✅ Prebuilt available. |
| [R2024a](releases/R2024a/README.md) |  | ⚠️ Prebuilt will be removed in September 2026. |
| [R2023b](releases/R2023b/README.md) |  | ⚠️ Prebuilt will be removed in March 2026. |
| [Earlier/Custom](./packer/v1) |  | For earlier MATLAB releases, you must build your own machine image. |

The above instructions allow you to launch instances based on the latest prebuilt MathWorks&reg; Amazon Machine Images (AMIs).
MathWorks periodically replaces older AMIs with new images.
For more details, see
[When are the MathWorks Amazon Machine Images updated?](#when-are-the-mathWorks-amazon-machine-images-updated)

## Build and Deploy Your Own Machine Image
For details of the scripts which form the basis of the MathWorks Linux AMI build process,
see [Build Your Own Machine Image](./packer/v1).
You can use these scripts to build a custom Linux machine image for running MATLAB on Amazon Web Services.
You can then deploy this custom image with the MathWorks infrastructure as code (IaC) templates.

You can customize the MATLAB release which is installed as part of this custom build.
This includes MATLAB releases supported by the prebuilt images, as well as earlier MATLAB releases.
For more details,
see [Customize MATLAB Release to Install](./packer/v1#customize-matlab-release-to-install).

Platform engineering teams can use these scripts to take advantage of optimizations MathWorks has developed
for running MathWorks products in the cloud.
For more details, see [What are the advantages of building images with MathWorks scripts?](#what-are-the-advantages-of-building-images-with-mathworks-scripts)

## Learn about Architecture

![MATLAB on AWS Reference Architecture](img/aws-matlab-diagram.png)

Deploying this reference architecture sets up a single AWS EC2 instance containing MATLAB, a private VPC with an internet gateway, a private subnet, and a security group that opens the appropriate ports for SSH and RDP access.

The Amazon Machine Image (AMI) contains pre-installed drivers and the following software:
* MATLAB, Simulink, toolboxes, and support for GPUs.
* Add-ons: several pretrained deep neural networks for classification, feature extraction, and transfer learning with Deep Learning Toolbox&trade;, including GoogLeNet, ResNet-50, and NASNet-Large.

### Resources

The following resources will be created as part of the CloudFormation Stack:

1. Security Group for SSH and RDP access
2. EC2 Instance

The following resources might be created, depending on your deployment configuration:

1. IAM role
2. A CloudWatch log group
3. An elastic IP address
4. A SSM document

## FAQ

### What permissions are required by end users to deploy MATLAB in an AWS account?

You do not need administrative-level access in AWS to deploy this reference architecture. If users already have the necessary permissions, no further action is required. If you are unsure whether you have sufficient permissions to deploy MATLAB on AWS, check with your AWS administrator and share the [permission document](./permission.md) with them. Using this document, administrators can assign the required permissions following the principle of least privilege. This document is kept current with the latest MATLAB release.

AWS administrators can assign the necessary permissions to end users in two ways:

* **Full Stack Creation Workflow**: MATLAB Users can create the entire stack. This approach is recommended for streamlined setups.

* **Pass Role Workflow**: MATLAB Users can only create non-IAM resources in their stack. AWS admins must create necessary IAM roles that the user must pass to the stack. This approach is suitable for tighter control over IAM policies.

For both options, the permission document provides a CloudFormation template to generate the necessary IAM roles and permissions. This template also supports granting additional permissions to EC2 instances depending on specific users' needs.

### When are the MathWorks Amazon Machine Images updated?
The links in [Deployment Steps](#deployment-steps) launch instances based on the latest MathWorks
AMIs for at least the four most recent MATLAB releases. MATLAB releases occur twice each year.

For each MATLAB release, MathWorks periodically replaces the corresponding AMI with a newer AMI
that includes the latest MATLAB updates and important security updates of the base OS image.

When MathWorks replaces an AMI, the older AMI is deleted.
However, any running instances previously launched from the older AMI are not affected.
To continue using an older AMI, copy the AMI into your AWS account.
For more details on how to copy an AMI, see
[How do I copy the AMI?](#how-do-I-copy-the-ami)
For more details on how to customize the reference architectures to
deploy the copied AMI see [How do I customize the AMI?](#how-do-I-customize-the-ami)

### How do I save my changes in the AMI?
All your files and changes are stored locally on the EC2 Instance. They persist until you either terminate the instance or delete the stack. Stopping the instance does not destroy the data on the instance. If you want your changes to persist outside the stack or before you terminate an instance, you need to:
* Copy your files to another location, or
* Create an image of the virtual machine.

### What happens to my data if I shut down the instance?
To minimize costs, you might want to shut down the instance when you are not using it. When the virtual machine is stopped, you are only charged for storage. To shut down an EC2 instance, locate it in the AWS web console, select the instance and choose “Instance State/Stop” from the “Actions” menu. You can restart it from the same menu. Any files or changes you make to the virtual machine will persist when you shut it down and will be present when you restart it. Shutting down the virtual machine and restarting it might change the public IP address and DNS name. Inspecting the EC2 instance in the AWS console will reveal the new IP address and DNS name.

### How do I keep the same public IP address?
To avoid having to change the IP address between restarts, enable the **Keep public IP address the same** option during deployment. For more information, see [Elastic IP addresses](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html).

### How do I manage my EC2 quotas?
See [Amazon EC2 Service Quotas](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-resource-limits.html).

### How do I save or copy an AMI?
To save an AMI, locate the EC2 Instance in the AWS web console and select **Actions** > **Image** > **Create Image.**

To copy the AMI for a certain MATLAB version to a target region of your choice, follow these steps:
* Choose the MATLAB release that you want to copy from the Releases folder of this repository. Download and open the CloudFormation template .json file for that release.
* Locate the Mappings section in the CloudFormation template. Copy the AMI ID for one of the existing regions, for example, us-east-1.
* To copy the AMI to your target region, see [Copy an AMI](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/CopyingAMIs.html) in the AWS documentation.
* In the Mappings section of the CloudFormation template, add a new RegionMap pair corresponding to your target region. Insert the new AMI ID of the AMI in the target region.
* In your AWS Console, change your region to your target region. In the CloudFormation menu, select the **Create Stack > With new resources** option. Provide the modified CloudFormation template.

You can now deploy the AMI in your target region using the AMI that you copied.

### How do I customize the AMI?
You can customize a prebuilt AMI by launching the reference architecture, applying changes you want to the EC2 Instance (such as installing additional software, drivers, and files), then saving an image of that instance using the AWS Console. For more information, see [How do I save or copy an AMI?](#how-do-i-save-or-copy-an-ami). When you create a stack, replace the AMI ID in the CloudFormation template with the AMI ID of your customized image.

You can also create a custom image by building your own using the Packer scripts we provide. See [Build and Deploy Your Own Machine Image](#build-and-deploy-your-own-machine-image).

### How do I use a different license manager?
The AMI uses MathWorks Hosted License Manager by default. For information on how to use other license managers, see [MATLAB Licensing in the Cloud](https://www.mathworks.com/help/install/license/licensing-for-mathworks-products-running-on-the-cloud.html).

### What are the advantages of building images with MathWorks scripts?
Images built with MathWorks scripts are optimized and tested for MathWorks workflows.
The images are deployed by MathWorks CloudFormation templates following AWS best practices.

The warmup scripts found in [startup](./packer/v1/startup) allow you to start MATLAB faster. The CloudFormation template uses these scripts to automatically initialize MathWorks files on the instance. This allows MATLAB to be responsive in as little as a minute after you start it. These scripts are automatically included in both the prebuilt images and the images that you build using the instructions in [Deployment Steps](#deployment-steps).

Without the optimization scripts, starting a large software application, such as MATLAB, for the first time can potentially take tens of minutes. Subsequent starts of the large software application will be faster. This is because AWS initializes the storage for the EC2 instance, as described in [Initialize Amazon EBS volumes](https://docs.aws.amazon.com/ebs/latest/userguide/ebs-initialize.html).



Other scripts in this repo also enable options for connecting to the instance, ensure that all the necessary MATLAB dependencies are installed, and make it easy to build an image with an older MATLAB release.

# Technical Support
To request assistance or additional features, contact [MathWorks Technical Support](https://www.mathworks.com/support/contact_us.html).

----

Copyright 2018-2025 The MathWorks, Inc.

----