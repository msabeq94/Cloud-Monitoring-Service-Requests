
$uri = "https://management.azure.com/subscriptions/$($subscriptionID)/resourceGroups/$($AlertRG)/providers/Microsoft.Insights/activityLogAlerts?api-version=2017-04-01"

$RMScope = "/subscriptions/$($subscriptionID)/resourceGroups/$($rgtoRM)"

$existingActivityLogAlerts = Invoke-RestMethod -Method Get -Headers $header -Uri $uri #| ConvertTo-Json -Depth 20
foreach ($ActivityLogAlerts in $existingActivityLogAlerts.value) {

    $alertId = $ActivityLogAlerts.id
    $alertName = $ActivityLogAlerts.name
    $updateUri = "https://management.azure.com$($alertId)?api-version=2017-04-01"
    $eachLogAlert = Invoke-RestMethod -Method Get -Headers $header -Uri $updateUri
    # Get detailed properties of the current Activity Log Alert
    #$ActivityLogAlerts = Invoke-RestMethod -Method Get -Headers $header -Uri $uri  | ConvertTo-Json
    $updatedScopes = $($eachLogAlert).properties.scopes | Where-Object { $_ -ne $RMScope } | Select-Object -Unique
    $existingcondition = $($eachLogAlert).properties.condition | ConvertTo-Json
    $existingcactions = $($eachLogAlert).properties.actions | ConvertTo-Json
    $existingdescription = $($eachLogAlert).properties.description | ConvertTo-Json
    $existintags = $($eachLogAlert).tags | ConvertTo-Json
    $existinname = $($eachLogAlert).name | ConvertTo-Json
    $existinid = $($eachLogAlert).id | ConvertTo-Json

    # Correctly format scopes based on their count
    if ($updatedScopes.Count -eq 1) {
        $scopesBody = @("[`"$($updatedScopes)`"]")
    } else {
        $scopesBody = $updatedScopes | ConvertTo-Json -Compress
    }

$body = @"
{
    "id": $existinid,
    "name": $existinname,
    "type": "Microsoft.Insights/ActivityLogAlerts",
    "location": "global",
    "tags": $existintags,
    "properties": {
        "scopes" : $scopesBody,
        "condition": $existingcondition,
        "actions": $existingcactions,
        "enabled": true,
        "description": $existingdescription
    }
}
"@
    $update = Invoke-RestMethod -Uri $updateUri -Method put -Headers $header -Body $body
    Start-Sleep -Milliseconds 750
    $getscop = Invoke-RestMethod -Uri $updateUri -Method Get -Headers $header
    $RMScopeout = $($getscop).properties.scopes | ConvertTo-Json
    Write-Output "$alertName new scope $RMScopeout"
}
