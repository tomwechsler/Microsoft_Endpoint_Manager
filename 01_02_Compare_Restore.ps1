#Thank your very much to John Seerden! @jseerden
 
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
New-Item -ItemType Directory -Path C:\Backup\IntuneBackup1

#Switch to the folder
Set-Location C:\Backup\IntuneBackup1

#We have created a first backup. Now let us make a change to a profile in the MEM portal.
#After that we create another backup

#Create the Full-Backup
Start-IntuneBackup -Path 'C:\Backup\IntuneBackup1'

#We need the path to the .json file
$Ref = "C:\Backup\IntuneBackup\Device Configurations\Microsoft Defender AntiiVirus.json"
$Diff = "C:\Backup\IntuneBackup1\Device Configurations\Microsoft Defender AntiiVirus.json"

#Compare two Backup Files for changes
Compare-IntuneBackupFile -ReferenceFilePath $Ref -DifferenceFilePath $Diff

#Compare all files in two Backup Directories for changes
Compare-IntuneBackupDirectories -ReferenceDirectory 'C:\Backup\IntuneBackup' -DifferenceDirectory 'C:\Backup\IntuneBackup1'

#Restore Intune configuration
Start-IntuneRestoreConfig -Path 'C:\Backup\IntuneBackup1'

#If you wish to restore the assignments for Intune configurations
Start-IntuneRestoreAssignments -Path 'C:\Backup\IntuneBackup1'

#IMPORTANT: Restoring configurations will not overwrite existing configurations, but creates new ones. 
#Restoring assignments may overwrite existing assignments.

#You can also restore individual policies (The policy must not exist in the MEM portal). 
#But beware, first create a copy (new folder) of your fullbackup. 
#Navigate the new folder and remove everything you don't want to restore.
Invoke-IntuneRestoreDeviceCompliancePolicy -Path 'C:\Backup\IntuneBackup2'
Invoke-IntuneRestoreDeviceCompliancePolicyAssignment -Path 'C:\Backup\IntuneBackup2'

#Or so
Invoke-IntuneRestoreDeviceConfiguration -Path 'C:\Backup\IntuneBackup3'
Invoke-IntuneRestoreDeviceConfigurationAssignment -Path 'C:\Backup\IntuneBackup3'
