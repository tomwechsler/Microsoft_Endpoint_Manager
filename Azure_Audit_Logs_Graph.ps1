Set-Location C:\
Clear-Host

#Istall the module. (You need admin on the machine.)
Install-Module Microsoft.Graph -AllowClobber -Verbose -Force

#Set the variable with the tenant ID
$TenantID = "your Tenant ID"

#Connect to the graph
$Tenant = Connect-MgGraph -TenantId $TenantID -Scopes "AuditLog.Read.All","Directory.Read.All"

#Get ApplicationManagemnt logs
Get-MgAuditLogDirectoryAudit -Filter "category eq 'ApplicationManagement'"

#Get all device logs
Get-MgAuditLogDirectoryAudit -Filter "category eq 'Device'"

#Get all device logs in the past 30 days. Date must be properly formatted
[dateTime]$Past30Days = (get-date).addDays(-30)
$Past30DaysFormatted = Get-Date $Past30Days -Format yyyy-MM-dd
Get-MgAuditLogDirectoryAudit -Filter "category eq 'Device' and activityDateTime gt $Past30DaysFormatted"

#All actions initiated by Intune
Get-MgAuditLogDirectoryAudit -Filter "initiatedBy/app/displayName eq 'Microsoft Intune'" | Select-Object activitydisplayname,@{Name = 'Devicename'; Expression = {$_.targetresources.displayname}},result,resultreason

#Get failed actions
Get-MgAuditLogDirectoryAudit -Filter "result eq 'Failure'" | 
Select-Object activitydisplayname,@{Name = 'Devicename'; Expression = {$_.targetresources.displayname}},result,resultreason

#Get failed device creation
Get-MgAuditLogDirectoryAudit -Filter "activitydisplayname eq 'Add device' and result eq 'Failure'"

#Why did the device creation fail?
Get-MgAuditLogDirectoryAudit -Filter "activitydisplayname eq 'Add device' and result eq 'Failure'" | 
Select-Object activitydisplayname,@{Name = 'Devicename'; Expression = {$_.targetresources.displayname}},result,resultreason