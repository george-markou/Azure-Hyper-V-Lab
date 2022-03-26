# Azure-Hyper-V-Lab

Hey everyone 👋

This Template will automate the deployment of an IaaS Azure VM running Windows Server 2022, having Hyper-V Role enabled. By this, you will be able to experiment freely using Hyper-V Server, learn, build Proof-Of-Concept environments or even use it as staging environment for creating shipping Custom Images to Azure.

The Template consists of the following resources:

+ A Virtual Network(VNet) with 1 Subnet
+ A Standard SKU Static Public IP
+ A Network Security Group (NSG)
+ A Virtual Machine that is capable of Nested Virtualization - <a href="https://www.markou.me/2020/05/which-azure-vm-sizes-support-nested-virtualization/" target="_blank">Markou.me</a>
+ Two Premium SSD Disks - One for Operating System(128GB) and One for Storing Virtual Machines(512GB)

Server Roles:

+ Hyper-V
+ DHCP Server
+ RSAT Tools

Additional Software Included with the VM:

+ Azure PowerShell (Az)
+ Azure Cli
+ Azure Storage Explorer
+ AzCopy Utility
+ PowerShell Core
+ Windows Admin Center
+ 7-Zip

Press the button below to deploy the Template using the Azure Portal:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgeorge-markou%2FAzure-Hyper-V-Lab%2Fmain%2Fmain.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fgeorge-markou%2FAzure-Hyper-V-Lab%2Fmain%2Fmain.json)


