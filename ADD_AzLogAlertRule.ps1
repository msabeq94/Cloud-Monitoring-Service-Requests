$accessToken = (Get-AzAccessToken -ResourceUrl "https://management.azure.com").Token

$header = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

# Define common variables
$subscriptionID = Read-Host "Enter the subscription ID"
$AlertRG = Read-Host "Enter the Resource group of the alerts"
$rgtoAdd = Read-Host "Enter the new Resource group name to monitor"
#$actionGroupName = Read-Host "Enter the Action Grpup name"



#$ActionGroupId = (get-azactiongroup -ResourceGroupName $AlertRG  -name $actionGroupName).id

$uri = "https://management.azure.com/subscriptions/$($subscriptionID)/resourceGroups/$($AlertRG)/providers/Microsoft.Insights/activityLogAlerts?api-version=2017-04-01"

$newScope = "/subscriptions/$($subscriptionID)/resourceGroups/$($rgtoAdd)"

$existingActivityLogAlerts = Invoke-RestMethod -Method Get -Headers $header -Uri $uri #| ConvertTo-Json -Depth 20
foreach ($ActivityLogAlerts in $existingActivityLogAlerts.value) {

    $alertId = $ActivityLogAlerts.id
    $alertName = $ActivityLogAlerts.name
    $updateUri = "https://management.azure.com$($alertId)?api-version=2017-04-01"
    $eachLogAlert = Invoke-RestMethod -Method Get -Headers $header -Uri $updateUri
    # Get detailed properties of the current Activity Log Alert
    #$ActivityLogAlerts = Invoke-RestMethod -Method Get -Headers $header -Uri $uri  | ConvertTo-Json
    $updatedScopes = $eachLogAlert.properties.scopes + $newScope  | ConvertTo-Json
    $existingcondition= $($eachLogAlert).properties.condition | ConvertTo-Json
    $existingcactions= $($eachLogAlert).properties.actions | ConvertTo-Json
    $existingdescription = $($eachLogAlert).properties.description | ConvertTo-Json
    $existintags = $($eachLogAlert).tags | ConvertTo-Json
    $existinname = $($eachLogAlert).name | ConvertTo-Json
    $existinid =$($eachLogAlert).id| ConvertTo-Json

$body = @"
{
    "id": $existinid,
    "name": $existinname,
    "type": "Microsoft.Insights/ActivityLogAlerts",
    "location": "global",
    "tags": $existintags,
    "properties": {
        "scopes": $updatedScopes,
        "condition": $existingcondition,
        "actions": $existingcactions,
        "enabled": true,
        "description": $existingDescription
    }
}
"@
$update = Invoke-RestMethod -Uri $updateUri -Method  put -Headers $header -Body $body
$newScopeout = $($update).properties.scopes | ConvertTo-Json
Write-Output "$alertName new scope $newScopeout"
}