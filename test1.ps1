$resourceGroupRG = $newResourceGroupName
$RGAlertRG= Invoke-RestMethod -Uri $RGhealthURI -Method get -Headers $header 
$RGScopeRG = $RGAlertRG.properties.condition.allOf.anyof | Where-Object { $_.field -eq "resourceGroup" } 

vf-core-cm-resource-health-alert
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
        if ($resourceGroupCountRG -eq $null) {
           
            $resourceGroupCountRG = "1"
        }
        $NEWRTyScopeRG = $NEWRGAlertRG.properties.condition.allOf.anyof | Where-Object { $_.field -eq "resourceType" } 
        $equalsValueTYRG = $NEWRTyScopeRG.equals
        $resourceTyCountRG = $NEWRTyScopeRG.count

        if ($resourceTyCountRG -eq $null) {
           
            $resourceTyCountRG = "1"
        }
        # Create a new array with $NEWRGScopeRG and $newResourceGroupRG
        if ($resourceGroupCountRG -ne "1") {
            $UpdateNEWRGScopeRG = $NEWRGScopeRG += $newResourceGroupRG
            $UpdateNEWRGScopev2RG = $UpdateNEWRGScopeRG | ConvertTo-Json -Depth 10
           
          }
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
      write-output $RGScopeUPdateRG
      start-sleep -s 5
      }else {
        Write-Output "Resource Group neme $($resourceGroupRG) does exist in the alert scope "
    } 
  
   
      
        
    
          

