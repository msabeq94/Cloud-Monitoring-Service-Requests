$subscriptionId = "c3323cc6-1939-4b36-8714-86504bbb8e4b"
$resourceGroupToRemove = "VF-CloudMonitoring"
$resourceManagementScope = "/subscriptions/$($subscriptionId)/resourceGroups/$($resourceGroupToRemove)"

$policyAssignmentsInScope = Get-AzPolicyAssignment  -scope $resourceManagementScope 

foreach ($policyAssignment in $policyAssignmentsInScope) {
    Remove-AzPolicyAssignment -id $policyAssignment.id  -Force
    Write-Output "Removed policy assignment: $($policyAssignment.Name)"
}

$policyDefinitionsInScope = get-AzPolicyDefinition | Where-Object { $_.Name -like "vf-core-cm-*-$resourceGroupToRemove"}
foreach ($policyDefinition in $policyDefinitionsInScope) {
    Remove-AzPolicyDefinition -Name $policyDefinition.name -Force
    Write-Output "Removed policy Definition: $($policyDefinition.Name)"
}