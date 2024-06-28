
$accessToken = (Get-AzAccessToken -ResourceUrl "https://management.azure.com").Token

$header = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}
# Define common variables
$subscriptionID = Read-Host "Enter the subscription ID"
$AlertRG = Read-Host "Enter the Resource group of the alerts"
$rgtoAdd = Read-Host "Enter the new Resource group name to monitor"
$actionGroupName = Read-Host "Enter the Action Grpup name"
$VMlocation = Read-Host "enter the VMs location to monitor"


$ActionGroupId = (get-azactiongroup -ResourceGroupName $AlertRG  -name $actionGroupName).id


$newResourceGroup = "/subscriptions/$subscriptionID/resourceGroups/$rgtoAdd"
$EvaluationFrequency = "0:5"
$WindowSize = "0:15"
$TimeAggregation = 'Average'
$MetricNamespace = "microsoft.compute/virtualmachines"



# Debug output to verify variables
Write-Output "Subscription ID: $subscriptionID"
Write-Output "Alert Resource Group: $AlertRG"
Write-Output "New Resource Group to Monitor: $rgtoAdd"
Write-Output "Action Group Name: $actionGroupName"
Write-Output "VM Location: $VMlocation"
#############################################################################################################

# Define alerts
$MetricAlertV2 = @(
    @{
        Name = "vf-core-cm-vm-availability-$($VMlocation)"
        Description = "Alert for VM Availability"
        Severity = 0
        Scope = "/subscriptions/$subscriptionID/resourceGroups/$rgtoAdd"
        MetricName = "VmAvailabilityMetric"
        Threshold = 1
        Operator = "LessThan"
        CriterionType = "StaticThresholdCriterion"
    },
    @{
        Name = "vf-core-cm-vm-available-memory-$($VMlocation)"
        Description = "Alert when available memory bytes falls below threshold"
        Severity = 3
        Scope = "/subscriptions/$subscriptionID/resourceGroups/$rgtoAdd"
        MetricName = "Available Memory Bytes"
        Threshold = 1
        Operator = "LessThan"
        CriterionType = "StaticThresholdCriterion"
    },
    @{
        Name = "vf-core-cm-vm-cpu-percentage-$($VMlocation)"
        Description = "CIS VM- CPU Percentage Exceeded The Threshold"
        Severity = 2
        Scope = "/subscriptions/$subscriptionID/resourceGroups/$rgtoAdd"
        MetricName = "Percentage CPU"
        Threshold = 85
        Operator = "GreaterThan"
        CriterionType = "StaticThresholdCriterion"
    },
    @{
        Name = "vf-core-cm-vm-data-disk-iops-consumed-percentage-$($VMlocation)"
        Description = "Alert for Data Disk IOPS Consumed Percentage"
        Severity = 2
        Scope = "/subscriptions/$subscriptionID/resourceGroups/$rgtoAdd"
        MetricName = "Data Disk IOPS consumed Percentage"
        Threshold = 95
        Operator = "GreaterThan"
        CriterionType = "StaticThresholdCriterion"
    },
    @{
        Name = "vf-core-cm-VM-os-disk-iops-consumed-percentage-$($VMlocation)"
        Description = "Alert for OS Disk IOPS Consumed Percentage"
        Severity = 2
        Scope = "/subscriptions/$subscriptionID/resourceGroups/$rgtoAdd"
        MetricName = "OS Disk IOPS Consumed Percentage"
        Threshold = 95
        Operator = "GreaterThan"
        CriterionType = "StaticThresholdCriterion"
    }
)

# Create or update alerts
foreach ($ruleMatric in $MetricAlertV2) {
    
    $existingAlert = Get-AzMetricAlertRuleV2 -ResourceGroupName $AlertRG | Where-Object { $_.Name -eq $ruleMatric.Name }
    
    if (-not $existingAlert) {
        # Create new alert
       # Write-Output "Creating alert: $($ruleMatric.Name)"
        $criteria = New-AzMetricAlertRuleV2Criteria -MetricName $ruleMatric.MetricName -Operator $ruleMatric.Operator -Threshold $ruleMatric.Threshold -TimeAggregation $TimeAggregation -MetricNamespace $MetricNamespace 
       
        $IdUri= (Add-AzMetricAlertRuleV2 -ResourceGroupName $AlertRG -Name $ruleMatric.Name -Description $ruleMatric.Description -Severity $ruleMatric.Severity  -Scope $ruleMatric.Scope -EvaluationFrequency $EvaluationFrequency -WindowSize $WindowSize -Criteria $criteria -TargetResourceRegion $VMlocation -TargetResourceType  $MetricNamespace -ActionGroupId $ActionGroupId).id #-Tags $CommonTags

        $AlertUri = "https://management.azure.com$($IdUri)/providers/Microsoft.Resources/tags/default?api-version=2021-04-01"
          $body = @{
            "properties" = @{
                "tags" = @{
                    "DeployedBy" = "Vodafone"
                    "VodafoneBuildVersion" = "vf-build-v1"
                    "VodafoneProduct" = "Cloud Monitoring"
                }
            }
        }| ConvertTo-Json
        Invoke-RestMethod -Method Put -Headers $header -Uri $AlertUri -Body $body
         #| ConvertTo-Json


    } else {
            # Update scope of the existing alert
            Write-Output "Updating scope for alert: $($ruleMatric.Name)"
            
            $currentScopes = $existingAlert.Scopes
            $newScopes = @($currentScopes + $newResourceGroup)
            Add-AzMetricAlertRuleV2 -ResourceGroupName $AlertRG -Name $existingAlert.Name -Description $existingAlert.Description -Severity $existingAlert.Severity -Scope  $newScopes -EvaluationFrequency $EvaluationFrequency -WindowSize $WindowSize  -TargetResourceRegion $existingAlert.TargetResourceRegion -TargetResourceType  $existingAlert.TargetResourceType -ActionGroupId $ActionGroupId -Criteria $existingAlert.Criteria 
            $IdUri= (Add-AzMetricAlertRuleV2 -ResourceGroupName $AlertRG -Name $ruleMatric.Name -Description $ruleMatric.Description -Severity $ruleMatric.Severity  -Scope $ruleMatric.Scope -EvaluationFrequency $EvaluationFrequency -WindowSize $WindowSize -Criteria $criteria -TargetResourceRegion $VMlocation -TargetResourceType  $MetricNamespace -ActionGroupId $ActionGroupId).id #-Tags $CommonTags

        $AlertUri = "https://management.azure.com$($IdUri)/providers/Microsoft.Resources/tags/default?api-version=2021-04-01"
          $body = @{
            "properties" = @{
                "tags" = @{
                    "DeployedBy" = "Vodafone"
                    "VodafoneBuildVersion" = "vf-build-v1"
                    "VodafoneProduct" = "Cloud Monitoring"
                }
            }
        }| ConvertTo-Json
        Invoke-RestMethod -Method Put -Headers $header -Uri $AlertUri -Body $body
        
}
}