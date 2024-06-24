# Define your variables
$resourceGroupName = "vf-core-UK-resources-rg"

# Get all metric alert rules in the specified resource group
$alertRules = Get-AzMetricAlertRuleV2 -ResourceGroupName $resourceGroupName

foreach ($rule in $alertRules) {
    # Display the alert rule being deleted
    Write-Output "Deleting alert rule: $($rule.Name)"

    # Delete the alert rule
    try {
        Remove-AzMetricAlertRuleV2 -ResourceGroupName $resourceGroupName -Name $rule.Name 
        Write-Output "Deleted alert rule: $($rule.Name)"
    } catch {
        Write-Output "Failed to delete alert rule $($rule.Name): $_"
    }
}