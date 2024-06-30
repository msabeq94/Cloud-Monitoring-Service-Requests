# Define common variables
$subscriptionID = "c3323cc6-1939-4b36-8714-86504bbb8e4b"
$AlertRG = "vf-core-UK-resources-rg"
$rgtoAdd = "VF-CloudMonitoringv3"
$actionGroupName = "newag"
$VMlocation = "ukwest"

$jsonFilePaths = @(
    "~/vf-core-cm-blob-services-availability.json",
    "~/vf-core-cm-file-services-availability.json",
    "~/vf-core-cm-storage-account-availability.json"
)

$PolicyNames = @(
    "vf-core-cm-blob-services-availability-$($rgtoAdd)",
    "vf-core-cm-file-services-availability-$($rgtoAdd)",
    "vf-core-cm-storage-account-availability-$($rgtoAdd)"
)

foreach ($index in 0..($jsonFilePaths.Length - 1)) {
    $jsonFilePath = $jsonFilePaths[$index]
    $policyName = $($PolicyNames[$index])

    # Load the JSON content
    $jsonContent = Get-Content -Path $jsonFilePath -Raw

    # Replace the variables in the JSON content
    $jsonContent = $jsonContent `
        -replace '\$subscriptionID', $subscriptionID `
        -replace '\$AlertRG', $AlertRG `
        -replace '\$VMlocation', $VMlocation `
        -replace '\$newScope', $rgtoAdd `
        -replace '\$actionGroupName', $actionGroupName

    # Convert the JSON content to a PowerShell object
    $policyDefinition = $jsonContent #| ConvertFrom-Json

    # Create the policy definition in Azure
    New-AzPolicyDefinition -Name $policyName  -DisplayName $policyName  -Policy $policyDefinition
}


Write-Host "Policy definitions created successfully."
