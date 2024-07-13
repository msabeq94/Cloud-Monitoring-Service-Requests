$accessToken = (Get-AzAccessToken -ResourceUrl "https://management.azure.com").Token

$header = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

$subscriptionID = Read-Host "Enter the Subscription ID"
$alertResourceGroup = Read-Host "Enter the Resource PCR Group name"
$newResourceGroupName = Read-Host "Enter the new Resource Group name to monitor"
$actionGroupName = Read-Host "Enter the Action Group name"
$vmLocation = Read-Host "Enter the location of the VMs to monitor"
$managedIdentityName  = Read-Host "Enter the Managed Identity name"
$userAssignedIdentity = Get-AzUserAssignedIdentity -ResourceGroupName $alertResourceGroup -Name $managedIdentityName
$newResourceGroupPath = "/subscriptions/$subscriptionID/resourceGroups/$newResourceGroupName"
$URI_AzLogAlertRule = "https://management.azure.com/subscriptions/$($subscriptionID)/resourceGroups/$($alertResourceGroup)/providers/Microsoft.Insights/activityLogAlerts?api-version=2017-04-01"
$URI_MetricAlert = "https://management.azure.com/subscriptions/$($subscriptionID)/resourceGroups/$($alertResourceGroup)/providers/Microsoft.Insights/metricalerts?api-version=2018-03-01"
$currentDateTime = Get-Date -Format "yyyyMMddHHmmss"
###############################################################################################
#ADD_ Log_SearchAlertRule-custom- -per policy -RG
###############################################################################################
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
    Start-AzPolicyRemediation  -Name "$policyName _$currentDateTime" -PolicyAssignmentId $policyAssignment.Id -scope $policyAssignment.Scope

    # Output the assignment status
    Write-Output "Assigned policy $policyName to resource group $newResourceGroupName."
    Write-Output "Remediation task started for policy $policyName."
}

###############################################################################################
#ADD_AzLogAlertRule 
###############################################################################################

$existingActivityLogAlerts = Invoke-RestMethod -Method Get -Headers $header -Uri $URI_AzLogAlertRule 
foreach ($ActivityLogAlerts in $existingActivityLogAlerts.value) {

    $AlertIdAzLogAlertRule = $ActivityLogAlerts.id
    $AlertNameAzLogAlertRule = $ActivityLogAlerts.name
    $updateUriAzLogAlertRule = "https://management.azure.com$($AlertIdAzLogAlertRule)?api-version=2017-04-01"
    $AzLogAlertRuleeachLogAlert = Invoke-RestMethod -Method Get -Headers $header -Uri $updateUriAzLogAlertRule
    $updatedScopesAzLogAlertRule = $AzLogAlertRuleeachLogAlert.properties.scopes + $newResourceGroupPath  | ConvertTo-Json
    $AzLogAlertRuleexistingcondition= $($AzLogAlertRuleeachLogAlert).properties.condition | ConvertTo-Json
    $AzLogAlertRuleexistingcactions= $($AzLogAlertRuleeachLogAlert).properties.actions | ConvertTo-Json
    $AzLogAlertRuleexistingdescription = $($AzLogAlertRuleeachLogAlert).properties.description | ConvertTo-Json
    $AzLogAlertRuleexistintags = $($AzLogAlertRuleeachLogAlert).tags | ConvertTo-Json
    $AzLogAlertRuleexistinname = $($AzLogAlertRuleeachLogAlert).name | ConvertTo-Json
    $AzLogAlertRuleexistinid =$($AzLogAlertRuleeachLogAlert).id| ConvertTo-Json

$BodyAzLogAlertRule = @"
{
    "id": $AzLogAlertRuleexistinid,
    "name": $AzLogAlertRuleexistinname,
    "type": "Microsoft.Insights/ActivityLogAlerts",
    "location": "global",
    "tags": $AzLogAlertRuleexistintags,
    "properties": {
        "scopes": $updatedScopesAzLogAlertRule,
        "condition": $AzLogAlertRuleexistingcondition,
        "actions": $AzLogAlertRuleexistingcactions,
        "enabled": true,
        "description": $AzLogAlertRuleexistingDescription
    }
}
"@
$update = Invoke-RestMethod -Uri $updateUriAzLogAlertRule -Method  put -Headers $header -Body $BodyAzLogAlertRule
$newResourceGroupPathout = $($update).properties.scopes | ConvertTo-Json
Write-Output "$AlertNameAzLogAlertRule new scope $newResourceGroupPathout"
}

###############################################################################################
#ADD_AzMetricAlertRule-per VM location
###############################################################################################
$AllMetricAlert = Invoke-RestMethod -Uri $URI_MetricAlert -Method get -Headers $header 
$ExistingMetricAlert = $AllMetricAlert.value | Where-Object { $_.Name -like "vf-core-cm-*-$vmLocation"}





if (-not $ExistingMetricAlert) {
    $jsonFilePathsMetricAlert = @(
        "~/vf-core-cm-vm-data-disk-iops-consumed-percentage.json",
        "~/vf-core-cm-vm-availability.json",
        "~/vf-core-cm-vm-available-memory.json",
        "~/vf-core-cm-VM-os-disk-iops-consumed-percentage.json",
        "~/vf-core-cm-vm-cpu-percentage.json"
    )
    
     $uriBaseMetricAlert = "https://management.azure.com/subscriptions/$($subscriptionID)/resourceGroups/$($alertResourceGroup)/providers/Microsoft.Insights/metricalerts"
    $apiVersion = "?api-version=2018-03-01"
    $alertNames = @(
        "vf-core-cm-vm-data-disk-iops-consumed-percentage-$($vmLocation)",
        "vf-core-cm-vm-availability-$($vmLocation)",
        "vf-core-cm-vm-available-memory-$($vmLocation)",
        "vf-core-cm-VM-os-disk-iops-consumed-percentage-$($vmLocation)",
        "vf-core-cm-vm-cpu-percentage-$($vmLocation)"
    )

    for ($i = 0; $i -lt $jsonFilePathsMetricAlert.Length; $i++) {
        $jsonFilePath = $jsonFilePathsMetricAlert[$i]
        $alertName = $alertNames[$i]

        $jsonContent = Get-Content -Path $jsonFilePath -Raw
        $modifiedJsonContent = $jsonContent `
            -replace '\$subscriptionID', $subscriptionID `
            -replace '\$alertResourceGroup', $alertResourceGroup `
            -replace '\$vmLocation', $vmLocation `
            -replace '\$newScope', $newResourceGroupPath `
            -replace '\$actionGroupName', $actionGroupName

        $uriMetric = " $uriBaseMetricAlert/$alertName$apiVersion"
        Invoke-RestMethod -Uri $uriMetric -Method Put -Headers $header -Body $modifiedJsonContent
    }
} else {
    $URI_MetricAlert 
    $MAexistingmetricalerts = Invoke-RestMethod -Uri $URI_MetricAlert -Method get -Headers $header 
    $ExistingMetricAlert = $MAexistingmetricalerts.value | Where-Object { $_.Name -like "vf-core-cm-*-$vmLocation"}
    foreach ($ExistingMetricAlertZ in $ExistingMetricAlert) {
        $MalertId = $($ExistingMetricAlertZ).id
        $MalertName = $($ExistingMetricAlertZ).name
        $OneUriMetricAlert = "https://management.azure.com$($MalertId)?api-version=2018-03-01"
        $OneMetricAlertup = Invoke-RestMethod -Method Get -Headers $header -Uri $OneUriMetricAlert
        $Mlocation = $($OneMetricAlertup).location | ConvertTo-Json
        $Mcriteria = $($OneMetricAlertup).properties.criteria | ConvertTo-Json
        $Mscopes = $($OneMetricAlertup).properties.scopes + $newResourceGroupPath | ConvertTo-Json
        $MevaluationFrequency = $($OneMetricAlertup).properties.evaluationFrequency | ConvertTo-Json
        $Mseverity = $($OneMetricAlertup).properties.severity | ConvertTo-Json
        $MwindowSize = $($OneMetricAlertup).properties.windowSize | ConvertTo-Json
        $mtargetResourceType = $($OneMetricAlertup).properties.targetResourceType | ConvertTo-Json
        $MtargetResourceRegion = $($OneMetricAlertup).properties.targetResourceRegion | ConvertTo-Json
        $Mtargetaction = @"
[
    {
        "actionGroupId": "/subscriptions/$subscriptionID/resourceGroups/$alertResourceGroup/providers/microsoft.insights/actiongroups/$actionGroupName",
        "webHookProperties": {}
    }
]
"@


        # Create the body with proper JSON formatting
        $BodyMetricAlertu = @"
{
    "location": $Mlocation,
    "properties": {
        "criteria": $Mcriteria,
        "enabled": true,
        "evaluationFrequency": $MevaluationFrequency,
        "scopes": $Mscopes,
        "severity": $Mseverity,
        "windowSize": $MwindowSize,
        "targetResourceType": $mtargetResourceType,
        "targetResourceRegion": $MtargetResourceRegion,
        "actions": $Mtargetaction
    }
}
"@

       $Matupdate = Invoke-RestMethod -Uri $OneUriMetricAlert -Method put -Headers $header -Body $BodyMetricAlertu
        $MetricsnewScopeout = $($Matupdate).properties.scopes | ConvertTo-Json
Write-Output "$MalertName new scope $MetricsnewScopeout"
    }
}
