
# Define the new resource group to add to the scope
$subscriptionID = Read-Host "enter the subscription ID"
$rg = Read-Host "enter the new Resoucr group name to Monitoring"
$alertRulesLocation = Read-Host "enter the Resoucr group of the alerts"
$newResourceGroup = "/subscriptions/$subscriptionID/resourceGroups/$rg"

# Get all metric alert rules in the VF-Core resource group
$alertRules = Get-AzMetricAlertRuleV2 -ResourceGroupName $alertRulesLocation

foreach ($rule in $alertRules) {
    # Retrieve the current scopes of the alert rule
    $currentScopes = $rule.Scopes

    # Add the new resource group to the existing scopes if not already present
    if ($currentScopes -notcontains $newResourceGroup) {
        #$newScopes = "[$($currentScopes),$($newResourceGroup)]"
        $newScopes = @($currentScopes + $newResourceGroup)

        # Update the alert rule with the new scopes
        Add-AzMetricAlertRuleV2 -ResourceGroupName $alertRulesLocation -Name $rule.Name -TargetResourceScope $newScopes -WindowSize $rule.WindowSize -Frequency $rule.EvaluationFrequency -Severity $rule.Severity  -Condition $rule.Criteria -TargetResourceType $rule.TargetResourceType -TargetResourceRegion $rule.TargetResourceRegion

        Write-Output "Updated alert rule $($rule.Name) with new scope $($newResourceGroup)"
    } else {
        Write-Output "Alert rule $($rule.Name) already includes scope $($newResourceGroup)"
    }
}
