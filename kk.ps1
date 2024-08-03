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

# Get all resource groups
$resourceGroups = Get-AzResourceGroup

# Loop through each resource group
foreach ($rg in $resourceGroups) {
    # Check if the resource group name starts with "VF-0"
    if ($rg.ResourceGroupName -like "VF-0*") {
        # Display the resource group being deleted
        Write-Output "Deleting resource group: $($rg.ResourceGroupName)"

        # Delete the resource group
        try {
            Remove-AzResourceGroup -Name $rg.ResourceGroupName -Force -AsJob
            Write-Output "Deleted resource group: $($rg.ResourceGroupName)"
        } catch {
            Write-Output "Failed to delete resource group $($rg.ResourceGroupName): $_"
        }
    }
}
# Define your variables
$location = "West US" # replace with your actual location

# Define the names of your resource groups
$resourceGroupNames = "VF01", "VF02", "VF03"

# Loop through each resource group name
foreach ($rgName in $resourceGroupNames) {
    # Create the resource group
    try {
        New-AzResourceGroup -Name $rgName -Location $location
        Write-Output "Created resource group: $rgName"
    } catch {
        Write-Output "Failed to create resource group $rgName : $_"
    }
}





$policyDefinitions = get-AzPolicyDefinition | Where-Object { $_.Name -like "vf-cm-*-VF-0*"}
foreach ($policyDefinition in $policyDefinitions) {
    Remove-AzPolicyDefinition -Name $policyDefinition.name -Force
    Write-Output "Removed policy Definition: $($policyDefinition.Name)"
}