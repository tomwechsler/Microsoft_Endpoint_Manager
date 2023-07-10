#To make some space below
Set-Location C:\
Clear-Host

#Istall the module. (You need admin on the machine.)
Install-Module Microsoft.Graph -AllowClobber -Verbose -Force

#Search for specific cmdlets
get-command *-mgaudit*

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

#The last login
Get-MgAuditLogSignIn -Top 1 | Format-List

#About a user
Get-MgAuditLogSignIn -Filter "UserPrincipalName eq 'name@example.com'"

$Logs = Get-MgAuditLogSignIn -Filter "startsWith(userDisplayName,'James')" -All
$Logs | Group-Object -Property AppDisplayName | Select-Object -Property Name,Count | Sort-Object -Property Count -Descending

#Filter logs based on the AppDisplayName
$Logs = $Logs | Where-Object {$PSITEM.AppDisplayName -eq "Windows Sign In"}
$Logs

$Logs = Get-MgAuditLogSignIn -Filter "startsWith(userDisplayName,'James')" -All
$Logs | Select-Object -Property AppDisplayName -Unique

#Sort sign-in logs based on the CreatedDateTime
$Logs = Get-MgAuditLogSignIn -Filter "startsWith(userDisplayName,'James')" -Top 10
$Logs | Sort-Object -Property CreatedDateTime | Select-Object -Property AppDisplayName,CreatedDateTime,UserDisplayName

#The applications used
$signin = Get-MgAuditLogSignIn -Top 1000
$signin | Group-Object AppDisplayName -NoElement

#Retrieval of the "Basic Auth" logins of the last 30 days
$startdate = (get-date).adddays(-30)
$sstartdate = $startdate.ToString("yyy-MM-dd")
$basicsignin = Get-MgAuditLogSignIn -Filter "CreatedDateTime ge $sstartdate and ClientAppUsed ne 'Browser' and ClientAppUsed ne 'Mobile Apps and Desktop clients' and ClientAppUsed ne ''"
$basicsignin | Group-Object ClientAppUsed -NoElement

#Find Permissions
Find-MgGraphCommand -Uri '/security/alerts'
Find-MgGraphCommand -Command 'Get-MgSecurityAlert' | Select-Object Permissions

##Security Alerts##

#Create a new connection
Disconnect-Graph
Connect-MgGraph -Scopes SecurityEvents.Read.All, SecurityEvents.ReadWrite.All

#Examine the Security Alerts
Get-MgSecurityAlert

#A bit 
Get-MgSecurityAlert | Select-Object Title, Description, Category, Id | Out-GridView

#More detailed info
Get-MgSecurityAlert -AlertId e208bab9f9b02156e737c42d190e60d6bd5c49a7cc51a0432169973753f8503d

#List content from an alert ID
Get-MgSecurityAlert -AlertId e208bab9f9b02156e737c42d190e60d6bd5c49a7cc51a0432169973753f8503d | Select-Object *

##Last Sign In##

#Create a new connection
Disconnect-Graph

#Connect to Microsoft Graph
Connect-MgGraph -Scopes "AuditLog.Read.All", "User.Read.All"
 
#Properties to Retrieve
$Properties = @(
    'Id','DisplayName','UserPrincipalName','UserType', 'AccountEnabled', 'SignInActivity'   
)
 
#Get All users along with the properties
$AllUsers = Get-MgUser -All -Property $Properties
 
$SigninLogs = @()
ForEach ($User in $AllUsers)
{
    $SigninLogs += [PSCustomObject][ordered]@{
            LoginName       = $User.UserPrincipalName
            DisplayName     = $User.DisplayName
            UserType        = $User.UserType
            AccountEnabled  = $User.AccountEnabled
            LastSignIn      = $User.SignInActivity.LastSignInDateTime
    }
}
 
$SigninLogs

#More details about the users
$props = @(
    # Basic metadata
    'Id','DisplayName','Mail','UserPrincipalName','Department','JobTitle'
    # Account Status
    'AccountEnabled',
    # Password last set
    'LastPasswordChangeDateTime',
    # Last logon
    'SignInActivity',
    # Assigned Licenses
    'AssignedLicenses'
)
Get-MgUser -All -Property $props | Select-Object $props

##Find out who the registered owner is##

#Install the Excel Module
Install-Module ImportExcel

#Build the prereqs array
$props = 'AccountEnabled','ApproximateLastSignInDateTime','Id','OperatingSystem','OperatingSystemVersion','TrustType'

#Get all devices
$mgDevices = Get-MgDevice -All -Property $props | Select-Object $props

foreach ($mgDevice in $mgDevices) {
    #Get the registered owner and associate to a UPN
    $owner = Get-MgDeviceRegisteredOwner -DeviceId $mgDevice.Id | ForEach-Object {Get-MgUser -UserId $_.Id}

    #Add the UPN to the device report
    $mgDevice | Add-Member -MemberType NoteProperty -Name RegisterOwnerUPN -Value $owner.UserPrincipalName
}

$mgDevices | Export-Excel Devices.xlsx -TableName Devices -AutoSize