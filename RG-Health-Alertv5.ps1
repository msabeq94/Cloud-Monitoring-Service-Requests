$resourceGroupRG ="VF-01"

$accessToken = (Get-AzAccessToken -ResourceUrl "https://management.azure.com").Token
$header = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

$RGhealthURI ="https://management.azure.com/subscriptions/24b4b7e2-6a4a-4418-8868-9f51dfeca509/resourceGroups/vf-core-IT-resources-rg/providers/microsoft.insights/activityLogAlerts/vf-core-cm-resource-health-alert?api-version=2017-04-01"


$RGAlert= Invoke-RestMethod -Uri $RGhealthURI -Method get -Headers $header 
$RGScope = $RGAlert.properties.condition.allOf.anyof | Where-Object { $_.field -eq "resourceGroup" } 


  $newResourceGroup = @{
    "field" = "resourceGroup"
    "equals" = "$($resourceGroupRG)"
  } 
      $resourceGroupExists = $RGScope | Where-Object { $_.equals -eq "$($resourceGroupRG)" }
      if ($null -eq $resourceGroupExists) {
        $NEWRGAlert= Invoke-RestMethod -Uri $RGhealthURI -Method get -Headers $header 
        $NEWRGScope = $NEWRGAlert.properties.condition.allOf.anyof | Where-Object { $_.field -eq "resourceGroup" } 
        $resourceGroupCount = $NEWRGScope.count
        $equalsValueRG = $NEWRGScope.equals
        if ($resourceGroupCount -eq $null) {
           
            $resourceGroupCount = "1"
        }
        $NEWRTyScope = $NEWRGAlert.properties.condition.allOf.anyof | Where-Object { $_.field -eq "resourceType" } 
        $equalsValueTY = $NEWRTyScope.equals
        $resourceTyCount = $NEWRTyScope.count

        if ($resourceTyCount -eq $null) {
           
            $resourceTyCount = "1"
        }
        # Create a new array with $NEWRGScope and $newResourceGroup
        if ($resourceGroupCount -ne "1") {
            $UpdateNEWRGScope = $NEWRGScope += $newResourceGroup
            $UpdateNEWRGScopev2 = $UpdateNEWRGScope | ConvertTo-Json -Depth 10
           
          }
        $AzLogAlertRuleeachLogAlert =  $NEWRGAlert
        
        $AzLogAlertRuleExistingId = $AzLogAlertRuleeachLogAlert.id | ConvertTo-Json
        $AzLogAlertRuleExistingName = $AzLogAlertRuleeachLogAlert.name | ConvertTo-Json
        $AzLogAlertRuleExistingTags = $AzLogAlertRuleeachLogAlert.tags | ConvertTo-Json
        $AzLogAlertRuleExistinScopes = $AzLogAlertRuleeachLogAlert.properties.scopes | ConvertTo-Json
        $AzLogAlertRuleExistinScopesv2 = @"
[
  $AzLogAlertRuleExistinScopes
]
"@
        
        $AzLogAlertRuleExistingConditionResourceGroup = $UpdateNEWRGScopev2   #| ConvertTo-Json -Depth 10
        $AzLogAlertRuleExistingConditionResourceType = $NEWRTyScope | ConvertTo-Json -Depth 10

# 1 RG and mut RGTY
$AzLogAlertRuleExistingConditionV1 = @"
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
            $AzLogAlertRuleExistingConditionResourceType
        }
    ]
}
"@

#mult RG & one RGTY
$AzLogAlertRuleExistingConditionV2 = @"
{
    "allOf": [
        {
            "field": "category",
            "equals": "ResourceHealth"
        },
        {
            "anyOf": 
            $AzLogAlertRuleExistingConditionResourceGroup
        },
        {
            "anyOf": [
              {
                "field": "resourceType",
                "equals": "$($equalsValueTY)"
              }
            ]
            
        }
    ]
}
"@

#1 RG & 1 RGTY
$AzLogAlertRuleExistingConditionV3 = @"
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
                  "equals": "$($equalsValueTY)"
                }
              ]
              
          }
      ]
  }
"@

#mut RG & Mut RGTY
$AzLogAlertRuleExistingConditionV4 = @"
{
    "allOf": [
        {
            "field": "category",
            "equals": "ResourceHealth"
        },
        {
            "anyOf": 
            $AzLogAlertRuleExistingConditionResourceGroup
        },
        {
            "anyOf": 
            $AzLogAlertRuleExistingConditionResourceType
        }
    ]
}
"@

if ($resourceGroupCount -eq "1" -and $resourceTyCount -ne "1") {
  $UPAzLogAlertRuleExistingCondition = $AzLogAlertRuleExistingConditionV1
 
}elseif ($resourceGroupCount -ne "1" -and $resourceTyCount -eq "1") {
  $UPAzLogAlertRuleExistingCondition = $AzLogAlertRuleExistingConditionV2
}elseif ($resourceGroupCount -eq "1" -and $resourceTyCount -eq "1") {
      $UPAzLogAlertRuleExistingCondition = $AzLogAlertRuleExistingConditionv3
} else {
  $UPAzLogAlertRuleExistingCondition = $AzLogAlertRuleExistingConditionV4
}
        $AzLogAlertRuleExistingActions = $AzLogAlertRuleeachLogAlert.properties.actions | ConvertTo-Json
        $AzLogAlertRuleExistingDescription = $AzLogAlertRuleeachLogAlert.properties.description | ConvertTo-Json

      $BodyAzLogAlertRule = @"
{
    "id": $AzLogAlertRuleExistingId,
    "name": $AzLogAlertRuleExistingName,
    "type": "Microsoft.Insights/ActivityLogAlerts",
    "location": "global",
    "tags": $AzLogAlertRuleExistingTags,
    "properties": {
        "scopes": $AzLogAlertRuleExistinScopesv2,
        "condition": $UPAzLogAlertRuleExistingCondition,
        "actions": $AzLogAlertRuleExistingActions,
        "enabled": true,
        "description": $AzLogAlertRuleExistingDescription
    }
}
"@

      
      $RGAlertPUT= Invoke-RestMethod -Uri $RGhealthURI -Method put   -Headers $header  -Body $BodyAzLogAlertRule
      $RGScopeUPdate = $RGAlertPUT.properties.condition.allOf.anyof | Where-Object { $_.field -eq "resourceGroup" } |ConvertTo-Json -Depth 10
      write-output $RGScopeUPdate
      start-sleep -s 5
      }else {
        Write-Output "Resource Group neme $($resourceGroupRG) does exist in the alert scope "
    } 
  
   
      
        
    
          
