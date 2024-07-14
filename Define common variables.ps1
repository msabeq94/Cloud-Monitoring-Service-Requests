# Define common variables
$subscriptionID = "c3323cc6-1939-4b36-8714-86504bbb8e4b"
$rgtoRM = "VF-CloudMonitoringv4"
$AlertRG = "vf-core-UK-resources-rg"
$rgToRemove = "VF-CloudMonitoringv2"
$actionGroupName = "newag"
$VMlocation = "uksouth"

$accessToken = (Get-AzAccessToken -ResourceUrl "https://management.azure.com").Token

$header = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

# Function to remove policy assignments and definitions
function Remove-PolicyAssignmentsAndDefinitions {
    $RMScope = "/subscriptions/$($subscriptionID)/resourceGroups/$($rgtoRM)"

    $policyAssignments = Get-AzPolicyAssignment  -scope $RMScope 

    foreach ($policyAssignment in $policyAssignments) {
        Remove-AzPolicyAssignment -id $policyAssignment.id  -Force
        Write-Output "Removed policy assignment: $($policyAssignment.Name)"
    }

    $policyDefinitions = get-AzPolicyDefinition | Where-Object { $_.Name -like "vf-core-cm-*-$rgtoRM"}
    foreach ($policyDefinition in $policyDefinitions) {
        Remove-AzPolicyDefinition -Name $policyDefinition.name -Force
        Write-Output "Removed policy Definition: $($policyDefinition.Name)"
    }
}

# Function to update activity log alerts
function Update-ActivityLogAlerts {

    
$existingActivityLogAlerts = Invoke-RestMethod -Method Get -Headers $header -Uri $uri #| ConvertTo-Json -Depth 20
foreach ($ActivityLogAlerts in $existingActivityLogAlerts.value) {

    $alertId = $ActivityLogAlerts.id
    $alertName = $ActivityLogAlerts.name
    $updateUri = "https://management.azure.com$($alertId)?api-version=2017-04-01"
    $eachLogAlert = Invoke-RestMethod -Method Get -Headers $header -Uri $updateUri
    # Get detailed properties of the current Activity Log Alert
    #$ActivityLogAlerts = Invoke-RestMethod -Method Get -Headers $header -Uri $uri  | ConvertTo-Json
    $updatedScopes = $($eachLogAlert).properties.scopes | Where-Object { $_ -ne $RMScope } | Select-Object -Unique
    $existingcondition = $($eachLogAlert).properties.condition | ConvertTo-Json
    $existingcactions = $($eachLogAlert).properties.actions | ConvertTo-Json
    $existingdescription = $($eachLogAlert).properties.description | ConvertTo-Json
    $existintags = $($eachLogAlert).tags | ConvertTo-Json
    $existinname = $($eachLogAlert).name | ConvertTo-Json
    $existinid = $($eachLogAlert).id | ConvertTo-Json

    # Correctly format scopes based on their count
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
    $update = Invoke-RestMethod -Uri $updateUri -Method put -Headers $header -Body $body
    Start-Sleep -Milliseconds 750
    $getscop = Invoke-RestMethod -Uri $updateUri -Method Get -Headers $header
    $RMScopeout = $($getscop).properties.scopes | ConvertTo-Json
    Write-Output "$alertName new scope $RMScopeout"
}

}

# Function to update metric alert rules
function Update-MetricAlertRules {
    
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
}

# Call the functions
Remove-PolicyAssignmentsAndDefinitions
Update-ActivityLogAlerts
Update-MetricAlertRules