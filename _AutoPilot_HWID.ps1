New-Item -Type Directory -Path "C:\HWID"
Set-Location -Path "C:\HWID"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted
Install-Script -Name Get-WindowsAutoPilotInfo
Get-WindowsAutoPilotInfo.ps1 -OutputFile AutoPilotHWID.csv

net use z:\\172.16.1.10\temp /user:tomsmem\administrator
copy AutoPilotHWID.csv z:\AutoPilotHWID.csv
