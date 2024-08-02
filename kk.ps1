# Define your variables
$resourceGroupName = "vf-core-IT-resources-rg"

# Get all metric alert rules in the specified resource group
$MetricAlertV2 = Get-AzMetricAlertRuleV2 -ResourceGroupName $resourceGroupName

foreach ($ruleMatric in $MetricAlertV2) {
    # Display the alert rule being deleted
    Write-Output "Deleting alert rule: $($ruleMatric.Name)"

    # Delete the alert rule
    try {
        Remove-AzMetricAlertRuleV2 -ResourceGroupName $resourceGroupName -Name $ruleMatric.Name 
        Write-Output "Deleted alert rule: $($ruleMatric.Name)"
    } catch {
        Write-Output "Failed to delete alert rule $($ruleMatric.Name): $_"
    }
}

$ActivityLogAlert = Get-AzActivityLogAlert -ResourceGroupName $resourceGroupName

foreach ($ruleLogAlert in $ActivityLogAlert) {
    # Display the alert rule being deleted
    Write-Output "Deleting alert rule: $($ruleLogAlert.Name)"

    # Delete the alert rule
    try {
        Remove-AzActivityLogAlert -ResourceGroupName $resourceGroupName -Name $ruleLogAlert.Name 
        Write-Output "Deleted alert rule: $($ruleLogAlert.Name)"
    } catch {
        Write-Output "Failed to delete alert rule $($ruleLogAlert.Name): $_"
    }
}