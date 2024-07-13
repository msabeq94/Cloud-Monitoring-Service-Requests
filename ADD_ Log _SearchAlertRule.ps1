# Prompt user to enter necessary information
$subscriptionID = Read-Host "Enter the Subscription ID"
$alertResourceGroup = Read-Host "Enter the Resource Group name for the alerts"
$newResourceGroupName = Read-Host "Enter the new Resource Group name to monitor"
$actionGroupName = Read-Host "Enter the Action Group name"
$vmLocation = Read-Host "Enter the location of the VMs to monitor"
$managedIdentityName  = Read-Host "Enter the Managed Identity name"

$currentDateTime = Get-Date -Format "yyyyMMddHHmmss"

# Get the user-assigned identity details
$userAssignedIdentity = Get-AzUserAssignedIdentity -ResourceGroupName $alertResourceGroup -Name $managedIdentityName

# Define the new resource group path
$newResourceGroupPath = "/subscriptions/$subscriptionID/resourceGroups/$newResourceGroupName"

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

    # Create the policy definition in Azure
    New-AzPolicyDefinition -Name $policyName -DisplayName $policyName -Policy $policyDefinition
    Start-Sleep -Milliseconds 750

    # Retrieve the created policy definition
    $policyDefinition = Get-AzPolicyDefinition -Name $policyName
    Write-Output "policy Definition $policyName created"
    # Assign the policy to the new resource group with the user-assigned identity
    $policyAssignment = New-AzPolicyAssignment -Name $policyName -Scope $newResourceGroupPath -PolicyDefinition $policyDefinition -IdentityType 'UserAssigned' -IdentityId $userAssignedIdentity.Id -Location $userAssignedIdentity.Location

    Start-AzPolicyRemediation  -Name "$policyName _$currentDateTime" -PolicyAssignmentId $policyAssignment.Id -ResourceGroupName $newResourceGroupName

    # Output the assignment status
    Write-Output "Assigned policy $policyName to resource group $newResourceGroupName."
    Write-Output "Remediation started for policy $policyName."
}