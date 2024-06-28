$subscriptionID = Read-Host "Enter the subscription ID"
$AlertRG = Read-Host "Enter the Resource group of the alerts"
$VMlocation = Read-Host "enter the VMs location to monitor"


#$subscriptionID = Read-Host "Enter the subscription ID"
$rgToRemove = Read-Host "Enter the Resource group name to remove from alerts"
#$alertRulesLocation = Read-Host "Enter the Resource group of the alerts"
$resourceGroupToRemove = "/subscriptions/$($subscriptionID)/resourceGroups/$($rgToRemove)"
# Debug output to verify variables
Write-Output "Subscription ID: $subscriptionID"
Write-Output "Alert Resource Group: $AlertRG"
Write-Output "Resource group name to remove: $rgToRemove"
Write-Output "VM Location: $VMlocation"
# Get all metric alert rules in the specified alert rules resource group that start with "vf-core-cm-"
$alertRules = Get-AzMetricAlertRuleV2 -ResourceGroupName $AlertRG | Where-Object { $_.Name -like "vf-core-cm-*-$VMlocation" }

foreach ($rule in $alertRules) {
    # Retrieve the current scopes of the alert rule
    $currentScopes = $rule.Scopes

    if ($currentScopes -contains $resourceGroupToRemove) {
        if ($currentScopes.Count -eq 1) {
            # Remove the entire alert rule if it only contains the resource group to be removed
            Remove-AzMetricAlertRuleV2 -ResourceGroupName $AlertRG -Name $rule.Name
            Write-Output "Alert rule $($rule.Name) removed entirely as it only contained Resource Group $($rgToRemove)"
        } else {
            # Remove the resource group from the scopes
            $newScopes = $currentScopes | Where-Object { $_ -ne $resourceGroupToRemove }

            # Update the alert rule with the new scopes
            Add-AzMetricAlertRuleV2 -ResourceGroupName $AlertRG -Name $rule.Name -Scope $newScopes -WindowSize $rule.WindowSize -EvaluationFrequency $rule.EvaluationFrequency -Severity $rule.Severity -Criteria $rule.Criteria -TargetResourceType $rule.TargetResourceType -TargetResourceRegion $rule.TargetResourceRegion

            Write-Output "Resource Group $($rgToRemove) removed from the scope of alert name $($rule.Name)"
        }
    } else {
        Write-Output "Alert rule $($rule.Name) does not include Resource Group $($rgToRemove)"
    }

 
}
