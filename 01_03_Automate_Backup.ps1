#Thank your very much to John Seerden! @jseerden

$credential = Get-Credential
$credential.Password | ConvertFrom-SecureString | Set-Content c:\encrypted_password.txt

#Put this part of the content in to a script
$User = "tom@tomsmem.ch"

$encrypted = Get-Content c:\encrypted_password.txt | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PsCredential($User, $encrypted)

#Populate Variables
$FilePath = "C:\Backup"

#Create New Folder According to date
$BackupFolder = New-Item -ItemType Directory -Path "C:\Backup\$((Get-Date).ToString('yyyy-MM-dd'))"

#Connect to Graph API to Backup Intune
Connect-MSGraph -credential $Credential

#Start Intune Backup
Start-IntuneBackup -Path $BackupFolder

#Clean Up Old Intune Backups
Get-ChildItem -Path $FilePath | where-object {$_.LastWriteTime -lt (get-date).AddDays(-90)} |Remove-Item -Force
