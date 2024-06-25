//param location string

param allAlertaScope string = 'VF-CloudMonitoring'
//param resourceGroupname string
//param subscriptionId string
param newActionGroupId string = '/subscriptions/c3323cc6-1939-4b36-8714-86504bbb8e4b/resourceGroups/vf-core-UK-resources-rg/providers/microsoft.insights/actiongroups/ vf-core-cm-notifications'

// param vmlocations array
// param deploymentRG string 
param subscriptionId string = subscription().subscriptionId
param alertProcessingRuleScope string = '/subscriptions/${subscriptionId}/resourceGroups/${allAlertaScope}'


// resource newActionGroup 'Microsoft.Insights/actionGroups@2022-06-01' = {
//   name: 'vf-core-cm-monitoring-notifications'
//   location: 'Global'
//   tags: {
//     DeployedBy: 'Vodafone'
//     VodafoneBuildVersion: 'vf-build-v1'
//     VodafoneProduct: 'Cloud Monitoring'
//   }
//   properties: {
//     emailReceivers: [for item in emailNotification: {
//       name: 'emailReceivers-${uniqueString(item)}'
//       emailAddress: item
//       useCommonAlertSchema: true
//     }]
//     groupShortName: actionGroupShortName
//     enabled: true
//   }
// }

// module monitoringAlertRulesx 'Virtual Machine Alerts.bicep' = [for loc in vmlocations: {
//   scope:resourceGroup(deploymentRG)
//   name: 'vmMonitoringAlertRules-${loc}'  
//   params: {
//     vmlocation: loc
//     vmAlertProcessingRuleScope: allAlertaScope
//     newActionGroupId: newActionGroupId 
  
//   }

// }]



// // Resource Health Alert Rules
// module resourceHealthAlertRules 'resourceHealthAlert.bicep' = {
//   scope:resourceGroup(deploymentRG)
//   name: 'resourceHealthAlertRules'  
//   params: {
//     //location: resourceGroup.location
//     //vmlocations: mLocation
//     allAlertaScope: allAlertaScope
//     newActionGroupId: newActionGroupId 
//     //emailNotification: emailNotification
//     deploymentRG: deploymentRG
//     //customerRG: customerRG
//     //resourceGroupname: resourceGroup.name
//     //subscriptionId: subscription().id
//   }

// }





// monitoring alert rule for delete virtual machine

resource vmDeleteAlert 'microsoft.insights/activitylogalerts@2020-10-01' = {
  name: 'vf-core-cm-vm-deleted'
  location: 'global'
  tags: {
    DeployedBy: 'Vodafone'
    VodafoneBuildVersion: 'vf-build-v1'
    VodafoneProduct: 'Cloud Monitoring'
  }
  properties: {
    scopes: [alertProcessingRuleScope]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'resourceType'
          equals: 'microsoft.compute/virtualmachines'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.Compute/virtualMachines/delete'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: newActionGroupId 
          webhookProperties: {}
        }
      ]
    }
    enabled: true
  }
}

// monitoring alert rule for Power Off virtual machine

resource vmPowerOffAlert 'microsoft.insights/activitylogalerts@2020-10-01' = {
  name: 'vf-core-cm-vm-powerOff'
  location: 'global'
  tags: {
    DeployedBy: 'Vodafone'
    VodafoneBuildVersion: 'vf-build-v1'
    VodafoneProduct: 'Cloud Monitoring'
  }
  properties: {
    scopes: [alertProcessingRuleScope]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'resourceType'
          equals: 'microsoft.compute/virtualmachines'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.Compute/virtualMachines/powerOff/action'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: newActionGroupId 
          webhookProperties: {}
        }
      ]
    }
    enabled: true
  }
}

// monitoring alert rule for delete Resource Group

resource rgDeletedAlert 'microsoft.insights/activitylogalerts@2020-10-01' = {
  name: 'vf-core-cm-resource-group-deleted'
  location: 'global'
  tags: {
    DeployedBy: 'Vodafone'
    VodafoneBuildVersion: 'vf-build-v1'
    VodafoneProduct: 'Cloud Monitoring'
  }
  properties: {
    description: 'A resource Group has been Deleted from Azure subscriptions'
    scopes: [alertProcessingRuleScope]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'resourceType'
          equals: 'microsoft.resources/subscriptions/resourcegroups'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.Resources/subscriptions/resourceGroups/delete'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: newActionGroupId 
          webhookProperties: {}
        }
      ]
    }
    enabled: true
  }
}

// monitoring alert rule for create Resource Group

resource rgCreatedAlert 'microsoft.insights/activitylogalerts@2020-10-01' = {
  name: 'vf-core-cm-resource-group-created'
  location: 'global'
  tags: {
    DeployedBy: 'Vodafone'
    VodafoneBuildVersion: 'vf-build-v1'
    VodafoneProduct: 'Cloud Monitoring'
  }
  properties: {
    description: 'A resource Group has been created in the Azure subscriptions'
    scopes: [alertProcessingRuleScope]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'resourceType'
          equals: 'microsoft.resources/subscriptions/resourcegroups'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.Resources/subscriptions/resourceGroups/write'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: newActionGroupId 
          webhookProperties: {}
        }
      ]
    }
    enabled: true
  }
}

// monitoring alert rule for delete Application Gateway

resource appGatewayDeletedAlert 'microsoft.insights/activitylogalerts@2020-10-01' = {
  name: 'vf-core-cm-application-gw-deleted'
  location: 'global'
  tags: {
    DeployedBy: 'Vodafone'
    VodafoneBuildVersion: 'vf-build-v1'
    VodafoneProduct: 'Cloud Monitoring'
  }
  properties: {
    description: 'An Application Gateway has been Deleted'
    scopes: [alertProcessingRuleScope]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'resourceType'
          equals: 'microsoft.network/applicationgateways'
        }
        {
          field: 'operationName'
          equals: 'microsoft.network/applicationgateways/delete'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: newActionGroupId 
          webhookProperties: {}
        }
      ]
    }
    enabled: true
  }
}

// monitoring alert rule for stopped Application Gateway

resource appGatewayStoppedAlert 'microsoft.insights/activitylogalerts@2020-10-01' = {
  name: 'vf-core-cm-application-gw-stopped'
  location: 'global'
  tags: {
    DeployedBy: 'Vodafone'
    VodafoneBuildVersion: 'vf-build-v1'
    VodafoneProduct: 'Cloud Monitoring'
  }
  properties: {
    description: 'An Application Gateway has been Stopped'
    scopes: [alertProcessingRuleScope]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'resourceType'
          equals: 'microsoft.network/applicationgateways'
        }
        {
          field: 'operationName'
          equals: 'microsoft.network/applicationgateways/stop/action'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: newActionGroupId 
          webhookProperties: {}
        }
      ]
    }
    enabled: true
  }
}


// monitoring alert rule for deleted Load Balancer

resource loadBalancerDeletedAlert 'microsoft.insights/activitylogalerts@2020-10-01' = {
  name: 'vf-core-cm-load-balancer-deleted'
  location: 'global'
  tags: {
    DeployedBy: 'Vodafone'
    VodafoneBuildVersion: 'vf-build-v1'
    VodafoneProduct: 'Cloud Monitoring'
  }
  properties: {
    description: 'Load Balancer has been Deleted '
    scopes: [alertProcessingRuleScope]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'resourceType'
          equals: 'Microsoft.Network/loadBalancers'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.Network/loadBalancers/delete'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: newActionGroupId 
          webhookProperties: {}
        }
      ]
    }
    enabled: true
  }
}

// monitoring alert rule for deleted Virutual Network

resource virtualNetworkDeletedAlert 'microsoft.insights/activitylogalerts@2020-10-01' = {
  name: 'vf-core-cm-virtual-network-deleted'
  location: 'global'
  tags: {
    DeployedBy: 'Vodafone'
    VodafoneBuildVersion: 'vf-build-v1'
    VodafoneProduct: 'Cloud Monitoring'
  }
  properties: {
    description: 'A Virtual Network has been Deleted'
    scopes: [alertProcessingRuleScope]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'resourceType'
          equals: 'Microsoft.Network/virtualNetworks'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.Network/virtualNetworks/delete'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: newActionGroupId 
          webhookProperties: {}
        }
      ]
    }
    enabled: true
  }
}

// monitoring alert rule for deleted MySQL Server 

resource mySQLServerDeletedAlert 'microsoft.insights/activitylogalerts@2020-10-01' = {
  name: 'vf-core-cm-MySQL-flexible-server-deleted'
  location: 'global'
  tags: {
    DeployedBy: 'Vodafone'
    VodafoneBuildVersion: 'vf-build-v1'
    VodafoneProduct: 'Cloud Monitoring'
  }
  properties: {
    description: 'An Azure MySQL Flexible Server Database has been Deleted'
    scopes: [alertProcessingRuleScope]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'resourceType'
          equals: 'Microsoft.DBForMySQL/servers'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.DBForMySQL/servers/delete'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: newActionGroupId 
          webhookProperties: {}
        }
      ]
    }
    enabled: true
  }
}

// monitoring alert rule for Failed Over MySQL Server 

resource mySQLServerFailedOverAlert 'microsoft.insights/activitylogalerts@2020-10-01' = {
  name: 'vf-core-cm-MySQL-flexible-server-failover'
  location: 'global'
  tags: {
    DeployedBy: 'Vodafone'
    VodafoneBuildVersion: 'vf-build-v1'
    VodafoneProduct: 'Cloud Monitoring'
  }
  properties: {
    description: 'An Azure MySQL Flexible Server Database has Failed'
    scopes: [alertProcessingRuleScope]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'resourceType'
          equals: 'Microsoft.DBForMySQL/servers'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.DBForMySQL/servers/stop/action'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: newActionGroupId 
          webhookProperties: {}
        }
      ]
    }
    enabled: true
  }
}

// monitoring alert rule for Deleted PostgreSQL 

resource postgreSQLDeletedAlert 'microsoft.insights/activitylogalerts@2020-10-01' = {
  name: 'vf-core-cm-PostgreSQL-flexible-server-deleted'
  location: 'global'
  tags: {
    DeployedBy: 'Vodafone'
    VodafoneBuildVersion: 'vf-build-v1'
    VodafoneProduct: 'Cloud Monitoring'
  }
  properties: {
    description: 'An Azure PostgreSQL Flexible Server Database has been Deleted'
    scopes: [alertProcessingRuleScope]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'resourceType'
          equals: 'Microsoft.DBForPostgreSQL/servers'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.DBForPostgreSQL/servers/delete'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: newActionGroupId 
          webhookProperties: {}
        }
      ]
    }
    enabled: true
  }
}


// monitoring alert rule for Deleted SQL Server 

resource azureSQLServerDeletedAlert 'microsoft.insights/activitylogalerts@2020-10-01' = {
  name: 'vf-core-cm-SQL-server-deleted'
  location: 'global'
  tags: {
    DeployedBy: 'Vodafone'
    VodafoneBuildVersion: 'vf-build-v1'
    VodafoneProduct: 'Cloud Monitoring'
  }
  properties: {
    description: 'An Azure SQL Database has been Deleted'
    scopes: [alertProcessingRuleScope]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'resourceType'
          equals: 'Microsoft.Sql/servers/databases'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.Sql/servers/databases/delete'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: newActionGroupId 
          webhookProperties: {}
        }
      ]
    }
    enabled: true
  }
}

// monitoring alert rule for Failed Over SQL Server 

resource azureSQLServerFailedOverAlert 'microsoft.insights/activitylogalerts@2020-10-01' = {
  name: 'vf-core-cm-SQL-server-issue-failover'
  location: 'global'
  tags: {
    DeployedBy: 'Vodafone'
    VodafoneBuildVersion: 'vf-build-v1'
    VodafoneProduct: 'Cloud Monitoring'
  }
  properties: {
    description: 'An Azure SQL Database has failed.'
    scopes: [alertProcessingRuleScope]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'resourceType'
          equals: 'Microsoft.Sql/servers/databases'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.Sql/servers/databases/failover/action'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: newActionGroupId 
          webhookProperties: {}
        }
      ]
    }
    enabled: true
  }
}


// monitoring alert rule for Deleted Storage Account 

resource storageAccountDeletedAlert 'microsoft.insights/activitylogalerts@2020-10-01' = {
  name: 'vf-core-cm-storage-account-deleted'
  location: 'global'
  tags: {
    DeployedBy: 'Vodafone'
    VodafoneBuildVersion: 'vf-build-v1'
    VodafoneProduct: 'Cloud Monitoring'
  }
  properties: {
    description: 'A Storage Account has been Deleted'
    scopes: [alertProcessingRuleScope]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'resourceType'
          equals: 'Microsoft.Storage/storageAccounts'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.Storage/storageAccounts/delete'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: newActionGroupId 
          webhookProperties: {}
        }
      ]
    }
    enabled: true
  }
}

// monitoring alert rule for Failed Storage Account 

resource storageAccountFailedAlert 'microsoft.insights/activitylogalerts@2020-10-01' = {
  name: 'vf-core-cm-storage-account-failover'
  location: 'global'
  tags: {
    DeployedBy: 'Vodafone'
    VodafoneBuildVersion: 'vf-build-v1'
    VodafoneProduct: 'Cloud Monitoring'
  }
  properties: {
    description: 'Storage Account failover occurred'
    scopes: [alertProcessingRuleScope]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'resourceType'
          equals: 'Microsoft.Storage/storageAccounts'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.Storage/storageAccounts/failover/action'
        }
      ]

    }
    actions: {
      actionGroups: [
        {
          actionGroupId: newActionGroupId 
          webhookProperties: {}
        }
      ]
    }
    enabled: true
  }
}


// monitoring alert rule for Deleted N/w Security Group 

resource networkSecurityGroupDeletedAlert 'microsoft.insights/activitylogalerts@2020-10-01' = {
  name: 'vf-core-cm-network-security-group-deleted'
  location: 'global'
  tags: {
    DeployedBy: 'Vodafone'
    VodafoneBuildVersion: 'vf-build-v1'
    VodafoneProduct: 'Cloud Monitoring'
  }
  properties: {
    description: 'Network Security Group has been Deleted'
    scopes: [alertProcessingRuleScope]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'resourceType'
          equals: 'Microsoft.Network/networkSecurityGroups'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.Network/networkSecurityGroups/delete'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: newActionGroupId 
          webhookProperties: {}
        }
      ]
    }
    enabled: true
  }
}
