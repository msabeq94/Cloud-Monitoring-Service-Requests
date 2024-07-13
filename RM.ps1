
# Get all Activity Log Alerts in the subscription
$activityLogAlerts = Get-AzActivityLogAlert

# Iterate over each Activity Log Alert and remove it
foreach ($activityLogAlert in $activityLogAlerts) {
    Remove-AzActivityLogAlert -Name $activityLogAlert.Name -ResourceGroupName $activityLogAlert.ResourceGroupName
}


# Get all resource groups in the subscription
$resourceGroups = Get-AzResourceGroup

# Iterate over each resource group
foreach ($resourceGroup in $resourceGroups) {
    # Get all Log Search Alerts in the resource group
    $logSearchAlerts = Get-AzScheduledQueryRule -ResourceGroupName $resourceGroup.ResourceGroupName

    # Iterate over each Log Search Alert and remove it
    foreach ($logSearchAlert in $logSearchAlerts) {
        Remove-AzScheduledQueryRule -Name $logSearchAlert.Name -ResourceGroupName $resourceGroup.ResourceGroupName
    }
}
$resourceGroups = Get-AzResourceGroup

# Iterate over each resource group
foreach ($resourceGroup in $resourceGroups) {
    # Get all Metric Alert rules in the resource group
    $metricAlerts = Get-AzMetricAlertRuleV2 -ResourceGroupName $resourceGroup.ResourceGroupName

    # Iterate over each Metric Alert rule and remove it
    foreach ($metricAlert in $metricAlerts) {
        Remove-AzMetricAlertRuleV2 -Name $metricAlert.Name -ResourceGroupName $resourceGroup.ResourceGroupName
    }
}

# Get all policy assignments for the specified resource group
$policyAssignments = Get-AzPolicyAssignment  -scope $newResourceGroupPath

# Loop through each policy assignment and remove it
foreach ($policyAssignment in $policyAssignments) {
    Remove-AzPolicyAssignment -id $policyAssignment.id  -Force
    Write-Output "Removed policy assignment: $($policyAssignment.Name)"
}


$policyDefinitions = get-AzPolicyDefinition | Where-Object { $_.Name -like "vf-core-cm-*-$resourceGroupName"}
foreach ($policyDefinition in $policyDefinitions) {
    Remove-AzPolicyDefinition -Name $policyDefinition.name -Force
    Write-Output "Removed policy Definition: $($policyAssignment.Name)"
}

