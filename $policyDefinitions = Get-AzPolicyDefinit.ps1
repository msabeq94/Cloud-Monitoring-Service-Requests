$policyDefinitions = Get-AzPolicyDefinition -Custom

foreach ($policyDefinition in $policyDefinitions) {
    Remove-AzPolicyDefinition -Name $policyDefinition.Name -Force
    Write-Output "Removed policy Definition: $($policyDefinition.Name)"
}