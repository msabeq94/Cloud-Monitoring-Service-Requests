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
    Write-Host "$($entry.Key)) $($entry.Value)"
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
$RMResourceGroupName = Read-Host "Enter the new Resource Group name to monitor"
$vmLocation = Read-Host "Enter the location of the VMs to monitor"

$RMResourceGroup = Get-AzResourceGroup -Name $RMResourceGroupName
$RMResourceGroupId = $RMResourceGroup.ResourceId
$RMResourceGrouplocation = $RMResourceGroup.Location

$actionGroup = Get-AzActionGroup -ResourceGroupName  $PCRalertResourceGroup -Name 'vf-core-cm-notifications'
$actionGroupId = $actionGroup.Id
$actionGroupName = $actionGroup.Name

$RM_AzLogAlerRuleuri = "https://management.azure.com/subscriptions/$($subscriptionID)/resourceGroups/$($PCRalertResourceGroupv2)/providers/Microsoft.Insights/activityLogAlerts?api-version=2017-04-01"
$RGhealthURI ="https://management.azure.com/subscriptions/$($subscriptionID)/resourceGroups/$($PCRalertResourceGroup)/providers/microsoft.insights/activityLogAlerts/vf-core-cm-resource-health-alert?api-version=2017-04-01"

###############################################################################################
# RM TAGS & diag-setg -per-RG
###############################################################################################

try {
    $policyAssignmentsInScope = Get-AzPolicyAssignment -Scope $RMResourceGroupId
} catch {
    $policyAssignmentsInScope = $null
}

if ($policyAssignmentsInScope) {
    foreach ($policyAssignment in $policyAssignmentsInScope) {
        Remove-AzPolicyAssignment -Id $policyAssignment.Id -Force
        Write-Output "Removed policy assignment: $($policyAssignment.Name)"
    }
} else {
    Write-Output "No policy assignments found."
}

$policyDefinitionsInScope = Get-AzPolicyDefinition | Where-Object { $_.Name -like "*-$RMResourceGroupName" }
if ($policyDefinitionsInScope) {
    foreach ($policyDefinition in $policyDefinitionsInScope) {
        Remove-AzPolicyDefinition -Name $policyDefinition.Name -Force
        Write-Output "Removed policy Definition: $($policyDefinition.Name)"
    }
} else {
    Write-Output "No policies found with the specified name."
}
###############################################################################################
# Log_SearchAlertRule-custom -per-RG
###############################################################################################
$SearchAlertRuleNames = @(
    "vf-cm-blob-services-availability-$RMResourceGroupName",
    "vf-cm-storage-account-avl-$RMResourceGroupName",
    "vf-cm-file-services-avl-$RMResourceGroupName",
    "vf-cm-SQL-server-cpu-per-$RMResourceGroupName",
    "vf-cm-SQL-server-memory-per-$RMResourceGroupName",
    "vf-cm-SQL-server-data-used-per-$RMResourceGroupName",
    "vf-cm-SQL-server-failed-conn-$RMResourceGroupName",
    "vf-cm-SQL-server-dtu-per-$RMResourceGroupName",
    "vf-cm-SQL-server-log-IO-per-conn-$RMResourceGroupName",
    "vf-cm-SQL-server-data-IO-per-$RMResourceGroupName",
    "vf-cm-PSQL-flx-server-cpu-per-$RMResourceGroupName",
    "vf-cm-PSQL-flx-server-memory-per-$RMResourceGroupName",
    "vf-cm-PSQL-flx-server-storage-per-$RMResourceGroupName",
    "vf-cm-PSQL-flx-server-act-conn-xceed-$RMResourceGroupName",
    "vf-cm-PSQL-flx-server-failed-conn-$RMResourceGroupName",
    "vf-cm-PSQL-flx-server-rep-lag-$RMResourceGroupName",
    "vf-cm-MySQL-flx-server-host-cpu-per-$RMResourceGroupName",
    "vf-cm-MySQL-flx-server-host-memory-per-$RMResourceGroupName",
    "vf-cm-MySQL-flx-server-storage-per-$RMResourceGroupName",
    "vf-cm-MySQL-flx-server-act-conn-xceed-$RMResourceGroupName",
    "vf-cm-MySQL-flx-server-aborted-conn-$RMResourceGroupName",
    "vf-cm-MySQL-flx-server-replica-lag-$RMResourceGroupName",
    "vf-cm-app-gw-unhealthyhost-count-lag-$RMResourceGroupName",
    "vf-cm-app-gw-failed-req-$RMResourceGroupName"
)
foreach ($SearchAlertRuleName in $SearchAlertRuleNames) {
    $RM_AzSearchAlertRule = "https://management.azure.com/subscriptions/$($subscriptionID)/resourceGroups/$($PCRalertResourceGroupv2)/providers/Microsoft.Insights/scheduledqueryrules/$($SearchAlertRuleName)?api-version=2021-08-01"
    try {
         Invoke-RestMethod -Uri $RM_AzSearchAlertRule -Method Delete -Headers $header
            Write-Output "Removed Log search alert rule: $SearchAlertRuleName"
        } catch {
            Write-Output "No Log search alert rule found with the specified name: $SearchAlertRuleName"
        }
        }
###############################################################################################
#ADD_AzLogAlertRule 
############################################################################################### 

    $existingActivityLogAlerts = Invoke-RestMethod -Method Get -Headers $header -Uri $RM_AzLogAlerRuleuri
    foreach ($ActivityLogAlerts in $existingActivityLogAlerts.value) {
        $alertName = $ActivityLogAlerts.name
     if ($alertName -eq "vf-core-cm-resource-health-alert") {
     }else {
            $alertId = $ActivityLogAlerts.id
            $updateUri = "https://management.azure.com$($alertId)?api-version=2017-04-01"
            $eachLogAlert = Invoke-RestMethod -Method Get -Headers $header -Uri $updateUri
            $updatedScopes = $($eachLogAlert).properties.scopes | Where-Object { $_ -ne $RMResourceGroupId} | Select-Object -Unique
            $existingcondition = $($eachLogAlert).properties.condition | ConvertTo-Json
            $existingcactions = $($eachLogAlert).properties.actions | ConvertTo-Json
            $existingdescription = $($eachLogAlert).properties.description | ConvertTo-Json
            $existintags = $($eachLogAlert).tags | ConvertTo-Json
            $existinname = $($eachLogAlert).name | ConvertTo-Json
            $existinid = $($eachLogAlert).id | ConvertTo-Json

            if ($updatedScopes.Count -eq 1) {
                $scopesBody = @("[`"$($updatedScopes)`"]")
            } else {
                $scopesBody = $updatedScopes | ConvertTo-Json -Compress
            }

$body = @"
{
    "id": $existinid,
    "name": $existinname,
    "type": "Microsoft.Insights/ActivityLogAlerts",
    "location": "global",
    "tags": $existintags,
    "properties": {
        "scopes" : $scopesBody,
        "condition": $existingcondition,
        "actions": $existingcactions,
        "enabled": true,
        "description": $existingdescription
    }
}
"@
            if ($null -eq $updatedScopes) {
                Write-Output "Alert cannot be removed as it only contains $RMResourceGroupName in its scope."
            } else {
                $update = Invoke-RestMethod -Uri $updateUri -Method put -Headers $header -Body $body
                Start-Sleep -Milliseconds 750
                $getscop = Invoke-RestMethod -Uri $updateUri -Method Get -Headers $header
                $RMScopeout = $($getscop).properties.scopes | ConvertTo-Json
                Write-Output "Activity log alert rule : $alertName new scope $RMScopeout"
            }  
}
}

###############################################################################################
#ADD_AzMetricAlertRule-per VM location
###############################################################################################
$AAllMatricURI = "https://management.azure.com/subscriptions/$($subscriptionID)/resourceGroups/$($PCRalertResourceGroupv2)/providers/Microsoft.Insights/metricalerts?api-version=2018-03-01"

$existingmetricalerts = Invoke-RestMethod -Uri $AAllMatricURI -Method get -Headers $header 
  $existingmetricalertslocations = $existingmetricalerts.value | Where-Object { $_.Name -like "vf-core-cm-*-$vmLocation"}


foreach ($existingmetricalertslocation in $existingmetricalertslocations ) {
    # Retrieve the current scopes of the alert rule
    $RMalertId = $($existingmetricalertslocation).id
    $RMalertName = $($existingmetricalertslocation).name
    $currentScopes = $existingmetricalertslocation.properties.Scopes
    $RoneuMatricuri = "https://management.azure.com$($RMalertId)?api-version=2018-03-01"
    if ($currentScopes -contains $RMResourceGroupId) {
        if ($currentScopes.Count -eq 1) {
            # Remove the entire alert rule if it only contains the resource group to be removed
            Invoke-RestMethod -Uri $RoneuMatricuri -Method Delete -Headers $header 
            Write-Output " Alert $RMalertName deleted "
        } else {
            # Remove the resource group from the scopes
            $newScop = $currentScopes  | Where-Object { $_ -ne $RMResourceGroupId}  | Select-Object -Unique
        $ReachMatric  = Invoke-RestMethod -Method Get -Headers $header -Uri $RoneuMatricuri
        $Mlocation = $($ReachMatric).location | ConvertTo-Json
        $Mcriteria = $($ReachMatric).properties.criteria | ConvertTo-Json
       
        $MevaluationFrequency = $($ReachMatric).properties.evaluationFrequency | ConvertTo-Json
        $Mseverity = $($ReachMatric).properties.severity | ConvertTo-Json
        $MwindowSize = $($ReachMatric).properties.windowSize | ConvertTo-Json
        $mtargetResourceType = $($ReachMatric).properties.targetResourceType | ConvertTo-Json
        $MtargetResourceRegion = $($ReachMatric).properties.targetResourceRegion | ConvertTo-Json
        $Mtargetaction = @"
[
    {
        "actionGroupId": "$actionGroupId",
        "webHookProperties": {}
    }
]
"@

    # Correctly format scopes based on their count
    if ($newScop.Count -eq 1) {
        $scopesBody = @("[`"$($newScop)`"]")
    } else {
        $scopesBody = $newScop | ConvertTo-Json -Compress
    }

# Create the body with proper JSON formatting
$bodyMatricUP = @"
{
    "location": $Mlocation,
    "properties": {
        "criteria": $Mcriteria,
        "enabled": true,
        "evaluationFrequency": $MevaluationFrequency,
        "scopes": $scopesBody,
        "severity": $Mseverity,
        "windowSize": $MwindowSize,
        "targetResourceType": $mtargetResourceType,
        "targetResourceRegion": $MtargetResourceRegion,
        "actions": $Mtargetaction
    }
}
"@

       $Matupdate = Invoke-RestMethod -Uri $RoneuMatricuri  -Method put -Headers $header -Body $bodyMatricUP
        $MetricsnewScopeout = $($Matupdate).properties.scopes | ConvertTo-Json
        Write-Output "Metric alert rule : $RMalertName new scope $MetricsnewScopeout"
    }

    } else {
        Write-Output "Metric alert rule : $($existingmetricalertslocation.Name) does not include $RMResourceGroupName 
        scope $MetricsnewScopeout"
    }

 
}


###############################################################################################
#  RG-Health-Alert
###############################################################################################

$RGAlertRG= Invoke-RestMethod -Uri $RGhealthURI -Method get -Headers $header 
$RGScopeRG = $RGAlertRG.properties.condition.allOf.anyof | Where-Object { $_.field -eq "resourceGroup" } 
$resourceGroupExistsRG = $RGScopeRG | Where-Object { $_.equals -eq "$($RMResourceGroupName)" }
$resourceGroupCountRGv1 = $RGScopeRG.count
if ($null -ne $resourceGroupExistsRG -and  $resourceGroupCountRGv1 -eq "1" ){
    Write-Output "Resource Group neme $($RMResourceGroupName) is only Resource Group in the alert scope"
} elseif ($null -ne $resourceGroupExistsRG -and  $resourceGroupCountRGv1 -gt "1" ) {
    $NEWRGScopeRG = $RGAlertRG.properties.condition.allOf.anyof | Where-Object { $_.field -eq "resourceGroup" } 
    $resourceGroupCountRG = $NEWRGScopeRG.count
    if ($resourceGroupCountRG -eq "2") {
        $UpdateNEWRGScopeRG = $NEWRGScopeRG | Where-Object { $_.equals -ne $RMResourceGroupName}
        $equalsValueRG = $UpdateNEWRGScopeRG.equals
    }
    if ($resourceGroupCountRG -gt "2") {
        $UpdateNEWRGScopeRG = $NEWRGScopeRG | Where-Object { $_.equals -ne $RMResourceGroupName}
        $UpdateNEWRGScopev2RG = $UpdateNEWRGScopeRG | ConvertTo-Json -Depth 10
    }
    $NEWRTyScopeRG = $RGAlertRG.properties.condition.allOf.anyof | Where-Object { $_.field -eq "resourceType" } 
    $equalsValueTYRG = $NEWRTyScopeRG.equals

    $AzLogAlertRuleeachLogAlertRG =  $RGAlertRG

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

    $resourceTyCountRG = $NEWRTyScopeRG.count
    $resourceGroupCountRGv2 = $UpdateNEWRGScopeRG.count
      
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
       
   
if ($resourceGroupCountRGv2 -eq "1" -and $resourceTyCountRG -ne "1") {
    $UPAzLogAlertRuleExistingConditionRG = $AzLogAlertRuleExistingConditionV1RG
    
    }elseif ($resourceGroupCountRGv2 -ne "1" -and $resourceTyCountRG -eq "1") {
    $UPAzLogAlertRuleExistingConditionRG = $AzLogAlertRuleExistingConditionV2RG
    }elseif ($resourceGroupCountRGv2 -eq "1" -and $resourceTyCountRG -eq "1") {
        $UPAzLogAlertRuleExistingConditionRG = $AzLogAlertRuleExistingConditionV3RG
    } else {
    $UPAzLogAlertRuleExistingConditionRG = $AzLogAlertRuleExistingConditionV4RG
    }
    $AzLogAlertRuleExistingActionsRG = $AzLogAlertRuleeachLogAlertRG.properties.actions | ConvertTo-Json
    $AzLogAlertRuleExistingDescriptionRG = $AzLogAlertRuleeachLogAlertRG.properties.description | ConvertTo-Json

    $BodyAzLogAlertRuleRG =@"
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
    write-output $RGScopeUPdateRG


} else {
    Write-Output "Resource Group neme $($RMResourceGroupName) doesn't exist in the alert scope "
} 


