#Install the msal.ps module
Install-Module -Name msal.ps -AllowClobber -Verbose -Force

#I am working with an app registration, replace the values with your own (be sure that your app has the needed permissions)
#Device.Read.All
#DeviceManagementConfiguration.Read.All
#DeviceManagementConfiguration.ReadWrite.All

#Important: This script is only used to import profiles and policies in case they were accidentally deleted. A check in Intune whether the profiles or policies already exist does not (yet) exist.

$params = @{
    ClientId = '12345678-ee4e-498b-b449-5c949d5caf14'
    TenantId = '87654321-a6a2-4f99-b864-164035e9e465'
    DeviceCode = $true
}
$authHeaders = @{Authorization = (Get-MsalToken @params).CreateAuthorizationHeader()}

########################
# Variable Collections #
########################
$location = "C:\Temp"

#Compliance policies
$compliancePolicies = Get-ChildItem -Path "$($location)\Compliance*"

#Configuration policies
$ConfigurationPolicies = Get-ChildItem -Path "$($location)\Configuration*"

################################
# Import Policies and Profiles #
################################

#Compliance policies
try{
  foreach($policy in $compliancePolicies){
    $JSON = Get-Content $policy.fullName

    # If missing, adds a default required block scheduled action to the compliance policy request body, as this value is not returned when retrieving compliance policies.
    $scheduledActionsForRule = '"scheduledActionsForRule":[{"ruleName":"PasswordRequired","scheduledActionConfigurations":[{"actionType":"block","gracePeriodHours":0,"notificationTemplateId":"","notificationMessageCCList":[]}]}]'
    $JSON = $JSON.trimend("}")
    $JSON = $JSON.TrimEnd() + "," + "`r`n"
    $JSON = $JSON + $scheduledActionsForRule + "`r`n" + "}"

    $response = Invoke-RestMethod -Headers $authHeaders -Uri "https://graph.microsoft.com/v1.0/deviceManagement/deviceCompliancePolicies" -UseBasicParsing -Method POST -ContentType "application/json" -Body $JSON
    write-host "Imported policy: $(($JSON | convertfrom-json).displayname)" -ForegroundColor green
  }
}
catch{
  write-host "Error: $($_.Exception.Message)" -ForegroundColor red
}

#Configuration policies
try{
  foreach($policy in $ConfigurationPolicies){
    $JSON = Get-Content $policy.fullName
    $response = Invoke-RestMethod -Headers $authHeaders -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations" -UseBasicParsing -Method POST -ContentType "application/json" -Body $JSON
    write-host "Imported profile: $(($JSON | convertfrom-json).displayname)" -ForegroundColor green
  }
}
catch{
  write-host "Error: $($_.Exception.Message)" -ForegroundColor red
}