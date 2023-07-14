#Installation of the Microsoft Graph module
Install-Module -Name Microsoft.Graph.Intune -Verbose -AllowClobber -Force

Import-Module -Name Microsoft.Graph.Intune

#Authentication
Connect-MSGraph

#Query of the configuration profiles
$profiles = Get-IntuneDeviceConfigurationPolicy

#output of the configuration profiles
$profiles.value | Format-Table -Property DisplayName

#Disconnect
Disconnect-MSGraph