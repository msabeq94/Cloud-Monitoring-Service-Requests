$RMResourceGroupName = "vf-03"
$RGAlertRG= Invoke-RestMethod -Uri $RGhealthURI -Method get -Headers $header 
$RGScopeRG = $RGAlertRG.properties.condition.allOf.anyof | Where-Object { $_.field -eq "resourceGroup" } 
$resourceGroupCountRGv1 = $NEWRGScopeRG.count
$resourceGroupExistsRG = $RGScopeRG | Where-Object { $_.equals -eq "$($RMResourceGroupName)" }
if ($resourceGroupExistsRG) {
    

    
    # $equalsValueRG = $UpdateNEWRGScopeRG.equals 
    # if ($null -eq $resourceGroupCountRG) {
       
    #     $resourceGroupCountRG = "1"
    #     $equalsValueRG = $UpdateNEWRGScopeRG.equals
    # }
    # if ($null -eq $resourceTyCountRG) {
       
    #     $resourceTyCountRG = "1"
    # }
    if ($resourceGroupCountRG -eq "2") {
        $UpdateNEWRGScopeRG = $NEWRGScopeRG | Where-Object { $_.equals -ne $RMResourceGroupName}
        $UpdateNEWRGScopev2RG = $UpdateNEWRGScopeRG | ConvertTo-Json -Depth 10
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


