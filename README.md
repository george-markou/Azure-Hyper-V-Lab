# Azure Hyper-V Lab

Hey everyone 👋

Introducing an Azure IaaS VM Deployment Template for Windows Server 2022 with Hyper-V Role enabled. This template simplifies the process, allowing you to harness the power of Hyper-V for experimentation, learning, proof of concept development, non-production environments, or even as a staging environment for creating custom images destined for Azure's public cloud.

Here's what's included in the template:

+ A Virtual Network (VNet) with one Subnet
+ A Static Public IP with Standard SKU
+ A Network Security Group (NSG) configured to enable Remote Desktop Connections
+ A Virtual Machine with Nested Virtualization capabilities - visit Markou.me for more information
+ Two Premium SSD Disks: one for the Operating System (127GB) and one for Storing Virtual Machines (512GB)

🌐 Server Roles:

+ Hyper-V
+ DHCP Server
+ RSAT Tools
+ Containers

📦 Additional Software Pre-Installed:

+ Azure Az PowerShell module
+ Azure CLI
+ Azure Storage Explorer
+ AzCopy Utility
+ PowerShell Core
+ Windows Admin Center
+ 7-Zip
+ Chocolatey Package Manager

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fgeorge-markou%2FAzure-Hyper-V-Lab%2Fmain%2Fmain.json)

## Get Started

1. Press the button below to deploy the Template using the Azure Portal.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgeorge-markou%2FAzure-Hyper-V-Lab%2Fmain%2Fmain.json)

2. Fill in the required information.

![](./images/template.png)

3. Enjoy a cup of coffee :coffee: while waiting for the deployment to finish(Approx 15m).

![](./images/deployment.png)

4. Connect to the newly deployed VM using Remote Desktop.

![](./images/connection.png)

5. Start managing Hyper-V using either Hyper-V Manager or Windows Admin Center.

![](./images/shortcuts.png)

## General Notes

+ There is a large list of VM sizes specified as allowed values within the Template. Just to make your life easier and avoid deployment errors :superhero:.
+ The virtual machine is utilizing Azure Spot Instances instead of regular instances, and an eviction policy has been set to 'deallocate'.
+ To evaluate Microsoft Software and Operating Systems, use the Desktop Shortcut of the Microsoft Evaluation Center.
+ In order to use Azure Marketplace Images to deploy Virtual Machines, visit my [blog](https://www.markou.me/2022/03/use-azure-marketplace-images-to-deploy-virtual-machines-on-azure-stack-hci/).
+ The default path for storing Virtual Machine configuration files is "F:\VMS" and for disks is "F:\VMS\Disks".
+ Enhanced Session Mode is set to Enabled.
+ A DHCP Scope is present, providing Network Addressing to Virtual Machines.
+ An Internal Hyper-V Switch that is Nat enabled is present.
+ The Data Disk (Volume F) is formatted with ReFS and unit size 64KB.
+ You will find both JSON and Bicep Templates within this repo.
+ The DSC Configuration File is listed here [here](dsc/DSCInstallWindowsFeatures.ps1).
+ The Host Configuration File is listed here [here](/HostConfig.ps1).

## Learn more about Hyper-V

+ Windows Server Hyper-V and Virtualization Learning Path on [Microsoft Learn](https://docs.microsoft.com/en-us/learn/paths/windows-server-hyper-v-virtualization/)
+ Markou.me Hyper-V [Blog](https://www.markou.me/category/hyper-v/)
+ Virtualization [Blog](https://techcommunity.microsoft.com/t5/virtualization/bg-p/Virtualization)
+ MSLab [GitHub Project](https://github.com/microsoft/MSLab)
