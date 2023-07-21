#For this example I have created an application ID and a client secret for MS Graph (with the permissions: DeviceManagementConfiguration:ReadWirte.All)

#Delcare all the variable within this section
$graphEndpoint = "https://graph.microsoft.com"
$resourceUrl = "$graphEndpoint/beta/deviceManagement/remoteAssistanceSettings"

#Client ID, Secret and tenant id which we will paste in here
$clientId = "XXXXXXXX-7b60-XXXXX-ab45-XXXXXXXXXXXXX"
$clientSecret = "Z-b465~XXXXXXXXXXXXXXXXXXXXXXXXXXX"
$tenantId = "XXXXXXXXXX-1234-7845-XXXXX-XXXXXXXXXXX"
$authority = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
$scope = "https://graph.microsoft.com/.default"

#The payload to enable the Remote Help Assistance settings
$payload = @{
    "@odata.type" = "#microsoft.graph.remoteAssistanceSettings"
    "remoteAssistanceState" = "disabled"
    "allowSessionsToUnenrolledDevices" = $true
    "blockChat" = $false
} | ConvertTo-Json

#The entire script block

$graphEndpoint = "https://graph.microsoft.com"
$resourceUrl = "$graphEndpoint/beta/deviceManagement/remoteAssistanceSettings"
$clientId = "XXXXXXXX-7b60-XXXXX-ab45-XXXXXXXXXXXXX"
$clientSecret = "Z-b465~XXXXXXXXXXXXXXXXXXXXXXXXXXX"
$tenantId = "XXXXXXXXXX-1234-7845-XXXXX-XXXXXXXXXXX"
$authority = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
$scope = "https://graph.microsoft.com/.default"

$tokenResponse = Invoke-RestMethod -Method Post -Uri $authority `
    -Body @{
        client_id = $clientId
        client_secret = $clientSecret
        scope = $scope
        grant_type = "client_credentials"
    } `
    -Headers @{
        "Content-Type" = "application/x-www-form-urlencoded"
    }

$accessToken = $tokenResponse.access_token

$payload = @{
    "@odata.type" = "#microsoft.graph.remoteAssistanceSettings"
    "remoteAssistanceState" = "enabled"
    "allowSessionsToUnenrolledDevices" = $true
    "blockChat" = $false
} | ConvertTo-Json

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
    "Content-length" = $payload.Length
}

Invoke-RestMethod -Method Patch -Uri $resourceUrl -Headers $headers -Body $payload