# Define the paths to the JSON files containing policy definitions
$jsonFilePaths = @(
    "~/vf-core-cm-blob-services-availability.json",
    "~/vf-core-cm-file-services-availability.json",
    "~/vf-core-cm-storage-account-availability.json"
)

# Define the policy names corresponding to each JSON file
$policyNames = @(
    "vf-core-cm-blob-services-availability-$newResourceGroupName",
    "vf-core-cm-file-services-availability-$newResourceGroupName",
    "vf-core-cm-storage-account-availability-$newResourceGroupName"
)

# Loop through each JSON file and policy name
foreach ($index in 0..($jsonFilePaths.Length - 1)) {
    $jsonFilePath = $jsonFilePaths[$index]
    $policyName = $policyNames[$index]

    # Load the JSON content from the file
    $jsonContent = Get-Content -Path $jsonFilePath -Raw

    # Replace placeholders in the JSON content with actual values
    $jsonContent = $jsonContent `
        -replace '\$subscriptionID', $subscriptionID `
        -replace '\$AlertRG', $alertResourceGroup `
        -replace '\$VMlocation', $vmLocation `
        -replace '\$rgtoAdd', $newResourceGroupName `
        -replace '\$actionGroupName', $actionGroupName

    # Convert the JSON content to a PowerShell object
    $policyDefinition = $jsonContent 

    # Check if the policy definition already exists
    $existingPolicyDefinition = Get-AzPolicyDefinition -Name $policyName -ErrorAction SilentlyContinue
    if ($null -ne $existingPolicyDefinition) {
        Write-Output "Policy Definition $policyName already exists."
    } else {
        # Create the policy definition in Azure
        New-AzPolicyDefinition -Name $policyName -DisplayName $policyName -Policy $policyDefinition
        Start-Sleep -Seconds 15

        # Output the creation status
        Write-Output "Policy Definition $policyName created."
    }

    Start-Sleep -Seconds 15
    $existingPolicyAssignment = Get-AzPolicyAssignment -Name $policyName -Scope $newResourceGroupPath -ErrorAction SilentlyContinue

    if ($null -ne $existingPolicyAssignment) {
        Write-Output "The policy $policyName is already assigned to the resource group $newResourceGroupName."
    } else {
        # Assign the policy to the new resource group with the user-assigned identity
        $newPolicyDefinition = Get-AzPolicyDefinition -Name $policyName
        Start-Sleep -Seconds 15
        $policyAssignment = New-AzPolicyAssignment -Name $policyName -Scope $newResourceGroupPath -PolicyDefinition $newPolicyDefinition -IdentityType 'UserAssigned' -IdentityId $userAssignedIdentity.Id -Location $userAssignedIdentity.Location
        Start-AzPolicyRemediation -Name "$policyName_$currentDateTime" -PolicyAssignmentId $policyAssignment.Id -Scope $policyAssignment.Scope

        # Output the assignment status
        Write-Output "Assigned policy $policyName to resource group $newResourceGroupName."
        Write-Output "Remediation task started for policy $policyName."
    }
}