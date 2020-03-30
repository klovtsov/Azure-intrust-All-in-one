# Create a Quest InTrust lab

## Description

This template deploys the Quest InTrust lab with following configuration: 

* a new AD domain controller. 
* a SQL Server 
* an InTrust Server. 
* a client machine.

Each VM has its own public IP address and is added to a subnet protected with a Network Security Group, which only allows RDP port from Internet. 

Each VM has a private network IP which is for InTrust communication. 


azuredeploy.json - template dfinition
example_azuredeploy.paramters.json - file with parameters,they also can be specified in Azure portal if deploying template from there
DSC\CommonUtilities.ps1 - InTrust AT scripts
DSC\DCConfiguration.zip - archive of all scripts for deployment by DSC
DSC\gpo.zip - GPO backup for policies, non applicable without domain, [ToDo]without domain auditpol should be used
DSC\Installation.psm1 - InTrust AT scripts
DSC\InstallationUtilies.ps1
DSC\INTRConfiguration.ps1 - DSC configuration for the server (INTR prefix because in other template with more than 1 VM, it is beeing done via copying parameters)
DSC\NotifyThroughEventLog.exe - batch enable event logging for alert rules
DSC\SetInstallationParameters.psm1 - InTrust AT scripts
DSC\Utility.psm1 - InTrust AT scripts

SQLServerDSC - module for SQL server DSC configuration (used only for SRS, because base image for the VM already contains SQL)
TemplateHelpDSC - set of helper scripts including main classes for installation and downloading for InTrust deployment
xCredSSP - CredSPP configuration for Invoke-Command from Local System to template admin user
