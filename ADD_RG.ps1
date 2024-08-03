
$OpColist  =  @{
    "1"  =  "UK"
    "2"  =  "IT"
    "3"  =  "IE"
    "4"  =  "ES"
    "5"  =  "PT"
    }

    # Sort the options by key before displaying
$sortedOptions  =  $OpColist.GetEnumerator() | Sort-Object Name

while ($true) {
Write-Host "Please Choose the OpCo?"
foreach ($entry in $sortedOptions) {
Write-Host "$($entry.Key)) $($entry.Value)"
}

$choiceOpCO  =  Read-Host "Enter the number corresponding to your choice"
if ($OpColist.ContainsKey($choiceOpCO)) {
    $OpCo  =  $OpColist[$choiceOpCO]
    
    Write-Host "OpCO  =  $OpCo"
    $accessToken = (Get-AzAccessToken -ResourceUrl "https://management.azure.com").Token

    $header = @{
        "Authorization" = "Bearer $accessToken"
        "Content-Type" = "application/json"
    }
    
break
} else {
Write-Host "Error: Invalid choice. Please select a valid option."
}
}

 $PCRalertResourceGroup =  "vf-core-$OpCo-resources-rg"

 $PCRalertResourceGroupv2 = $PCRalertResourceGroup

$subscriptionID = Read-Host "Enter the Subscription ID"
$newResourceGroupName = Read-Host "Enter the new Resource Group name to monitor"
$newResourceGroup = Get-AzResourceGroup -Name $newResourceGroupName
$newResourceGroupId = $newResourceGroup.ResourceId
$newResourceGrouplocation = $newResourceGroup.Location


$actionGroup = Get-AzActionGroup -ResourceGroupName  $PCRalertResourceGroup -Name 'vf-core-cm-notifications'
$actionGroupId = $actionGroup.Id
$actionGroupName = $actionGroup.Name


$vmLocation = Read-Host "Enter the location of the VMs to monitor"


$userAssignedIdentity = Get-AzUserAssignedIdentity -ResourceGroupName  $PCRalertResourceGroup -Name 'vf-core-cm-managed-identity-ap'
#$newResourceGroupId = "/subscriptions/$subscriptionID/resourceGroups/$newResourceGroupName"
$URI_AzLogAlertRule = "https://management.azure.com/subscriptions/$($subscriptionID)/resourceGroups/$($PCRalertResourceGroup)/providers/Microsoft.Insights/activityLogAlerts?api-version=2017-04-01"
$URI_MetricAlert = "https://management.azure.com/subscriptions/$($subscriptionID)/resourceGroups/$($PCRalertResourceGroup)/providers/Microsoft.Insights/metricalerts?api-version=2018-03-01"
$currentDateTime = Get-Date -Format "yyyyMMddHHmmss"
###############################################################################################
#ADD_ Log_SearchAlertRule-custom- -per policy -RG
###############################################################################################
# Define the paths to the JSON files containing policy definitions
$jsonFilePathsPolicy = @(
    "vf-cm-blob-services-availability.json",
    "vf-cm-storage-account-avl.json",
    "vf-cm-file-services-avl.json",
    "vf-cm-SQL-server-cpu-per.json",
    "vf-cm-SQL-server-memory-per.json",
    "vf-cm-SQL-server-data-used-per.json",
    "vf-cm-SQL-server-failed-conn.json",
    "vf-cm-SQL-server-dtu-per.json",
    "vf-cm-SQL-server-log-IO-per-conn.json",
    "vf-cm-SQL-server-data-IO-per.json",
    "vf-cm-PSQL-flx-server-cpu-per.json",
    "vf-cm-PSQL-flx-server-memory-per.json",
    "vf-cm-PSQL-flx-server-storage-per.json",
    "vf-cm-PSQL-flx-server-act-conn-xceed.json",
    "vf-cm-PSQL-flx-server-failed-conn.json",
    "vf-cm-PSQL-flx-server-rep-lag.json",
    "vf-cm-MySQL-flx-server-host-cpu-per.json",
    "vf-cm-MySQL-flx-server-host-memory-per.json",
    "vf-cm-MySQL-flx-server-storage-per.json",
    "vf-cm-MySQL-flx-server-act-conn-xceed.json",
    "vf-cm-MySQL-flx-server-aborted-conn.json",
    "vf-cm-MySQL-flx-server-replica-lag.json",
    "vf-cm-app-gw-unhealthyhost-count-lag.json",
    "vf-cm-app-gw-failed-req-.json"
)

# Define the policy names corresponding to each JSON file
$policyNames = @(
    "vf-cm-blob-services-availability-$newResourceGroupName",
    "vf-cm-storage-account-avl-$newResourceGroupName",
    "vf-cm-file-services-avl-$newResourceGroupName",
    "vf-cm-SQL-server-cpu-per-$newResourceGroupName",
    "vf-cm-SQL-server-memory-per-$newResourceGroupName",
    "vf-cm-SQL-server-data-used-per-$newResourceGroupName",
    "vf-cm-SQL-server-failed-conn-$newResourceGroupName",
    "vf-cm-SQL-server-dtu-per-$newResourceGroupName",
    "vf-cm-SQL-server-log-IO-per-conn-$newResourceGroupName",
    "vf-cm-SQL-server-data-IO-per-$newResourceGroupName",
    "vf-cm-PSQL-flx-server-cpu-per-$newResourceGroupName",
    "vf-cm-PSQL-flx-server-memory-per-$newResourceGroupName",
    "vf-cm-PSQL-flx-server-storage-per-$newResourceGroupName",
    "vf-cm-PSQL-flx-server-act-conn-xceed-$newResourceGroupName",
    "vf-cm-PSQL-flx-server-failed-conn-$newResourceGroupName",
    "vf-cm-PSQL-flx-server-rep-lag-$newResourceGroupName",
    "vf-cm-MySQL-flx-server-host-cpu-per-$newResourceGroupName",
    "vf-cm-MySQL-flx-server-host-memory-per-$newResourceGroupName",
    "vf-cm-MySQL-flx-server-storage-per-$newResourceGroupName",
    "vf-cm-MySQL-flx-server-act-conn-xceed-$newResourceGroupName",
    "vf-cm-MySQL-flx-server-aborted-conn-$newResourceGroupName",
    "vf-cm-MySQL-flx-server-replica-lag-$newResourceGroupName",
    "vf-cm-app-gw-unhealthyhost-count-lag-$newResourceGroupName",
    "vf-cm-app-gw-failed-req-$newResourceGroupName"
)

# Loop through each JSON file and policy name
foreach ($index in 0..($jsonFilePathsPolicy.Length - 1)) {
    $jsonFilePath = $jsonFilePathsPolicy[$index]
    $policyName = $policyNames[$index]

    # Load the JSON content from the file
    $jsonContentPolicy = Get-Content -Path $jsonFilePath -Raw

    # Replace placeholders in the JSON content with actual values
    $jsonContentPolicy = $jsonContentPolicy `
        -replace '\$rgScope', $newResourceGroupId `
        -replace '\$Alocation', $newResourceGrouplocation  `
        -replace '\$customerRG', $newResourceGroupName `
        -replace '\$AactionGroupName', $actionGroupId 

    # Convert the JSON content to a PowerShell object
    $policyDefinition = $jsonContentPolicy 
    # Check if the policy definition already exists

    try {
        $existingPolicyDefinition = Get-AzPolicyDefinition -Name $policyName -ErrorAction Stop
    } catch {
        $existingPolicyDefinition = $null
    }
    if ($null -ne $existingPolicyDefinition) {
        Write-Output "Policy Definition $policyName already exists."
    } else {
    # Create the policy definition in Azure
    New-AzPolicyDefinition -Name $policyName -DisplayName $policyName -Policy $policyDefinition
    Start-Sleep -Milliseconds 5

    # Retrieve the created policy definition
    
    Write-Output "policy Definition $policyName created"
    }
    Start-Sleep -Milliseconds 5
    $existingpolicyAssignment = Get-AzPolicyAssignment -Name $policyName -Scope $newResourceGroupId -ErrorAction SilentlyContinue

    if ($null -ne $existingpolicyAssignment) {
        Write-Output "The policy $policyName is already assigned to the resource group $newResourceGroupName."
    } else {
    # Assign the policy to the new resource group with the user-assigned identity
    $NewpolicyDefinition = Get-AzPolicyDefinition -Name $policyName
    Start-Sleep -Milliseconds 5
    $policyAssignment = New-AzPolicyAssignment -Name $policyName -Scope $newResourceGroupId -PolicyDefinition $NewpolicyDefinition -IdentityType 'UserAssigned' -IdentityId $userAssignedIdentity.Id -Location $userAssignedIdentity.Location
    Start-AzPolicyRemediation  -Name "$policyName _$currentDateTime" -PolicyAssignmentId $policyAssignment.Id -scope $policyAssignment.Scope

    # Output the assignment status
    Write-Output "Assigned policy $policyName to resource group $newResourceGroupName."
    Write-Output "Remediation task started for policy $policyName."
}
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
    
    if ($AzLogAlertRuleeachLogAlert.properties.scopes -contains $newResourceGroupId) {
        Write-Output "The resource group $newResourceGroupName is already in the scope of $AlertNameAzLogAlertRule"
    } else {
    $updatedScopesAzLogAlertRule = $AzLogAlertRuleeachLogAlert.properties.scopes + $newResourceGroupId  | ConvertTo-Json
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
$newResourceGroupIdout = $($update).properties.scopes | ConvertTo-Json
Write-Output "$AlertNameAzLogAlertRule new scope $newResourceGroupIdout"
}}

###############################################################################################
#ADD_AzMetricAlertRule-per VM location
###############################################################################################
$AllMetricAlert = Invoke-RestMethod -Uri $URI_MetricAlert -Method get -Headers $header 
$ExistingMetricAlert = $AllMetricAlert.value | Where-Object { $_.Name -like "vf-core-cm-*-$vmLocation"}

if (-not $ExistingMetricAlert) {
    $jsonFilePathsMetricAlert = @(
        "vf-core-cm-vm-data-disk-iops-consumed-percentage.json",
        "vf-core-cm-vm-availability.json",
        "vf-core-cm-vm-available-memory.json",
        "vf-core-cm-VM-os-disk-iops-consumed-percentage.json",
        "vf-core-cm-vm-cpu-percentage.json"
    )
    
     $uriBaseMetricAlert = "https://management.azure.com/subscriptions/$($subscriptionID)/resourceGroups/$($PCRalertResourceGroup)/providers/Microsoft.Insights/metricalerts"
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
            -replace '\$PCRalertResourceGroup', $PCRalertResourceGroupv2 `
            -replace '\$VMlocation', $vmLocation `
            -replace '\$newResourceGroupName', $newResourceGroupName `
            -replace '\$actionGroupName', $actionGroupName 

        $uriMetric = " $uriBaseMetricAlert/$alertName$apiVersion"
        $Matupdatev1 = Invoke-RestMethod -Uri $uriMetric -Method Put -Headers $header -Body $modifiedJsonContent

        Write-Output "Created metric alert rule: $alertName"

        $MetricsnewScopeoutv1 = $($Matupdatev1).properties.scopes | ConvertTo-Json
        Write-Output "$alertName new scope $MetricsnewScopeoutv1"

    }
} else {
     
    $MAexistingmetricalerts = Invoke-RestMethod -Uri $URI_MetricAlert -Method get -Headers $header 
    $ExistingMetricAlert = $MAexistingmetricalerts.value | Where-Object { $_.Name -like "vf-core-cm-*-$vmLocation"}
    foreach ($ExistingMetricAlertZ in $ExistingMetricAlert) {
        $MalertId = $($ExistingMetricAlertZ).id
        $MalertName = $($ExistingMetricAlertZ).name
        $OneUriMetricAlert = "https://management.azure.com$($MalertId)?api-version=2018-03-01"
        $OneMetricAlertup = Invoke-RestMethod -Method Get -Headers $header -Uri $OneUriMetricAlert

        if ($OneMetricAlertup.properties.scopes -contains $newResourceGroupId) {
            Write-Output "The resource group $newResourceGroupName is already in the scope of $MalertName"
        } else {
        $Mlocation = $($OneMetricAlertup).location | ConvertTo-Json
        $Mcriteria = $($OneMetricAlertup).properties.criteria | ConvertTo-Json
        $Mscopes = $($OneMetricAlertup).properties.scopes + $newResourceGroupId | ConvertTo-Json
        $MevaluationFrequency = $($OneMetricAlertup).properties.evaluationFrequency | ConvertTo-Json
        $Mseverity = $($OneMetricAlertup).properties.severity | ConvertTo-Json
        $MwindowSize = $($OneMetricAlertup).properties.windowSize | ConvertTo-Json
        $mtargetResourceType = $($OneMetricAlertup).properties.targetResourceType | ConvertTo-Json
        $MtargetResourceRegion = $($OneMetricAlertup).properties.targetResourceRegion | ConvertTo-Json
        $Mtargetaction = @"
[
    {
        "actionGroupId": "$actionGroupId",
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
}}
