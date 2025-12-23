Connect-MgGraph -Scopes Policy.ReadWrite.Authorization
$authPolicyUri = "https://graph.microsoft.com/beta/policies/authorizationPolicy/authorizationPolicy"
$body = @{
    defaultUserRolePermissions = @{
        allowedToReadBitlockerKeysForOwnedDevice = $false #Set this to $true to allow BitLocker self-service recovery
    }
}| ConvertTo-Json
Invoke-MgGraphRequest -Uri $authPolicyUri -Method PATCH -Body $body
# Show current policy setting
$authPolicy = Invoke-MgGraphRequest -Uri $authPolicyUri
$authPolicy.defaultUserRolePermissions