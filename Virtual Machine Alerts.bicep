param vmAlertProcessingRuleScope string = 'VF-CloudMonitoring'
param vmlocations string = 'uksouth'
param newActionGroupId string = '/subscriptions/c3323cc6-1939-4b36-8714-86504bbb8e4b/resourceGroups/vf-core-UK-resources-rg/providers/microsoft.insights/actiongroups/ vf-core-cm-notifications'
param subscriptionId string = subscription().subscriptionId
param customerRGScope string = '/subscriptions/${subscriptionId}/resourceGroups/${vmAlertProcessingRuleScope}'

 
 
// monitoring alert rule for CPU Percentage Exceeded
resource newcpuPercentageAlert 'microsoft.insights/metricAlerts@2018-03-01' = {
  name: 'vf-core-cm-vm-cpu-percentage-${vmlocations}'
  location: 'Global'
  tags: {
    DeployedBy: 'Vodafone'
    VodafoneBuildVersion: 'vf-build-v1'
    VodafoneProduct: 'Cloud Monitoring'
  }
  properties: {
    description: 'CIS VM- CPU Percentage Exceeded The Threshold'
    severity: 2
    enabled: true
    scopes: [customerRGScope]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      allOf: [
        {
          threshold: 85
          name: 'Percentage CPU'
          metricNamespace: 'microsoft.compute/virtualmachines'
          metricName: 'Percentage CPU'
          operator: 'GreaterThan'
          timeAggregation: 'Average'
          skipMetricValidation: false
          criterionType: 'StaticThresholdCriterion'
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
    }
    autoMitigate: true
    targetResourceType: 'microsoft.compute/virtualmachines'
    targetResourceRegion: vmlocations
    actions: [
      {
        actionGroupId: newActionGroupId
        webHookProperties: {}
      }
    ]
  }
}
 
// monitoring alert rule for available memory bytes
 
resource memoryBytesAlert 'microsoft.insights/metricAlerts@2018-03-01' = {
  name: 'vf-core-cm-vm-available-memory-${vmlocations}'
  location: 'Global'
  tags: {
    DeployedBy: 'Vodafone'
    VodafoneBuildVersion: 'vf-build-v1'
    VodafoneProduct: 'Cloud Monitoring'
  }
  properties: {
    description: 'Alert when available memory bytes falls below threshold'
    severity: 3
    enabled: true
    scopes: [customerRGScope]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      allOf: [
        {
          threshold: 1
          name: 'Available Memory Bytes'
          metricNamespace: 'microsoft.compute/virtualmachines'
          metricName: 'Available Memory Bytes'
          operator: 'LessThan'
          timeAggregation: 'Average'
          skipMetricValidation: false
          criterionType: 'StaticThresholdCriterion'
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
    }
    autoMitigate: true
    targetResourceType: 'microsoft.compute/virtualmachines'
    targetResourceRegion: vmlocations
    actions: [
      {
        actionGroupId: newActionGroupId
        webHookProperties: {}
      }
    ]
  }
}
 
// monitoring alert rule for consumed IOPS percentage on the data disk
 
resource diskIOPSAlert 'microsoft.insights/metricAlerts@2018-03-01' = {
  name: 'vf-core-cm-vm-data-disk-iops-consumed-percentage-${vmlocations}'
  location: 'Global'
  tags: {
    DeployedBy: 'Vodafone'
    VodafoneBuildVersion: 'vf-build-v1'
    VodafoneProduct: 'Cloud Monitoring'
  }
  properties: {
    description: 'Alert for Data Disk IOPS Consumed Percentage'
    severity: 2
    enabled: true
    scopes: [customerRGScope]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      allOf: [
        {
          threshold: 95
          name: 'Data Disk IOPS consumed Percentage'
          metricNamespace: 'microsoft.compute/virtualmachines'
          metricName: 'Data Disk IOPS consumed Percentage'
          operator: 'GreaterThan'
          timeAggregation: 'Average'
          skipMetricValidation: false
          criterionType: 'StaticThresholdCriterion'
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
    }
    autoMitigate: true
    targetResourceType: 'microsoft.compute/virtualmachines'
    targetResourceRegion: vmlocations
    actions: [
      {
        actionGroupId: newActionGroupId
        webHookProperties: {}
      }
    ]
  }
}
 
 
// monitoring alert rule for consumed IOPS percentage on the OS disk
 
resource osDiskIOPSAlert 'microsoft.insights/metricAlerts@2018-03-01' = {
  name: 'vf-core-cm-VM-os-disk-iops-consumed-percentage-${vmlocations}'
  location: 'Global'
  tags: {
    DeployedBy: 'Vodafone'
    VodafoneBuildVersion: 'vf-build-v1'
    VodafoneProduct: 'Cloud Monitoring'
  }
  properties: {
    description: 'Alert for OS Disk IOPS Consumed Percentage'
    severity: 2
    enabled: true
    scopes: [customerRGScope]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      allOf: [
        {
          threshold: 95
          name: 'OS Disk IOPS Consumed Percentage'
          metricNamespace: 'microsoft.compute/virtualmachines'
          metricName: 'OS Disk IOPS Consumed Percentage'
          operator: 'GreaterThan'
          timeAggregation: 'Average'
          skipMetricValidation: false
          criterionType: 'StaticThresholdCriterion'
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
    }
    autoMitigate: true
    targetResourceType: 'microsoft.compute/virtualmachines'
    targetResourceRegion: vmlocations
    actions: [
      {
        actionGroupId: newActionGroupId
        webHookProperties: {}
      }
    ]
  }
}
 
 
// monitoring alert rule for VM availability
 
resource vmAvailabilityAlert 'microsoft.insights/metricAlerts@2018-03-01' = {
  name: 'vf-core-cm-vm-availability-${vmlocations}'
  location: 'Global'
  tags: {
    DeployedBy: 'Vodafone'
    VodafoneBuildVersion: 'vf-build-v1'
    VodafoneProduct: 'Cloud Monitoring'
  }
  properties: {
    description: 'Alert for VM Availability'
    severity: 0
    enabled: true
    scopes: [customerRGScope]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      allOf: [
        {
          threshold: 1
          name: 'VM Availability'
          metricNamespace: 'microsoft.compute/virtualmachines'
          metricName: 'VmAvailabilityMetric'
          operator: 'LessThan'
          timeAggregation: 'Average'
          skipMetricValidation: false
          criterionType: 'StaticThresholdCriterion'
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
    }
    autoMitigate: true
    targetResourceType: 'microsoft.compute/virtualmachines'
    targetResourceRegion: vmlocations
    actions: [
      {
        actionGroupId: newActionGroupId
        webHookProperties: {}
      }
    ]
  }
}
