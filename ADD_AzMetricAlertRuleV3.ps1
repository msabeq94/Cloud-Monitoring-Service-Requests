$accessToken = (Get-AzAccessToken -ResourceUrl "https://management.azure.com").Token

$header = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}
# Define common variables
$subscriptionID = Read-Host "Enter the subscription ID"
$AlertRG = Read-Host "Enter the Resource group of the alerts"
$rgtoAdd = Read-Host "Enter the new Resource group name to monitor"
$actionGroupName = Read-Host "Enter the Action Group name"
$VMlocation = Read-Host "Enter the VMs location to monitor"



$newResourceGroup = "/subscriptions/$subscriptionID/resourceGroups/$rgtoAdd"

$existingAlert = Get-AzMetricAlertRuleV2 -ResourceGroupName $AlertRG | Where-Object { $_.Name -like "*-$VMlocation" }

if (-not $existingAlert) {
    $jsonFilePaths = @(
        "~/vf-core-cm-vm-data-disk-iops-consumed-percentage.json",
        "~/vf-core-cm-vm-availability.json",
        "~/vf-core-cm-vm-available-memory.json",
        "~/vf-core-cm-VM-os-disk-iops-consumed-percentage.json",
        "~/vf-core-cm-vm-cpu-percentage.json"
    )
    
    $uriBase = "https://management.azure.com/subscriptions/$($subscriptionID)/resourceGroups/$($AlertRG)/providers/Microsoft.Insights/metricalerts"
    $apiVersion = "?api-version=2018-03-01"
    $alertNames = @(
        "vf-core-cm-vm-data-disk-iops-consumed-percentage-$($VMlocation)",
        "vf-core-cm-vm-availability-$($VMlocation)",
        "vf-core-cm-vm-available-memory-$($VMlocation)",
        "vf-core-cm-VM-os-disk-iops-consumed-percentage-$($VMlocation)",
        "vf-core-cm-vm-cpu-percentage-$($VMlocation)"
    )

    for ($i = 0; $i -lt $jsonFilePaths.Length; $i++) {
        $jsonFilePath = $jsonFilePaths[$i]
        $alertName = $alertNames[$i]

        $jsonContent = Get-Content -Path $jsonFilePath -Raw
        $modifiedJsonContent = $jsonContent `
            -replace '\$subscriptionID', $subscriptionID `
            -replace '\$AlertRG', $AlertRG `
            -replace '\$VMlocation', $VMlocation `
            -replace '\$newScope', $newResourceGroup `
            -replace '\$actionGroupName', $actionGroupName

        $uriMetric = "$uriBase/$alertName$apiVersion"
        Invoke-RestMethod -Uri $uriMetric -Method Put -Headers $header -Body $modifiedJsonContent
    }
} else {
    $AllMatricURI = "https://management.azure.com/subscriptions/$($subscriptionID)/resourceGroups/$($AlertRG)/providers/Microsoft.Insights/metricalerts?api-version=2018-03-01"
    $existingmetricalerts = Invoke-RestMethod -Uri $AllMatricURI -Method get -Headers $header

    foreach ($existingmetricalert in $existingmetricalerts.value) {
        $MalertId = $($existingmetricalert).id
        $MalertName = $($existingmetricalert).name
        $oneuMatricuri = "https://management.azure.com$($MalertId)?api-version=2018-03-01"
        $eachMatric = Invoke-RestMethod -Method Get -Headers $header -Uri $oneuMatricuri
        $Mlocation = $($eachMatric).location | ConvertTo-Json
        $Mcriteria = $($eachMatric).properties.criteria | ConvertTo-Json
        $Mscopes = $($eachMatric).properties.scopes + $newResourceGroup | ConvertTo-Json
        $MevaluationFrequency = $($eachMatric).properties.evaluationFrequency | ConvertTo-Json
        $Mseverity = $($eachMatric).properties.severity | ConvertTo-Json
        $MwindowSize = $($eachMatric).properties.windowSize | ConvertTo-Json
        $mtargetResourceType = $($eachMatric).properties.targetResourceType | ConvertTo-Json
        $MtargetResourceRegion = $($eachMatric).properties.targetResourceRegion | ConvertTo-Json
        $Mtargetaction = @"
[
    {
        "actionGroupId": "/subscriptions/$subscriptionID/resourceGroups/$AlertRG/providers/microsoft.insights/actiongroups/$actionGroupName",
        "webHookProperties": {}
    }
]
"@


        # Create the body with proper JSON formatting
        $bodyMatricUP = @"
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

       $Matupdate = Invoke-RestMethod -Uri $oneuMatricuri -Method put -Headers $header -Body $bodyMatricUP
        $MetricsnewScopeout = $($Matupdate).properties.scopes | ConvertTo-Json
Write-Output "$MalertName new scope $MetricsnewScopeout"
    }
}
