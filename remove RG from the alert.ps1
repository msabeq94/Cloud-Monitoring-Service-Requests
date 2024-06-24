# Define the resource group to remove from the scope
$subscriptionID = Read-Host "Enter the subscription ID"
$rgToRemove = Read-Host "Enter the Resource group name to remove from alerts"
$alertRulesLocation = Read-Host "Enter the Resource group of the alerts"
$resourceGroupToRemove = "/subscriptions/$subscriptionID/resourceGroups/$rgToRemove"

# Get all metric alert rules in the specified alert rules resource group
$alertRules = Get-AzMetricAlertRuleV2 -ResourceGroupName $alertRulesLocation

foreach ($rule in $alertRules) {
    # Retrieve the current scopes of the alert rule
    $currentScopes = $rule.Scopes

    # Check if the resource group to remove is present in the alert rule's scopes
    if ($currentScopes -contains $resourceGroupToRemove) {
        # Remove the resource group from the scopes
        $newScopes = $currentScopes | Where-Object { $_ -ne $resourceGroupToRemove }

        # Update the alert rule with the new scopes
        Add-AzMetricAlertRuleV2 -ResourceGroupName $alertRulesLocation -Name $rule.Name -TargetResourceScope $newScopes -WindowSize $rule.WindowSize -Frequency $rule.EvaluationFrequency -Severity $rule.Severity  -Condition $rule.Criteria -TargetResourceType $rule.TargetResourceType -TargetResourceRegion $rule.TargetResourceRegion

        Write-Output "Resource Group $($rgToRemove) removed from the scope of alert name $($rule.Name)"
    } else {
        Write-Output "Alert rule $($rule.Name) does not include Resource Group $($rgToRemove) "
    }
}
