

$resourceGroupName = "VF-CloudMonitoringv3"
$scope = "/subscriptions/c3323cc6-1939-4b36-8714-86504bbb8e4b/resourceGroups/$resourceGroupName"

# Get all policy assignments for the specified resource group
$policyAssignments = Get-AzPolicyAssignment -Scope $scope

# Loop through each policy assignment and create a remediation task
foreach ($policyAssignment in $policyAssignments) {
    $remediationName =  "v7- $policyAssignment.name"
    #$remediation = New-AzPolicyRemediation -Name $remediationName -PolicyAssignmentId $policyAssignment.Id -ResourceDiscoveryMode ReEvaluateCompliance
    Start-AzPolicyRemediation -PolicyAssignmentId $policyAssignment.Id -Name $remediationName -ResourceGroupName $resourceGroupName -ResourceDiscoveryMode "ReEvaluateCompliance"
 
   Write-Output "Created remediation task: $remediationName for policy assignment: $($policyAssignment.Name)"
   Start-Sleep  -Seconds 15
}

# # Verify the created remediation tasks
# $remediationTasks = Get-AzPolicyRemediation -ResourceGroupName $resourceGroupName

# $remediationTasks | Format-Table Name,  ProvisioningState

$remediationTasks.Count




while ($true) {
    # Get the policy remediation tasks
    $remediationTasks = Get-AzPolicyRemediation -ResourceGroupName $resourceGroupName

    # Filter tasks that start with "MOS"
    $filteredTasks = $remediationTasks | Where-Object { $_.Name -like "mos-3-*" }

    # Display the filtered tasks in a table format
    $filteredTasks | Format-Table Name, ProvisioningState

    # Wait for 30 seconds before the next iteration
    Start-Sleep -Seconds 30
    clear
}


