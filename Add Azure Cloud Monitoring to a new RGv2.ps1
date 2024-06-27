# Define the new resource group to add to the scope
$subscriptionID = Read-Host "Enter the subscription ID"
$rgtoAdd = Read-Host "Enter the new Resource group name to monitor"
$AlertLocation = Read-Host "Enter the Resource group of the alerts"
$actionGroupName =  Read-Host "Enter the Action Grpup name"
$actionGroupID = "/subscriptions/$subscriptionID/resourceGroups/$AlertLocation/providers/microsoft.insights/actiongroups/$actionGroupName"
$newResourceGroup = "/subscriptions/$subscriptionID/resourceGroups/$rgtoAdd"
$VMlocation = Read-Host "enter the VMs location to monitor"
$EvaluationFrequency = "PT5M"
$WindowSize = "PT15M"
# Define tags
$Tags = @{
    "DeployedBy" = "Vodafone"
    "VodafoneBuildVersion" = "vf-build-v1"
    "VodafoneProduct" = "Cloud Monitoring"
}
#===========================================================================================
# $ActivityLogAlert = Get-AzMetricAlertRuleV2 -ResourceGroupName $AlertLocation | Where-Object { $_.Name -like "vf-core-cm-vm-*-$($VMlocation)" }

# if (-not $ActivityLogAlert) {
#     # Create a new alert
#     Write-Output "No existing alert found for $VMlocation . Creating new alerts."
#     Add-AzMetricAlertRuleV2 -ResourceGroupName $AlertLocation -Name "vf-core-cm-vm-cpu-percentage-$($VMlocation)" -TargetResourceScope $newResourceGroup -WindowSize 0:15 -Frequency 0:05 -Severity 2  -TargetResourceType "microsoft.compute/virtualmachines" -TargetResourceRegion $VMlocation 
       


#===========================================================================================

# Get all metric alert rules in the specified resource group that start with "vf-core-cm-"
$MetricAlertV2 = Get-AzMetricAlertRuleV2 -ResourceGroupName $AlertLocation | Where-Object { $_.Name -like "vf-core-cm-*" }

foreach ($ruleMatric in $MetricAlertV2) {
    # Retrieve the current scopes of the alert rule
    $currentScopes = $ruleMatric.Scopes

    # Add the new resource group to the existing scopes if not already present
    if ($currentScopes -notcontains $newResourceGroup) {
        $newScopes = @($currentScopes + $newResourceGroup)

        # Update the alert rule with the new scopes
        Add-AzMetricAlertRuleV2 -ResourceGroupName $AlertLocation -Name $ruleMatric.Name -TargetResourceScope $newScopes -WindowSize $ruleMatric.WindowSize -Frequency $ruleMatric.EvaluationFrequency -Severity $ruleMatric.Severity -Condition $ruleMatric.Criteria -TargetResourceType $ruleMatric.TargetResourceType -TargetResourceRegion $ruleMatric.TargetResourceRegion

        Write-Output "Resource Group $($rgtoAdd) added to the scope of alert name $($ruleMatric.Name)"
    } else {
        Write-Output "Alert rule $($ruleMatric.Name) already includes Resource Group $($rgtoAdd)"
    }
}





