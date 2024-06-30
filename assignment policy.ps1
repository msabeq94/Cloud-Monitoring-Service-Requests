

$resourceGroupName = "VF-CloudMonitoringv3"
$scope = "/subscriptions/c3323cc6-1939-4b36-8714-86504bbb8e4b/resourceGroups/$resourceGroupName"
$UserAssignedIdentity = Get-AzUserAssignedIdentity -ResourceGroupName 'vf-core-UK-resources-rg' -Name 'vf-core-cm-managed-identity-ap'
$policys = Get-AzPolicyDefinition -Custom


foreach ($policy in $policys) {
    $assignmentName = $policy.displayname

    New-AzPolicyAssignment -Name $assignmentName -Scope $scope -PolicyDefinition $Policy -IdentityType 'UserAssigned' -IdentityId $UserAssignedIdentity.Id -Location $UserAssignedIdentity.Location
}




(Get-AzPolicyAssignment -Scope $scope).Count