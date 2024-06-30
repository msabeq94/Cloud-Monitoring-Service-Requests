$accessToken = (Get-AzAccessToken -ResourceUrl "https://management.azure.com").Token

$header = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}
# Define common variables
$subscriptionID =  Read-Host "Enter the subscription ID"
$alertResourceGroup = Read-Host  "Enter the Resource group of the alerts"
$newResourceGroupPathName  =  Read-Host "Enter the new Resource group name to monitor"
$actionGroupName= Read-Host "Enter the Action Group name"
$vmLocation =  Read-Host "Enter the VMs location to monitor"



$newResourceGroupPath = "/subscriptions/$subscriptionID/resourceGroups/$newResourceGroupPathName "
$URI_MetricAlert = "https://management.azure.com/subscriptions/$($subscriptionID)/resourceGroups/$($alertResourceGroup)/providers/Microsoft.Insights/metricalerts?api-version=2018-03-01"
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
