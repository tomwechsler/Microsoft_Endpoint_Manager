Set-Location c:\
Clear-Host

#Customize the ExecutionPolicy (absolutely OK for this demo)
Set-ExecutionPolicy -ExecutionPolicy Unrestricted

#Install the Module
Install-Module -Name Microsoft.Graph.Intune -Verbose -Force -AllowClobber

#Install the Module
Install-Module -Name MSGraphFunctions -Verbose -Force -AllowClobber

#Import the Module
Import-Module -Name MSGraphFunctions

#Install the Module
Install-Module -Name AzureAD -Verbose -Force -AllowClobber

#Install IntuneBackupAndRestore from the PowerShell Gallery
Install-Module -Name IntuneBackupAndRestore -Verbose -Force -AllowClobber

#Update the Module
Update-Module -Name IntuneBackupAndRestore -Verbose

#Import the Module
Import-Module IntuneBackupAndRestore

#Connect to Microsoft Graph
Connect-MSGraph

#Create a folder
New-Item -ItemType Directory -Path C:\Backup\IntuneBackup

#Switch to the folder
Set-Location C:\Backup\IntuneBackup

#Create the Full-Backup
Start-IntuneBackup -Path 'C:\Backup\IntuneBackup'

#Let's look at the content
Get-ChildItem -Path 'C:\Backup\IntuneBackup'