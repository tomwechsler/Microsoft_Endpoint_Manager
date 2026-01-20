New-Item -Type Directory -Path "C:\HWID"
Set-Location -Path "C:\HWID"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted
Install-Script -Name Get-WindowsAutoPilotInfo
Get-WindowsAutoPilotInfo.ps1 -OutputFile AutoPilotHWID.csv

#Copy the file to another system
net use z: \\192.168.179.10\temp /user:tomsmem\administrator
Copy-Item AutoPilotHWID.csv z:\AutoPilotHWID.csv

#Direct upload to intune
Get-WindowsAutoPilotInfo.ps1 -online