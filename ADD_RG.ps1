$WarningPreference = 'SilentlyContinue'
$OpColist  =  @{
    "1"  =  "UK"
    "2"  =  "IT"
    "3"  =  "IE"
    "4"  =  "ES"
    "5"  =  "PT"
    }

$sortedOptions  =  $OpColist.GetEnumerator() | Sort-Object Name
while ($true) {
    Write-Host "Please Choose the OpCo?"
    foreach ($entry in $sortedOptions) {
    Write-Host "$($entry.Key) $($entry.Value)"
    }
    $choiceOpCO  =  Read-Host "Enter the number corresponding to your choice"
    if ($OpColist.ContainsKey($choiceOpCO)) {
        $OpCo  =  $OpColist[$choiceOpCO]
        Write-Host "OpCO  =  $OpCo"
        $secureToken = (Get-AzAccessToken -ResourceUrl "https://management.azure.com" -AsSecureString).Token
        $accessToken = [System.Net.NetworkCredential]::new("", $secureToken).Password
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
$vmLocation = Read-Host "Enter the location of the VMs to monitor"

$newResourceGroup = Get-AzResourceGroup -Name $newResourceGroupName
$newResourceGroupId = $newResourceGroup.ResourceId
$newResourceGrouplocation = $newResourceGroup.Location

$actionGroup = Get-AzActionGroup -ResourceGroupName  $PCRalertResourceGroup -Name 'vf-core-cm-notifications'
$actionGroupId = $actionGroup.Id
$actionGroupName = $actionGroup.Name

$userAssignedIdentity = Get-AzUserAssignedIdentity -ResourceGroupName  $PCRalertResourceGroup -Name 'vf-core-cm-managed-identity-ap'
$logAnalyticsWorkspaceId = (Get-AzOperationalInsightsWorkspace -ResourceGroupName $PCRalertResourceGroupv2 -Name "vf-core-log-analyticsv2").ResourceId

$URI_AzLogAlertRule = "https://management.azure.com/subscriptions/$($subscriptionID)/resourceGroups/$($PCRalertResourceGroup)/providers/Microsoft.Insights/activityLogAlerts?api-version=2017-04-01"
$URI_MetricAlert = "https://management.azure.com/subscriptions/$($subscriptionID)/resourceGroups/$($PCRalertResourceGroup)/providers/Microsoft.Insights/metricalerts?api-version=2018-03-01"
$RGhealthURI ="https://management.azure.com/subscriptions/$($subscriptionID)/resourceGroups/$($PCRalertResourceGroup)/providers/microsoft.insights/activityLogAlerts/vf-core-cm-resource-health-alert?api-version=2017-04-01"

$currentDateTime = Get-Date -Format "yyyyMMddHHmmss"

###############################################################################################
#TAGS & diag-setg -per-RG
###############################################################################################
Write-Output "**********TAG-POLICIES**********"
start-sleep -s 3

$TS_policyParameters = @{
    "tagName" = "vf-core-cloud-monitoring"
    "tagValue" = "true"
}
$TS_PolicynameASS1 ="vf-core-cm-tag-resources-$($newResourceGroupName)"
$TS_PolicynameASS = $TS_PolicynameASS1
$TS_GETpolicyDefinition = Get-AzPolicyDefinition -Name "vf-core-cm-tag-resources"
$TS_existingpolicyAssignment = Get-AzPolicyAssignment -Name $TS_PolicynameASS -Scope $newResourceGroupId -ErrorAction SilentlyContinue
if ($null -eq $TS_existingpolicyAssignment) {
    $TS_policyAssignment = New-AzPolicyAssignment -Name $TS_PolicynameASS -PolicyDefinition $TS_GETpolicyDefinition -Scope $newResourceGroupId -Location $newResourceGrouplocation  -IdentityType 'UserAssigned' -IdentityId $userAssignedIdentity.Id  -PolicyParameterObject $TS_policyParameters
    Start-AzPolicyRemediation  -Name "$TS_PolicynameASS _$currentDateTime" -PolicyAssignmentId $TS_policyAssignment.Id -scope $TS_policyAssignment.Scope
    Write-Output "Assigned policy vf-core-cm-tag-resources to resource group $newResourceGroupName."
    Write-Output "Remediation task started for policy $TS_PolicynameASS."
} else {
    Write-Output "The policy vf-core-cm-tag-resources is already assigned to the resource group $newResourceGroupName."

}

Write-Output "**********DIAG-SETTING-POLICIES**********"
start-sleep -s 3

$DS_policyParameters = @{
    "logAnalytics" = "$logAnalyticsWorkspaceId"
}
$DS_policyDefinitions = @(
    "vf-core-cm-diag-setg-for-storage-acc-to-log-anl",
    "vf-core-cm-diag-setg-for-blob-ser-to-log-anl",
    "vf-core-cm-diag-setg-for-file-ser-to-log-anl",
    "vf-core-cm-diag-setg-for-SQL-db-to-log-anl",
    "vf-core-cm-diag-setg-for-postgreSQL-to-log-anl",
    "vf-core-cm-diag-setg-for-mySQL-db-to-log-anl",
    "vf-core-cm-diag-setg-for-app-gw-to-log-anl"
)
foreach ($DS_policyDefinition in $DS_policyDefinitions) {
    $DS_PolicynameASS1 ="$DS_policyDefinition-$($newResourceGroupName)"
    $DS_PolicynameASS = $DS_PolicynameASS1
    $DS_GETpolicyDefinition = Get-AzPolicyDefinition -Name $DS_policyDefinition
    $DS_existingpolicyAssignment = Get-AzPolicyAssignment -Name $DS_PolicynameASS -Scope $newResourceGroupId -ErrorAction SilentlyContinue

    if ($null -eq $DS_existingpolicyAssignment) {
        $DS_policyAssignment = New-AzPolicyAssignment -Name $DS_PolicynameASS -PolicyDefinition $DS_GETpolicyDefinition -Scope $newResourceGroupId -Location $newResourceGrouplocation  -IdentityType 'UserAssigned' -IdentityId $userAssignedIdentity.Id  -PolicyParameterObject $DS_policyParameters
        Start-AzPolicyRemediation  -Name "$DS_PolicynameASS _$currentDateTime" -PolicyAssignmentId $DS_policyAssignment.Id -scope $DS_policyAssignment.Scope
        Write-Output "Assigned policy $DS_policyDefinition to resource group $newResourceGroupName."
        Write-Output "Remediation task started for policy $DS_PolicynameASS."
    } else {
        Write-Output "The policy $DS_policyDefinition is already assigned to the resource group $newResourceGroupName."
        
    }
}
###############################################################################################
#ADD_ Log_SearchAlertRule-custom- -per policy -RG
###############################################################################################
Write-Output "**********CUSTOM-LOG-SEARCH-RULE-ALERT-POLICIES **********"
start-sleep -s 3
$jsonFilePathsPolicy = @(
    "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-blob-services-availability.json",
    "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-storage-account-avl.json",
    "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-file-services-avl.json",
    "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-SQL-server-cpu-per.json",
    "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-SQL-server-memory-per.json",
    "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-SQL-server-data-used-per.json",
    "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-SQL-server-failed-conn.json",
    "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-SQL-server-dtu-per.json",
    "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-SQL-server-log-IO-per-conn.json",
    "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-SQL-server-data-IO-per.json",
    "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-PSQL-flx-server-cpu-per.json",
    "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-PSQL-flx-server-memory-per.json",
    "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-PSQL-flx-server-storage-per.json",
    "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-PSQL-flx-server-act-conn-xceed.json",
    "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-PSQL-flx-server-failed-conn.json",
    "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-PSQL-flx-server-rep-lag.json",
    "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-MySQL-flx-server-host-cpu-per.json",
    "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-MySQL-flx-server-host-memory-per.json",
    "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-MySQL-flx-server-storage-per.json",
    "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-MySQL-flx-server-act-conn-xceed.json",
    "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-MySQL-flx-server-aborted-conn.json",
    "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-MySQL-flx-server-replica-lag.json",
    "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-app-gw-unhealthyhost-count-lag.json",
    "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-app-gw-failed-req-.json"
)
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
foreach ($index in 0..($jsonFilePathsPolicy.Length - 1)) {
    $jsonFilePath = $jsonFilePathsPolicy[$index]
    $policyName = $policyNames[$index]
    $jsonContentPolicy = Get-Content -Path $jsonFilePath -Raw
    $jsonContentPolicy = $jsonContentPolicy `
        -replace '\$rgScope', $newResourceGroupId `
        -replace '\$Alocation', $newResourceGrouplocation  `
        -replace '\$customerRG', $newResourceGroupName `
        -replace '\$AactionGroupName', $actionGroupId 

    $policyDefinition = $jsonContentPolicy 
    try {
        $existingPolicyDefinition = Get-AzPolicyDefinition -Name $policyName -ErrorAction Stop
    } catch {
        $existingPolicyDefinition = $null
    }
    if ($null -ne $existingPolicyDefinition) {
        Write-Output "Policy Definition $policyName already exists."
    } else {
    New-AzPolicyDefinition -Name $policyName -DisplayName $policyName -Policy $policyDefinition
    Start-Sleep -Milliseconds 5
    Write-Output "policy Definition $policyName created"
    }
    Start-Sleep -Milliseconds 5
    $existingpolicyAssignment = Get-AzPolicyAssignment -Name $policyName -Scope $newResourceGroupId -ErrorAction SilentlyContinue

    if ($null -ne $existingpolicyAssignment) {
        Write-Output "The policy $policyName is already assigned to the resource group $newResourceGroupName."
    } else {
    $NewpolicyDefinition = Get-AzPolicyDefinition -Name $policyName
    Start-Sleep -Milliseconds 5
    $policyAssignment = New-AzPolicyAssignment -Name $policyName -Scope $newResourceGroupId -PolicyDefinition $NewpolicyDefinition -IdentityType 'UserAssigned' -IdentityId $userAssignedIdentity.Id -Location $userAssignedIdentity.Location
    Start-AzPolicyRemediation  -Name "$policyName _$currentDateTime" -PolicyAssignmentId $policyAssignment.Id -scope $policyAssignment.Scope
    Write-Output "Policy $policyName assigned to resource group $newResourceGroupName."
    Write-Output "Remediation task started for policy $policyName."
}
}

###############################################################################################
#ADD_AzLogAlertRule 
###############################################################################################
Write-Output "**********ACTIVITY-LOG-ALERT-RULE**********"
start-sleep -s 3
$existingActivityLogAlerts = Invoke-RestMethod -Method Get -Headers $header -Uri $URI_AzLogAlertRule 
foreach ($ActivityLogAlerts in $existingActivityLogAlerts.value) {
    $AlertIdAzLogAlertRule = $ActivityLogAlerts.id
    $AlertNameAzLogAlertRule = $ActivityLogAlerts.name
    $updateUriAzLogAlertRule = "https://management.azure.com$($AlertIdAzLogAlertRule)?api-version=2017-04-01"
    $AzLogAlertRuleeachLogAlert = Invoke-RestMethod -Method Get -Headers $header -Uri $updateUriAzLogAlertRule
    
    if ($AzLogAlertRuleeachLogAlert.properties.scopes -contains $newResourceGroupId) {
        Write-Output "The resource group $newResourceGroupName is already in the scope of $AlertNameAzLogAlertRule"
    } elseif ($AlertNameAzLogAlertRule -eq "vf-core-cm-resource-health-alert") {
        
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
    $ALupdate = Invoke-RestMethod -Uri $updateUriAzLogAlertRule -Method  put -Headers $header -Body $BodyAzLogAlertRule
    $newResourceGroupIdout = $($ALupdate).properties.scopes | ConvertTo-Json
    Write-Output "ACTIVITY-LOG-ALERT-RULE : $AlertNameAzLogAlertRule new scope $newResourceGroupIdout"
}
}
###############################################################################################
#ADD_AzMetricAlertRule-per VM location
###############################################################################################
Write-Output "**********METRIC-ALERT-RULE**********"
start-sleep -s 3
$AllMetricAlert = Invoke-RestMethod -Uri $URI_MetricAlert -Method get -Headers $header 
$ExistingMetricAlert = $AllMetricAlert.value | Where-Object { $_.Name -like "vf-core-cm-*-$vmLocation"}

if (-not $ExistingMetricAlert) {
    $jsonFilePathsMetricAlert = @(
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-core-cm-vm-data-disk-iops-consumed-percentage.json",
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-core-cm-vm-availability.json",
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-core-cm-vm-available-memory.json",
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-core-cm-VM-os-disk-iops-consumed-percentage.json",
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-core-cm-vm-cpu-percentage.json"
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
        Write-Output "METRIC-ALERT-RULE : $alertName new scope :
    [
        $MetricsnewScopeoutv1
    ]"

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
  Write-Output "METRIC-ALERT-RULE : $MalertName 
    new scope $MetricsnewScopeout"
    }
}}
###############################################################################################
#  RG-Health-Alert
###############################################################################################
Write-Output "**********RESOURCE-GROUP-HEALTH-ALERT**********"
start-sleep -s 3
$resourceGroupRG = $newResourceGroupName
$RGAlertRG= Invoke-RestMethod -Uri $RGhealthURI -Method get -Headers $header 
$RGScopeRG = $RGAlertRG.properties.condition.allOf.anyof | Where-Object { $_.field -eq "resourceGroup" } 
$newResourceGroupRG = @{
    "field" = "resourceGroup"
    "equals" = "$($resourceGroupRG)"
  } 
$resourceGroupExistsRG = $RGScopeRG | Where-Object { $_.equals -eq "$($resourceGroupRG)" }

if ($null -eq $resourceGroupExistsRG) {
        $NEWRGAlertRG= Invoke-RestMethod -Uri $RGhealthURI -Method get -Headers $header 
        $NEWRGScopeRG = $NEWRGAlertRG.properties.condition.allOf.anyof | Where-Object { $_.field -eq "resourceGroup" } 
        $resourceGroupCountRG = $NEWRGScopeRG.count
        $equalsValueRG = $NEWRGScopeRG.equals

        if ($null -eq $resourceGroupCountRG) {
           
            $resourceGroupCountRG = "1"
        }
        if ($null -eq $resourceTyCountRG) {
           
            $resourceTyCountRG = "1"
        }
        if ($resourceGroupCountRG -ne "1") {
            $UpdateNEWRGScopeRG = $NEWRGScopeRG += $newResourceGroupRG
            $UpdateNEWRGScopev2RG = $UpdateNEWRGScopeRG | ConvertTo-Json -Depth 10
        }

        $NEWRTyScopeRG = $NEWRGAlertRG.properties.condition.allOf.anyof | Where-Object { $_.field -eq "resourceType" } 
        $equalsValueTYRG = $NEWRTyScopeRG.equals
        $resourceTyCountRG = $NEWRTyScopeRG.count
        $AzLogAlertRuleeachLogAlertRG =  $NEWRGAlertRG

        $AzLogAlertRuleExistingIdRG = $AzLogAlertRuleeachLogAlertRG.id | ConvertTo-Json
        $AzLogAlertRuleExistingNameRG = $AzLogAlertRuleeachLogAlertRG.name | ConvertTo-Json
        $AzLogAlertRuleExistingTagsRG = $AzLogAlertRuleeachLogAlertRG.tags | ConvertTo-Json
        $AzLogAlertRuleExistinScopesRG = $AzLogAlertRuleeachLogAlertRG.properties.scopes | ConvertTo-Json
        $AzLogAlertRuleExistinScopesv2RG = @"
[
  $AzLogAlertRuleExistinScopesRG
]
"@
        
        $AzLogAlertRuleExistingConditionResourceGroupRG = $UpdateNEWRGScopev2RG   #| ConvertTo-Json -Depth 10
        $AzLogAlertRuleExistingConditionResourceTypeRG = $NEWRTyScopeRG | ConvertTo-Json -Depth 10

        # 1 RG and mut RGTY
        $AzLogAlertRuleExistingConditionV1RG = @"
{
    "allOf": [
        {
            "field": "category",
            "equals": "ResourceHealth"
        },
        {
            "anyOf": [
                {
                  "field": "resourceGroup",
                  "equals": "$($equalsValueRG)"
                },
                {
                  "field": "resourceGroup",
                  "equals": "$($resourceGroupRG)"
                }
              ]
        },
        {
            "anyOf": 
            $AzLogAlertRuleExistingConditionResourceTypeRG
        }
    ]
}
"@
#mult RG & one RGTY
        $AzLogAlertRuleExistingConditionV2RG = @"
{
    "allOf": [
        {
            "field": "category",
            "equals": "ResourceHealth"
        },
        {
            "anyOf": 
            $AzLogAlertRuleExistingConditionResourceGroupRG
        },
        {
            "anyOf": [
              {
                "field": "resourceType",
                "equals": "$($equalsValueTYRG)"
              }
            ]
            
        }
    ]
}
"@
#1 RG & 1 RGTY
        $AzLogAlertRuleExistingConditionV3RG = @"
  {
      "allOf": [
          {
              "field": "category",
              "equals": "ResourceHealth"
          },
          {
              "anyOf": [
                  {
                    "field": "resourceGroup",
                    "equals": "$($equalsValueRG)"
                  },
                  {
                    "field": "resourceGroup",
                    "equals": "$($resourceGroupRG)"
                  }
                ]
          },
          {
              "anyOf": [
                {
                  "field": "resourceType",
                  "equals": "$($equalsValueTYRG)"
                }
              ]
              
          }
      ]
  }
"@

#mut RG & Mut RGTY
        $AzLogAlertRuleExistingConditionV4RG = @"
{
    "allOf": [
        {
            "field": "category",
            "equals": "ResourceHealth"
        },
        {
            "anyOf": 
            $AzLogAlertRuleExistingConditionResourceGroupRG
        },
        {
            "anyOf": 
            $AzLogAlertRuleExistingConditionResourceTypeRG
        }
    ]
}
"@

        if ($resourceGroupCountRG -eq "1" -and $resourceTyCountRG -ne "1") {
        $UPAzLogAlertRuleExistingConditionRG = $AzLogAlertRuleExistingConditionV1RG
        
        }elseif ($resourceGroupCountRG -ne "1" -and $resourceTyCountRG -eq "1") {
        $UPAzLogAlertRuleExistingConditionRG = $AzLogAlertRuleExistingConditionV2RG
        }elseif ($resourceGroupCountRG -eq "1" -and $resourceTyCountRG -eq "1") {
            $UPAzLogAlertRuleExistingConditionRG = $AzLogAlertRuleExistingConditionV3RG
        } else {
        $UPAzLogAlertRuleExistingConditionRG = $AzLogAlertRuleExistingConditionV4RG
        }
        $AzLogAlertRuleExistingActionsRG = $AzLogAlertRuleeachLogAlertRG.properties.actions | ConvertTo-Json
        $AzLogAlertRuleExistingDescriptionRG = $AzLogAlertRuleeachLogAlertRG.properties.description | ConvertTo-Json

        $BodyAzLogAlertRuleRG = @"
{
    "id": $AzLogAlertRuleExistingIdRG,
    "name": $AzLogAlertRuleExistingNameRG,
    "type": "Microsoft.Insights/ActivityLogAlerts",
    "location": "global",
    "tags": $AzLogAlertRuleExistingTagsRG,
    "properties": {
        "scopes": $AzLogAlertRuleExistinScopesv2RG,
        "condition": $UPAzLogAlertRuleExistingConditionRG,
        "actions": $AzLogAlertRuleExistingActionsRG,
        "enabled": true,
        "description": $AzLogAlertRuleExistingDescriptionRG
    }
}
"@

      
      $RGAlertPUTRG= Invoke-RestMethod -Uri $RGhealthURI -Method put   -Headers $header  -Body $BodyAzLogAlertRuleRG
      $RGScopeUPdateRG = $RGAlertPUTRG.properties.condition.allOf.anyof | Where-Object { $_.field -eq "resourceGroup" } |ConvertTo-Json -Depth 10
      write-output "RESOURCE-GROUP-HEALTH-ALERT : $RGScopeUPdateRG"
      }else {
        Write-Output "Resource Group neme $($resourceGroupRG) does exist in the alert scope "
    }    
###############################################################################################
do {
    $addResourceGroup = Read-Host "Do you want to add another resource group? (yes/no)"
    $secureToken = (Get-AzAccessToken -ResourceUrl "https://management.azure.com" -AsSecureString).Token
    $accessToken = [System.Net.NetworkCredential]::new("", $secureToken).Password

$header = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}
    if ([string]::IsNullOrEmpty($addResourceGroup) -or $addResourceGroup -eq "yes" -or $addResourceGroup -eq "y") {
        $newResourceGroupName = Read-Host "Enter the new Resource Group name to monitor"
        $addVMLocation = Read-Host "Do you want to cahnge virtual machine location? 
Curent : $vmLocation 
(yes/no) "
        if ([string]::IsNullOrEmpty($addVMLocation) -or $addVMLocation -eq "yes" -or $addVMLocation -eq "y") {
            $vmLocation = Read-Host "Enter the location of the VMs to monitor"
        }}
        $newResourceGroup = Get-AzResourceGroup -Name $newResourceGroupName
        $newResourceGroupId = $newResourceGroup.ResourceId
        $newResourceGrouplocation = $newResourceGroup.Location
    ###############################################################################################
    #TAGS & diag-setg -per-RG -NEW
    ###############################################################################################
    Write-Output "**********TAG-POLICIES**********"
    start-sleep -s 3

        $TS_PolicynameASS1 ="vf-core-cm-tag-resources-$($newResourceGroupName)"
        $TS_PolicynameASS = $TS_PolicynameASS1
        $TS_GETpolicyDefinition = Get-AzPolicyDefinition -Name "vf-core-cm-tag-resources"
        $TS_existingpolicyAssignment = Get-AzPolicyAssignment -Name $TS_PolicynameASS -Scope $newResourceGroupId -ErrorAction SilentlyContinue
        if ($null -eq $TS_existingpolicyAssignment) {
            $TS_policyAssignment = New-AzPolicyAssignment -Name $TS_PolicynameASS -PolicyDefinition $TS_GETpolicyDefinition -Scope $newResourceGroupId -Location $newResourceGrouplocation  -IdentityType 'UserAssigned' -IdentityId $userAssignedIdentity.Id  -PolicyParameterObject $TS_policyParameters
            Start-AzPolicyRemediation  -Name "$TS_PolicynameASS _$currentDateTime" -PolicyAssignmentId $TS_policyAssignment.Id -scope $TS_policyAssignment.Scope
            Write-Output "Assigned policy  vf-core-cm-tag-resources to resource group $newResourceGroupName."
            Write-Output "Remediation task started for policy $TS_PolicynameASS."
        } else {
            Write-Output "The policy vf-core-cm-tag-resources is already assigned to the resource group $newResourceGroupName."
        }
        Write-Output "**********DIAG-SETTING-POLICIES**********"
        start-sleep -s 3
        foreach ($DS_policyDefinition in $DS_policyDefinitions) {
            $DS_PolicynameASS1 ="$DS_policyDefinition-$($newResourceGroupName)"
            $DS_PolicynameASS = $DS_PolicynameASS1
            $DS_GETpolicyDefinition = Get-AzPolicyDefinition -Name $DS_policyDefinition
            $DS_existingpolicyAssignment = Get-AzPolicyAssignment -Name $DS_PolicynameASS -Scope $newResourceGroupId -ErrorAction SilentlyContinue
        
            if ($null -eq $DS_existingpolicyAssignment) {
                $DS_policyAssignment = New-AzPolicyAssignment -Name $DS_PolicynameASS -PolicyDefinition $DS_GETpolicyDefinition -Scope $newResourceGroupId -Location $newResourceGrouplocation  -IdentityType 'UserAssigned' -IdentityId $userAssignedIdentity.Id  -PolicyParameterObject $DS_policyParameters
                Start-AzPolicyRemediation  -Name "$DS_PolicynameASS _$currentDateTime" -PolicyAssignmentId $DS_policyAssignment.Id -scope $DS_policyAssignment.Scope
                Write-Output "Assigned policy $DS_policyDefinition to resource group $newResourceGroupName."
                Write-Output "Remediation task started for policy $DS_PolicynameASS."
            } else {
                Write-Output "The policy $DS_policyDefinition is already assigned to the resource group $newResourceGroupName."
                
            }
        }
    ###############################################################################################
    #ADD_ Log_SearchAlertRule-custom- -per policy -RG
    ###############################################################################################
    Write-Output "**********CUSTOM-LOG-SEARCH-RULE-ALERT-POLICIES **********"
    start-sleep -s 3
    $jsonFilePathsPolicy = @(
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-blob-services-availability.json",
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-storage-account-avl.json",
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-file-services-avl.json",
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-SQL-server-cpu-per.json",
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-SQL-server-memory-per.json",
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-SQL-server-data-used-per.json",
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-SQL-server-failed-conn.json",
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-SQL-server-dtu-per.json",
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-SQL-server-log-IO-per-conn.json",
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-SQL-server-data-IO-per.json",
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-PSQL-flx-server-cpu-per.json",
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-PSQL-flx-server-memory-per.json",
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-PSQL-flx-server-storage-per.json",
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-PSQL-flx-server-act-conn-xceed.json",
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-PSQL-flx-server-failed-conn.json",
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-PSQL-flx-server-rep-lag.json",
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-MySQL-flx-server-host-cpu-per.json",
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-MySQL-flx-server-host-memory-per.json",
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-MySQL-flx-server-storage-per.json",
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-MySQL-flx-server-act-conn-xceed.json",
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-MySQL-flx-server-aborted-conn.json",
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-MySQL-flx-server-replica-lag.json",
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-app-gw-unhealthyhost-count-lag.json",
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-cm-app-gw-failed-req-.json"
    )
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
    foreach ($index in 0..($jsonFilePathsPolicy.Length - 1)) {
        $jsonFilePath = $jsonFilePathsPolicy[$index]
        $policyName = $policyNames[$index]
        $jsonContentPolicy = Get-Content -Path $jsonFilePath -Raw
        $jsonContentPolicy = $jsonContentPolicy `
            -replace '\$rgScope', $newResourceGroupId `
            -replace '\$Alocation', $newResourceGrouplocation  `
            -replace '\$customerRG', $newResourceGroupName `
            -replace '\$AactionGroupName', $actionGroupId 
    
        $policyDefinition = $jsonContentPolicy 
        try {
            $existingPolicyDefinition = Get-AzPolicyDefinition -Name $policyName -ErrorAction Stop
        } catch {
            $existingPolicyDefinition = $null
        }
        if ($null -ne $existingPolicyDefinition) {
            Write-Output "Policy Definition $policyName already exists."
        } else {
        New-AzPolicyDefinition -Name $policyName -DisplayName $policyName -Policy $policyDefinition
        Start-Sleep -Milliseconds 5
        Write-Output "policy Definition $policyName created"
        }
        Start-Sleep -Milliseconds 5
        $existingpolicyAssignment = Get-AzPolicyAssignment -Name $policyName -Scope $newResourceGroupId -ErrorAction SilentlyContinue
    
        if ($null -ne $existingpolicyAssignment) {
            Write-Output "The policy $policyName is already assigned to the resource group $newResourceGroupName."
        } else {
        $NewpolicyDefinition = Get-AzPolicyDefinition -Name $policyName
        Start-Sleep -Milliseconds 5
        $policyAssignment = New-AzPolicyAssignment -Name $policyName -Scope $newResourceGroupId -PolicyDefinition $NewpolicyDefinition -IdentityType 'UserAssigned' -IdentityId $userAssignedIdentity.Id -Location $userAssignedIdentity.Location
        Start-AzPolicyRemediation  -Name "$policyName _$currentDateTime" -PolicyAssignmentId $policyAssignment.Id -scope $policyAssignment.Scope
        Write-Output "Policy $policyName assigned to resource group $newResourceGroupName."
        Write-Output "Remediation task started for policy $policyName."
    }
    }
    ###############################################################################################
    #ADD_AzLogAlertRule 
    ###############################################################################################
    Write-Output "**********ACTIVITY-LOG-ALERT-RULE**********"
    start-sleep -s 3
    $existingActivityLogAlerts = Invoke-RestMethod -Method Get -Headers $header -Uri $URI_AzLogAlertRule 
    foreach ($ActivityLogAlerts in $existingActivityLogAlerts.value) {
        $AlertIdAzLogAlertRule = $ActivityLogAlerts.id
        $AlertNameAzLogAlertRule = $ActivityLogAlerts.name
        $updateUriAzLogAlertRule = "https://management.azure.com$($AlertIdAzLogAlertRule)?api-version=2017-04-01"
        $AzLogAlertRuleeachLogAlert = Invoke-RestMethod -Method Get -Headers $header -Uri $updateUriAzLogAlertRule
        
        if ($AzLogAlertRuleeachLogAlert.properties.scopes -contains $newResourceGroupId) {
            Write-Output "The resource group $newResourceGroupName is already in the scope of $AlertNameAzLogAlertRule"
        } elseif ($AlertNameAzLogAlertRule -eq "vf-core-cm-resource-health-alert") {
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
        $ALupdate = Invoke-RestMethod -Uri $updateUriAzLogAlertRule -Method  put -Headers $header -Body $BodyAzLogAlertRule
        $newResourceGroupIdout = $($ALupdate).properties.scopes | ConvertTo-Json
        Write-Output "ACTIVITY-LOG-ALERT-RULE : $AlertNameAzLogAlertRule new scope $newResourceGroupIdout"
    }
    }
    ###############################################################################################
    #ADD_AzMetricAlertRule-per VM location
    ###############################################################################################
    Write-Output "**********METRIC-ALERT-RULE**********"
    start-sleep -s 3
    $AllMetricAlert = Invoke-RestMethod -Uri $URI_MetricAlert -Method get -Headers $header 
    $ExistingMetricAlert = $AllMetricAlert.value | Where-Object { $_.Name -like "vf-core-cm-*-$vmLocation"}

    if (-not $ExistingMetricAlert) {
        $jsonFilePathsMetricAlert = @(
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-core-cm-vm-data-disk-iops-consumed-percentage.json",
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-core-cm-vm-availability.json",
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-core-cm-vm-available-memory.json",
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-core-cm-VM-os-disk-iops-consumed-percentage.json",
        "~/Cloud-Monitoring-Service-Requests/AzPolicyDefinition/vf-core-cm-vm-cpu-percentage.json"
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
        Write-Output "METRIC-ALERT-RULE : $alertName new scope :
        [
            $MetricsnewScopeoutv1
        ]"

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
  Write-Output "METRIC-ALERT-RULE : $MalertName  new scope $MetricsnewScopeout"
    }}
}
###############################################################################################
#  RG-Health-Alert
###############################################################################################
Write-Output "**********RESOURCE-GROUP-HEALTH-ALERT**********"
start-sleep -s 3
$resourceGroupRG = $newResourceGroupName
$RGAlertRG= Invoke-RestMethod -Uri $RGhealthURI -Method get -Headers $header 
$RGScopeRG = $RGAlertRG.properties.condition.allOf.anyof | Where-Object { $_.field -eq "resourceGroup" } 
$newResourceGroupRG = @{
    "field" = "resourceGroup"
    "equals" = "$($resourceGroupRG)"
}
$resourceGroupExistsRG = $RGScopeRG | Where-Object { $_.equals -eq "$($resourceGroupRG)" }
if ($null -eq $resourceGroupExistsRG) {
        $NEWRGAlertRG= Invoke-RestMethod -Uri $RGhealthURI -Method get -Headers $header 
        $NEWRGScopeRG = $NEWRGAlertRG.properties.condition.allOf.anyof | Where-Object { $_.field -eq "resourceGroup" } 
        $resourceGroupCountRG = $NEWRGScopeRG.count
        $equalsValueRG = $NEWRGScopeRG.equals
        if ($null -eq $resourceGroupCountRG) {
           
            $resourceGroupCountRG = "1"
        }
        if ($null -eq $resourceTyCountRG) {
           
            $resourceTyCountRG = "1"
        }
        if ($resourceGroupCountRG -ne "1") {
            $UpdateNEWRGScopeRG = $NEWRGScopeRG += $newResourceGroupRG
            $UpdateNEWRGScopev2RG = $UpdateNEWRGScopeRG | ConvertTo-Json -Depth 10
        }
        $NEWRTyScopeRG = $NEWRGAlertRG.properties.condition.allOf.anyof | Where-Object { $_.field -eq "resourceType" } 
        $equalsValueTYRG = $NEWRTyScopeRG.equals
        $resourceTyCountRG = $NEWRTyScopeRG.count
        $AzLogAlertRuleeachLogAlertRG =  $NEWRGAlertRG
        $AzLogAlertRuleExistingIdRG = $AzLogAlertRuleeachLogAlertRG.id | ConvertTo-Json
        $AzLogAlertRuleExistingNameRG = $AzLogAlertRuleeachLogAlertRG.name | ConvertTo-Json
        $AzLogAlertRuleExistingTagsRG = $AzLogAlertRuleeachLogAlertRG.tags | ConvertTo-Json
        $AzLogAlertRuleExistinScopesRG = $AzLogAlertRuleeachLogAlertRG.properties.scopes | ConvertTo-Json
        $AzLogAlertRuleExistinScopesv2RG = @"
[
  $AzLogAlertRuleExistinScopesRG
]
"@   
        $AzLogAlertRuleExistingConditionResourceGroupRG = $UpdateNEWRGScopev2RG   #| ConvertTo-Json -Depth 10
        $AzLogAlertRuleExistingConditionResourceTypeRG = $NEWRTyScopeRG | ConvertTo-Json -Depth 10
        # 1 RG and mut RGTY
        $AzLogAlertRuleExistingConditionV1RG = @"
{
    "allOf": [
        {
            "field": "category",
            "equals": "ResourceHealth"
        },
        {
            "anyOf": [
                {
                  "field": "resourceGroup",
                  "equals": "$($equalsValueRG)"
                },
                {
                  "field": "resourceGroup",
                  "equals": "$($resourceGroupRG)"
                }
              ]
        },
        {
            "anyOf": 
            $AzLogAlertRuleExistingConditionResourceTypeRG
        }
    ]
}
"@
#mult RG & one RGTY
        $AzLogAlertRuleExistingConditionV2RG = @"
{
    "allOf": [
        {
            "field": "category",
            "equals": "ResourceHealth"
        },
        {
            "anyOf": 
            $AzLogAlertRuleExistingConditionResourceGroupRG
        },
        {
            "anyOf": [
              {
                "field": "resourceType",
                "equals": "$($equalsValueTYRG)"
              }
            ]
            
        }
    ]
}
"@
#1 RG & 1 RGTY
        $AzLogAlertRuleExistingConditionV3RG = @"
  {
      "allOf": [
          {
              "field": "category",
              "equals": "ResourceHealth"
          },
          {
              "anyOf": [
                  {
                    "field": "resourceGroup",
                    "equals": "$($equalsValueRG)"
                  },
                  {
                    "field": "resourceGroup",
                    "equals": "$($resourceGroupRG)"
                  }
                ]
          },
          {
              "anyOf": [
                {
                  "field": "resourceType",
                  "equals": "$($equalsValueTYRG)"
                }
              ]
              
          }
      ]
  }
"@

#mut RG & Mut RGTY
        $AzLogAlertRuleExistingConditionV4RG = @"
{
    "allOf": [
        {
            "field": "category",
            "equals": "ResourceHealth"
        },
        {
            "anyOf": 
            $AzLogAlertRuleExistingConditionResourceGroupRG
        },
        {
            "anyOf": 
            $AzLogAlertRuleExistingConditionResourceTypeRG
        }
    ]
}
"@
    if ($resourceGroupCountRG -eq "1" -and $resourceTyCountRG -ne "1") {
        $UPAzLogAlertRuleExistingConditionRG = $AzLogAlertRuleExistingConditionV1RG
        }elseif ($resourceGroupCountRG -ne "1" -and $resourceTyCountRG -eq "1") {
        $UPAzLogAlertRuleExistingConditionRG = $AzLogAlertRuleExistingConditionV2RG
        }elseif ($resourceGroupCountRG -eq "1" -and $resourceTyCountRG -eq "1") {
        $UPAzLogAlertRuleExistingConditionRG = $AzLogAlertRuleExistingConditionV3RG
        } else {
        $UPAzLogAlertRuleExistingConditionRG = $AzLogAlertRuleExistingConditionV4RG
        }
        $AzLogAlertRuleExistingActionsRG = $AzLogAlertRuleeachLogAlertRG.properties.actions | ConvertTo-Json
        $AzLogAlertRuleExistingDescriptionRG = $AzLogAlertRuleeachLogAlertRG.properties.description | ConvertTo-Json
$BodyAzLogAlertRuleRG = @"
{
    "id": $AzLogAlertRuleExistingIdRG,
    "name": $AzLogAlertRuleExistingNameRG,
    "type": "Microsoft.Insights/ActivityLogAlerts",
    "location": "global",
    "tags": $AzLogAlertRuleExistingTagsRG,
    "properties": {
        "scopes": $AzLogAlertRuleExistinScopesv2RG,
        "condition": $UPAzLogAlertRuleExistingConditionRG,
        "actions": $AzLogAlertRuleExistingActionsRG,
        "enabled": true,
        "description": $AzLogAlertRuleExistingDescriptionRG
    }
}
"@  
      $RGAlertPUTRG= Invoke-RestMethod -Uri $RGhealthURI -Method put   -Headers $header  -Body $BodyAzLogAlertRuleRG
      $RGScopeUPdateRG = $RGAlertPUTRG.properties.condition.allOf.anyof | Where-Object { $_.field -eq "resourceGroup" } |ConvertTo-Json -Depth 10
      write-output "RESOURCE-GROUP-HEALTH-ALERT : $RGScopeUPdateRG" 
      } else {
        Write-Output "Resource Group neme $($resourceGroupRG) does exist in the alert scope "
        } 
    } while ($addResourceGroup -eq "yes" -or $addResourceGroup -eq "y" -or [string]::IsNullOrEmpty($addResourceGroup))

$WarningPreference = 'Continue'