# KMS Activation Script
$Logfile = "C:\Windows\Temp\KMSActivation.log"
$KMSServer = "192.168.0.9"

# Delete any existing logfile if it exists
If (Test-Path $Logfile) { Remove-Item $Logfile -Force -ErrorAction SilentlyContinue -Confirm:$false }

Function Write-Log{
	param (
	[Parameter(Mandatory = $true)]
	[string]$Message
	)

 $TimeGenerated = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
 $Line = "$TimeGenerated : $Message"
 Add-Content -Value $Line -Path $Logfile -Encoding Ascii
}

Write-Log "About to activate against the following KMS Server: $KMSServer"
$skms = & cscript.exe '//NoLogo' 'C:\Windows\System32\slmgr.vbs' '/skms' $KMSServer 2>&1
Write-Log "skms command output: $skms"
$ato = & cscript.exe '//NoLogo' 'C:\Windows\System32\slmgr.vbs' '/ato' 2>&1
Write-Log "ato command output: $ato"