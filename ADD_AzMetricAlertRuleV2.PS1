# Define common variables
$subscriptionID = Read-Host "Enter the subscription ID"
$AlertRG = Read-Host "Enter the Resource group of the alerts"
$rgtoAdd = Read-Host "Enter the new Resource group name to monitor"
$actionGroupName =  Read-Host "Enter the Action Grpup name"
$VMlocation = Read-Host "enter the VMs location to monitor"

$ActionGroupId = "/subscriptions/$subscriptionID/resourceGroups/$AlertRG/providers/microsoft.insights/actiongroups/$actionGroupName"
$newResourceGroup = "/subscriptions/$subscriptionID/resourceGroups/$rgtoAdd"
$AlertLocation= "Global"
$EvaluationFrequency = "0:5"
$WindowSize = "0:15"
$TimeAggregation = 'Average'
$MetricNamespace = "microsoft.compute/virtualmachines"


$CommonTags = @{
    "DeployedBy" = "Vodafone"
    "VodafoneBuildVersion" = "vf-build-v1"
    "VodafoneProduct" = "Cloud Monitoring"
}

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
        Write-Output "Creating alert: $($ruleMatric.Name)"
        $criteria = New-AzMetricAlertRuleV2Criteria -MetricName $ruleMatric.MetricName -Operator $ruleMatric.Operator -Threshold $ruleMatric.Threshold -TimeAggregation $TimeAggregation -MetricNamespace $MetricNamespace 
        Add-AzMetricAlertRuleV2 -ResourceGroupName $AlertRG -Name $ruleMatric.Name -Description $ruleMatric.Description -Severity $ruleMatric.Severity  -Scope $ruleMatric.Scope -EvaluationFrequency $EvaluationFrequency -WindowSize $WindowSize -Criteria $criteria -ActionGroupId  $ActionGroupId -TargetResourceRegion $VMlocation -TargetResourceType  $MetricNamespace  -Tag $CommonTags
    } else {
            # Update scope of the existing alert
            Write-Output "Updating scope for alert: $($ruleMatric.Name)"
            $existingAlert.Scopes += $newResourceGroup
            Set-AzMetricAlertRuleV2 -ResourceGroupName $AlertRG -Name $existingAlert.Name -Scope $existingAlert.Scopes
        # # Update existing alert
        # Write-Output "Updating alert: $($ruleMatric.Name)"
        # $currentScopes = $existingAlert.Scopes
        # $newScopes = @($currentScopes + $newResourceGroup)
        # $tags = $ruleMatric.tags | ConvertTo-Json
        # Add-AzMetricAlertRuleV2 -ResourceGroupName $AlertRG -Name $ruleMatric.Name -Description $ruleMatric.Description -Severity $ruleMatric.Severity  -Scope $newScopes  -EvaluationFrequency $EvaluationFrequency -WindowSize $WindowSize  -ActionGroupId  $ActionGroupId -TargetResourceRegion $VMlocation -TargetResourceType  $MetricNamespace  
}
}