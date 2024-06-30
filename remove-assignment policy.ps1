
$resourceGroupName = "VF-CloudMonitoringv3"
 $scope = "/subscriptions/c3323cc6-1939-4b36-8714-86504bbb8e4b/resourceGroups/$resourceGroupName"

# Get all policy assignments for the specified resource group
$policyAssignments = Get-AzPolicyAssignment  -scope $scope

# Loop through each policy assignment and remove it
foreach ($policyAssignment in $policyAssignments) {
    Remove-AzPolicyAssignment -id $policyAssignment.id  -Force
    Write-Output "Removed policy assignment: $($policyAssignment.Name)"
}


