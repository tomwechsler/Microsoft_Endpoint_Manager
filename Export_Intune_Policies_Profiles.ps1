#Install the msal.ps module
Install-Module -Name msal.ps -AllowClobber -Verbose -Force

#I am working with an app registration, replace the values with your own (be sure that your app has the needed permissions)
#Device.Read.All
#DeviceManagementConfiguration.Read.All
#DeviceManagementConfiguration.ReadWrite.All

$params = @{
    ClientId = '12345678-ee4e-498b-b449-5c949d5caf14'
    TenantId = '87654321-a6a2-4f99-b864-164035e9e465'
    DeviceCode = $true
}
$authHeaders = @{Authorization = (Get-MsalToken @params).CreateAuthorizationHeader()}

##Search for the policies and profiles##

#Compliance policies
$compliancePoliciesRequest = (Invoke-RestMethod -Headers $authHeaders -Uri "https://graph.microsoft.com/v1.0/deviceManagement/deviceCompliancePolicies" -Method Get)
$compliancePolicies = $compliancePoliciesRequest.value

#Configuration policies
$configurationPoliciesRequest = (Invoke-RestMethod -Headers $authHeaders -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations" -Method Get)
$configurationPolicies = $ConfigurationPoliciesRequest.value

#Export compliance policies (be sure that the export directory exists - C:\Temp\)
$location = "C:\Temp"
try{
    foreach($policy in $compliancePolicies){
      $filePath = "$($location)\Compliance - $($policy.displayName).json"
      $policy | convertto-json -Depth 10 | out-file $filePath
      write-host "Exported policy: $($policy.displayName)" -ForegroundColor green
    }  
  }
  catch{
    write-host "Error: $($_.Exception.Message)" -ForegroundColor red
  }
  
  #Export configuration profiles
  try{
    foreach($policy in $ConfigurationPolicies){
      $filePath = "$($location)\Configuration - $($policy.displayName).json"
      $policy | convertto-json -Depth 10 | out-file $filePath
      $Clean = Get-Content $filePath | Select-String -Pattern '"id":', '"createdDateTime":', '"modifiedDateTime":', '"version":', '"supportsScopeTags":' -notmatch
      $Clean | Out-File -FilePath $filePath
      write-host "Exported profiles: $($policy.displayName)" -ForegroundColor green
    }  
  }
  catch{
    write-host "Error: $($_.Exception.Message)" -ForegroundColor red
  }

#That's it!