configuration Configuration
{
   param
   (
        [Parameter(Mandatory)]
        [String]$DomainName,
        [Parameter(Mandatory)]
        [String]$DCName,
        [Parameter(Mandatory)]
        [String]$INTRName,
        [Parameter(Mandatory)]
        [String]$ClientName,
        [Parameter(Mandatory)]
        [String]$PSName,
		[Parameter(Mandatory)]
		[String]$IntrUrl,
		[Parameter(Mandatory)]
		[String]$IntrUpdateUrl,
        [Parameter(Mandatory)]
		[String]$IntrLicUrl,
		[Parameter(Mandatory)]
		[String]$GPOURL,
		[Parameter(Mandatory)]
		[String]$ITSSURL,
		[Parameter(Mandatory)]
        [String]$ITSSUpdateURL,
        [Parameter(Mandatory)]
        [String]$DNSIPAddress,
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds
    )

    Import-DscResource -ModuleName TemplateHelpDSC
	Import-DscResource -ModuleName xCredSSP
	#Import-DscResource -ModuleName IntrHelpers
	
    $LogFolder = "TempLog"
	$CM = "IntrFull"
    $LogPath = "c:\$LogFolder"
    $DName = $DomainName.Split(".")[0]
    $DCComputerAccount = "$DName\$DCName$"
    $PSComputerAccount = "$DName\$PSName$"

    [System.Management.Automation.PSCredential]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)", $Admincreds.Password)
    $PrimarySiteName = $PSName.split(".")[0] + "$"
    $INTRComputerAccount = "$DName\$INTRName$"
	$admname = $Admincreds.UserName
	$admpwd=$Admincreds.GetNetworkCredential().password

    Node localhost
    {
        LocalConfigurationManager
        {
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }

        SetCustomPagingFile PagingSettings
        {
            Drive       = 'C:'
            InitialSize = '8192'
            MaximumSize = '8192'
        }

        DownloadSCCM DownLoadSCCM
        {
            CM = $CM
            ExtPath = $LogPath
			IntrUrl= $IntrUrl
			IntrUpdateUrl= $IntrUpdateUrl
			IntrLicUrl= $IntrLicUrl
            Ensure = "Present"
            DependsOn = "[SetCustomPagingFile]PagingSettings"
        }

        SetDNS DnsServerAddress
        {
            DNSIPAddress = $DNSIPAddress
            Ensure = "Present"
            DependsOn = "[DownloadSCCM]DownLoadSCCM"
        }

        InstallFeatureForSCCM InstallFeature
        {
            Name = "INTR"
            Role = "Distribution Point","Management Point","DC"
            DependsOn = "[SetCustomPagingFile]PagingSettings"
        }
		
		xCredSSP Server
        {
            Ensure = "Present"
            Role = "Server"
            SuppressReboot = $true
			DependsOn = "[InstallFeatureForSCCM]InstallFeature"
        }
        xCredSSP Client
        {
            Ensure = "Present"
            Role = "Client"
            DelegateComputers = "*"
			DependsOn = "[xCredSSP]Server"
        }
		
		InstallInTrust InstallInTrustTask
        {
            CM = $CM
            Adminpass = $admpwd
			DomainName = $DomainName
            Credential = $DomainCreds
			PSName = $PSName
			ScriptPath = $PSScriptRoot
            Ensure = "Present"
            DependsOn = "[xCredSSP]Client"
        }

        DownloadAndRunSysmon DwnldSysmon
        {
            CM = "CM"
            Ensure = "Present"
            DependsOn = "[InstallInTrust]InstallInTrustTask"
        }

    }
}