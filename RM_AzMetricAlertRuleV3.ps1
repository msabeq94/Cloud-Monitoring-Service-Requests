# Define common variables
$subscriptionID = "c3323cc6-1939-4b36-8714-86504bbb8e4b" #Read-Host "Enter the subscription ID"
$AlertRG = "vf-core-UK-resources-rg"#Read-Host  "Enter the Resource group of the alerts"
$rgToRemove = "VF-CloudMonitoringv2" #Read-Host "Enter the Resource group name to remove from alerts"
$actionGroupName ="newag" # Read-Host "Enter the Action Group name"
$VMlocation = "uksouth"# Read-Host "Enter the VMs location to monitor"

$accessToken = (Get-AzAccessToken -ResourceUrl "https://management.azure.com").Token

$header = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

#$subscriptionID = Read-Host "Enter the subscription ID"

#$alertRulesLocation = Read-Host "Enter the Resource group of the alerts"
$resourceGroupToRemove = "/subscriptions/$($subscriptionID)/resourceGroups/$($rgToRemove)"
# Debug output to verify variables
Write-Output "Subscription ID: $subscriptionID"
Write-Output "Alert Resource Group: $AlertRG"
Write-Output "Resource group name to remove: $rgToRemove"
Write-Output "VM Location: $VMlocation"
# Get all metric alert rules in the specified alert rules resource group that start with "vf-core-cm-"
#$alertRules = Get-AzMetricAlertRuleV2 -ResourceGroupName $AlertRG | Where-Object { $_.Name -like "vf-core-cm-*-$VMlocation" }

$AAllMatricURI = "https://management.azure.com/subscriptions/$($subscriptionID)/resourceGroups/$($AlertRG)/providers/Microsoft.Insights/metricalerts?api-version=2018-03-01"
$existingmetricalerts = Invoke-RestMethod -Uri $AAllMatricURI -Method get -Headers $header 
  $existingmetricalertslocations = $existingmetricalerts.value | Where-Object { $_.Name -like "vf-core-cm-*-$VMlocation"}


foreach ($existingmetricalertslocation in $existingmetricalertslocations ) {
    # Retrieve the current scopes of the alert rule
    $RMalertId = $($existingmetricalertslocation).id
    $RMalertName = $($existingmetricalertslocation).name
    $currentScopes = $existingmetricalertslocation.properties.Scopes
    $RoneuMatricuri = "https://management.azure.com$($RMalertId)?api-version=2018-03-01"
    if ($currentScopes -contains $resourceGroupToRemove) {
        if ($currentScopes.Count -eq 1) {
            # Remove the entire alert rule if it only contains the resource group to be removed
            Invoke-RestMethod -Uri $RoneuMatricuri -Method Delete -Headers $header 
            Write-Output " Alert $RMalertName deleted "
        } else {
            # Remove the resource group from the scopes
            $newScop = $currentScopes  | Where-Object { $_ -ne $resourceGroupToRemove }  | Select-Object -Unique
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
        "actionGroupId": "/subscriptions/$subscriptionID/resourceGroups/$AlertRG/providers/microsoft.insights/actiongroups/$actionGroupName",
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
        Write-Output "$RMalertName new scope $MetricsnewScopeout"
    }

    } else {
        Write-Output "Alert rule $($existingmetricalertslocation.Name) does not include Resource Group $($rgToRemove)"
    }

 
}




#$existingmetricalerts.value | Where-Object { $_.Name -like "vf-core-cm-*-$VMlocation" }