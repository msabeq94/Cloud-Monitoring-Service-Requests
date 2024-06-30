$accessToken = (Get-AzAccessToken -ResourceUrl "https://management.azure.com").Token

$header = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

# Define common variables
$subscriptionID = Read-Host "Enter the subscription ID"
$alertResourceGroup = Read-Host "Enter the Resource group of the alerts"
$newResourceGroupName = Read-Host "Enter the new Resource group name to monitor"
#$actionGroupName = Read-Host "Enter the Action Grpup name"





$URI_AzLogAlertRule = "https://management.azure.com/subscriptions/$($subscriptionID)/resourceGroups/$($alertResourceGroup)/providers/Microsoft.Insights/activityLogAlerts?api-version=2017-04-01"

$newResourceGroupPath = "/subscriptions/$($subscriptionID)/resourceGroups/$($newResourceGroupName)"

$existingActivityLogAlerts = Invoke-RestMethod -Method Get -Headers $header -Uri $URI_AzLogAlertRule 
foreach ($ActivityLogAlerts in $existingActivityLogAlerts.value) {

    $AlertIdAzLogAlertRule = $ActivityLogAlerts.id
    $AlertNameAzLogAlertRule = $ActivityLogAlerts.name
    $updateUriAzLogAlertRule = "https://management.azure.com$($AlertIdAzLogAlertRule)?api-version=2017-04-01"
    $AzLogAlertRuleeachLogAlert = Invoke-RestMethod -Method Get -Headers $header -Uri $updateUriAzLogAlertRule
       $updatedScopesAzLogAlertRule = $AzLogAlertRuleeachLogAlert.properties.scopes + $newResourceGroupPath  | ConvertTo-Json
    $AzLogAlertRuleexistingcondition= $($AzLogAlertRuleeachLogAlert).properties.condition | ConvertTo-Json
    $AzLogAlertRuleexistingcactions= $($AzLogAlertRuleeachLogAlert).properties.actions | ConvertTo-Json
    $AzLogAlertRuleexistingdescription = $($AzLogAlertRuleeachLogAlert).properties.description | ConvertTo-Json
    $AzLogAlertRuleexistintags = $($AzLogAlertRuleeachLogAlert).tags | ConvertTo-Json
    $AzLogAlertRuleexistinname = $($AzLogAlertRuleeachLogAlert).name | ConvertTo-Json
    $AzLogAlertRuleexistinid =$($AzLogAlertRuleeachLogAlert).id| ConvertTo-Json

$BodyAzLogAlertRule = @"
{
    "id": $AzLogAlertRuleexistinid,
    "name": $AzLogAlertRuleexistinname,
    "type": "Microsoft.Insights/ActivityLogAlerts",
    "location": "global",
    "tags": $AzLogAlertRuleexistintags,
    "properties": {
        "scopes": $updatedScopesAzLogAlertRule,
        "condition": $AzLogAlertRuleexistingcondition,
        "actions": $AzLogAlertRuleexistingcactions,
        "enabled": true,
        "description": $AzLogAlertRuleexistingDescription
    }
}
"@
$update = Invoke-RestMethod -Uri $updateUriAzLogAlertRule -Method  put -Headers $header -Body $BodyAzLogAlertRule
$newResourceGroupPathout = $($update).properties.scopes | ConvertTo-Json
Write-Output "$AlertNameAzLogAlertRule new scope $newResourceGroupPathout"
}