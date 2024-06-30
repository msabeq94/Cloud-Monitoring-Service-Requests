$subscriptionID = "c3323cc6-1939-4b36-8714-86504bbb8e4b"


$rgtoRM = "VF-CloudMonitoringv4"

$RMScope = "/subscriptions/$($subscriptionID)/resourceGroups/$($rgtoRM)"

$policyAssignments = Get-AzPolicyAssignment  -scope $RMScope 

foreach ($policyAssignment in $policyAssignments) {
    Remove-AzPolicyAssignment -id $policyAssignment.id  -Force
    Write-Output "Removed policy assignment: $($policyAssignment.Name)"
}


$policyDefinitions = get-AzPolicyDefinition | Where-Object { $_.Name -like "vf-core-cm-*-$rgtoRM"}
foreach ($policyDefinition in $policyDefinitions) {
    Remove-AzPolicyDefinition -Name $policyDefinition.name -Force
    Write-Output "Removed policy Definition: $($policyDefinition.Name)"
}