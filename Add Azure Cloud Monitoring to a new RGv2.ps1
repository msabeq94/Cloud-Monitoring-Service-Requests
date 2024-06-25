# Define the new resource group to add to the scope
$subscriptionID = Read-Host "Enter the subscription ID"
$rgtoAdd = Read-Host "Enter the new Resource group name to monitor"
$alertRulesLocation = Read-Host "Enter the Resource group of the alerts"
$newResourceGroup = "/subscriptions/$subscriptionID/resourceGroups/$rgtoAdd"

# Get all metric alert rules in the specified resource group that start with "vf-core-cm-"
$alertRules = Get-AzMetricAlertRuleV2 -ResourceGroupName $alertRulesLocation | Where-Object { $_.Name -like "vf-core-cm-*" }

foreach ($rule in $alertRules) {
    # Retrieve the current scopes of the alert rule
    $currentScopes = $rule.Scopes

    # Add the new resource group to the existing scopes if not already present
    if ($currentScopes -notcontains $newResourceGroup) {
        $newScopes = @($currentScopes + $newResourceGroup)

        # Update the alert rule with the new scopes
        Add-AzMetricAlertRuleV2 -ResourceGroupName $alertRulesLocation -Name $rule.Name -TargetResourceScope $newScopes -WindowSize $rule.WindowSize -Frequency $rule.EvaluationFrequency -Severity $rule.Severity -Condition $rule.Criteria -TargetResourceType $rule.TargetResourceType -TargetResourceRegion $rule.TargetResourceRegion

        Write-Output "Resource Group $($rgtoAdd) added to the scope of alert name $($rule.Name)"
    } else {
        Write-Output "Alert rule $($rule.Name) already includes Resource Group $($rgtoAdd)"
    }
}
