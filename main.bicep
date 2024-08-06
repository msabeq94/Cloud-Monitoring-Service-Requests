// param pcrRG string 
// param location string = deployment().location
// param pcrCustomer string
param polDefStorageAccLogAnalyticsName string = 'vf-core-cm-diag-setg-for-storage-acc-to-log-anl'
param polDefBlobSerLogAnalyticsName string = 'vf-core-cm-diag-setg-for-blob-ser-to-log-anl'
param polDefFileSerLogAnalyticsName string = 'vf-core-cm-diag-setg-for-file-ser-to-log-anl'
param polDefSqlDbLogAnalyticsName string = 'vf-core-cm-diag-setg-for-SQL-db-to-log-anl'
param polDefPostgresSQLLogAnalyticsName string = 'vf-core-cm-diag-setg-for-postgreSQL-to-log-anl'
param polDefMySQLdbLogAnalyticsName string = 'vf-core-cm-diag-setg-for-mySQL-db-to-log-anl'
param polDefAppGwLogAnalyticsName string = 'vf-core-cm-diag-setg-for-app-gw-to-log-anl'
param polDefTagResourcesName string = 'vf-core-cm-tag-resources'
targetScope = 'subscription'
// param retentionInDays int
// param mLocation array
// param emailNotification array
// param customerRG array
// //param appInsightRG string
//param appInsightLocation string

// // Check if the resource group exists 
// //var existingResourceGroup = contains(listResourceGroups(), rg => rg.name == resourceGroupName) 

// resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = if (pcrCustomer == 'No') { 
//   name: pcrRG 
//   location: location 

// } 



// // Log Analytics Workspace

// module logAnalyticsWs 'logAnalyticsWs.bicep' = {
//   scope:resourceGroup
//   name: 'logAnalyticsWs'  
//   params: {
//     location: resourceGroup.location
//     workspaceExists: false
//     retentionInDays: retentionInDays
//   }

// }


// // Managed User Identity

// module managedUserIdty 'managedUserIdty.bicep' = {
//   scope:resourceGroup
//   name: 'managedUserIdty'  
//   params: {
//     location: resourceGroup.location
//   }
// }



// // All  Monitoring Alert Rules
// module monitoringAlertRules 'allMonitoringAlerts.bicep' = {
//   scope:resourceGroup
//   name: 'monitoringAlertRules'  
//   params: {
//     vmlocations: mLocation
//     allAlertaScope: customerRG
//     emailNotification: emailNotification
//     deploymentRG: pcrRG
//   }

// }



// Application Insight creation
//module applicationInsight 'appInsight.bicep' = {
//  scope:resourceGroup
//  name: 'applicationInsight'  
//  params: {
//    appInsightRG: appInsightRG
//    pcrRG: pcrRG
//    appInsightLocation: appInsightLocation
//  }
//}





// Policy Definitions start

//1 policyDefinitionName vf-core-cm-diag-setting-for-storage-account-to-log-analytics
resource polDefStorageAccLogAnalytics 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: polDefStorageAccLogAnalyticsName
  properties: {
    policyType: 'Custom' 
    mode: 'Indexed'
    description: 'This policy deploys a diagnostic setting for Storage account to send Transaction logs to the log analytics workspace'
    displayName: polDefStorageAccLogAnalyticsName
    metadata: {
      category : 'Monitoring'
    }
    parameters: {
      effect: {
        type: 'String'
        metadata: {
          displayName: 'Effect'
          description: 'Enable or disable the execution of the policy'
        }
        allowedValues: [
          'DeployIfNotExists'
          'Disabled'
        ]
        defaultValue: 'DeployIfNotExists'
      }
      diagnosticsSettingNameToUse: {
        type: 'String'
        metadata: {
          displayName: 'Setting name'
          description: 'Name of the policy for the diagnostics settings.'
        }
        defaultValue: 'setByPolicy'
      }
      logAnalytics: {
        type: 'String'
        metadata: {
          displayName: 'Log Analytics workspace'
          description: 'Select the Log Analytics workspace from dropdown list'
          strongType: 'omsWorkspace'
          assignPermissions: true
        }
      }
    }
    policyRule: {
      if: {
        field: 'type'
        equals: 'Microsoft.Storage/storageAccounts'
      }
      then: {
        effect: '[parameters(\'effect\')]'
        details: {
          type: 'Microsoft.Insights/diagnosticSettings'
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
            '/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa'
          ]
          existenceCondition: {
            field: 'Microsoft.Insights/diagnosticSettings/workspaceId'
            equals: '[parameters(\'logAnalytics\')]'
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                schema: 'http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  diagnosticsSettingNameToUse: {
                    type: 'string'
                  }
                  resourceName: {
                    type: 'string'
                  }
                  logAnalytics: {
                    type: 'string'
                  }
                  location: {
                    type: 'string'
                  }
                }
                variables: {}
                resources: [
                  {
                    type: 'Microsoft.Storage/storageAccounts/providers/diagnosticSettings'
                    apiVersion: '2017-05-01-preview'
                    name: '[concat(parameters(\'resourceName\') \'/\' \'Microsoft.Insights/\' parameters(\'diagnosticsSettingNameToUse\'))]'
                    location: '[parameters(\'location\')]'
                    dependsOn: []
                    properties: {
                      workspaceId: '[parameters(\'logAnalytics\')]'
                      metrics: [
                        {
                          category: 'Transaction'
                          enabled: true
                        }
                      ]
                    }
                  }
                ]
                outputs: {}
              }
              parameters: {
                diagnosticsSettingNameToUse: {
                  value: '[parameters(\'diagnosticsSettingNameToUse\')]'
                }
                logAnalytics: {
                  value: '[parameters(\'logAnalytics\')]'
                }
                location: {
                  value: '[field(\'location\')]'
                }
                resourceName: {
                  value: '[field(\'name\')]'
                }
              }
            }
          }
        }
      }
    }
  }
}


//2 policyDefinitionName vf-core-cm-diag-setting-for-blobservices-to-log-analytics

resource polDefBlobSerLogAnalytics 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: polDefBlobSerLogAnalyticsName
  properties: {
    policyType: 'Custom' 
    mode: 'Indexed'
    description: 'This policy deploys a diagnostic setting for Storage Account Blob services to send Transaction logs to the log analytics workspace'
    displayName: polDefBlobSerLogAnalyticsName
    metadata: {
      category : 'Monitoring'
    }
    parameters: {
      effect: {
        type: 'String'
        metadata: {
          displayName: 'Effect'
          description: 'Enable or disable the execution of the policy'
        }
        allowedValues: [
          'DeployIfNotExists'
          'Disabled'
        ]
        defaultValue: 'DeployIfNotExists'
      }
      profileName: {
        type: 'String'
        metadata: {
          displayName: 'Profile name'
          description: 'The diagnostic settings profile name.'
        }
        defaultValue: 'blobServicesDiagnosticsLogsToWorkspace'
      }
      logAnalytics: {
        type: 'String'
        metadata: {
          displayName: 'Log Analytics workspace'
          description: 'Select Log Analytics workspace from dropdown list. If this workspace is outside of the scope of the assignment you must manually grant \'Log Analytics Contributor\' permissions (or similar) to the policy assignments principal ID.'
          strongType: 'omsWorkspace'
          assignPermissions: true
        }
      }
      metricsEnabled: {
        type: 'Boolean'
        metadata: {
          displayName: 'Enable metrics'
          description: 'Whether to enable metrics stream to the Log Analytics workspace - True or False'
        }
        allowedValues: [
          true
          false
        ]
        defaultValue: true
      }
      logsEnabled: {
        type: 'Boolean'
        metadata: {
          displayName: 'Enable logs'
          description: 'Whether to enable logs stream to the Log Analytics workspace - True or False'
        }
        allowedValues: [
          true
          false
        ]
        defaultValue: true
      }
    }
    policyRule: {
      if: {
        field: 'type'
        equals: 'Microsoft.Storage/storageAccounts/blobServices'
      }
      then: {
        effect: '[parameters(\'effect\')]'
        details: {
          type: 'Microsoft.Insights/diagnosticSettings'
          name: '[parameters(\'profileName\')]'
          existenceCondition: {
            allOf: [
              {
                field: 'Microsoft.Insights/diagnosticSettings/logs.enabled'
                equals: '[parameters(\'logsEnabled\')]'
              }
              {
                field: 'Microsoft.Insights/diagnosticSettings/metrics.enabled'
                equals: '[parameters(\'metricsEnabled\')]'
              }
              {
                field: 'Microsoft.Insights/diagnosticSettings/workspaceId'
                equals: '[parameters(\'logAnalytics\')]'
              }
            ]
          }
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa'
            '/providers/microsoft.authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
          ]
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                schema: 'http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  resourceName: {
                    type: 'string'
                  }
                  location: {
                    type: 'string'
                  }
                  logAnalytics: {
                    type: 'string'
                  }
                  metricsEnabled: {
                    type: 'bool'
                  }
                  logsEnabled: {
                    type: 'bool'
                  }
                  profileName: {
                    type: 'string'
                  }
                }
                variables: {}
                resources: [
                  {
                    type: 'Microsoft.Storage/storageAccounts/blobServices/providers/diagnosticSettings'
                    apiVersion: '2021-05-01-preview'
                    name: '[concat(parameters(\'resourceName\') \'/\' \'Microsoft.Insights/\' parameters(\'profileName\'))]'
                    location: '[parameters(\'location\')]'
                    dependsOn: []
                    properties: {
                      workspaceId: '[parameters(\'logAnalytics\')]'
                      metrics: [
                        {
                          category: 'Transaction'
                          enabled: '[parameters(\'metricsEnabled\')]'
                        }
                      ]
                    }
                  }
                ]
                outputs: {}
              }
              parameters: {
                location: {
                  value: '[field(\'location\')]'
                }
                resourceName: {
                  value: '[field(\'fullName\')]'
                }
                logAnalytics: {
                  value: '[parameters(\'logAnalytics\')]'
                }
                metricsEnabled: {
                  value: '[parameters(\'metricsEnabled\')]'
                }
                logsEnabled: {
                  value: '[parameters(\'logsEnabled\')]'
                }
                profileName: {
                  value: '[parameters(\'profileName\')]'
                }
              }
            }
          }
        }
      }
    }
  }
}


//3 policyDefinitionName vf-core-cm-diag-setting-for-file-services-to-log-analytics

resource polDefFileSerLogAnalytics 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: polDefFileSerLogAnalyticsName
  properties: {
    policyType: 'Custom' 
    mode: 'Indexed'
    description: 'This policy deploys a diagnostic setting for Storage Account File services to send Transaction logs to the log analytics workspace'
    displayName: polDefFileSerLogAnalyticsName
    metadata: {
      category : 'Monitoring'
    }
    parameters: {
      effect: {
        type: 'String'
        metadata: {
          displayName: 'Effect'
          description: 'Enable or disable the execution of the policy'
        }
        allowedValues: [
          'DeployIfNotExists'
          'AuditIfNotExists'
          'Disabled'
        ]
        defaultValue: 'DeployIfNotExists'
      }
      profileName: {
        type: 'String'
        metadata: {
          displayName: 'Profile name'
          description: 'The diagnostic settings profile name.'
        }
        defaultValue: 'fileServicesDiagnosticsLogsToWorkspace'
      }
      logAnalytics: {
        type: 'String'
        metadata: {
          displayName: 'Log Analytics workspace'
          description: 'Select Log Analytics workspace from dropdown list. If this workspace is outside of the scope of the assignment you must manually.'
          strongType: 'omsWorkspace'
          assignPermissions: true
        }
      }
      metricsEnabled: {
        type: 'Boolean'
        metadata: {
          displayName: 'Enable metrics'
          description: 'Whether to enable metrics stream to the Log Analytics workspace - True or False'
        }
        allowedValues: [
          true
          false
        ]
        defaultValue: true
      }
      logsEnabled: {
        type: 'Boolean'
        metadata: {
          displayName: 'Enable logs'
          description: 'Whether to enable logs stream to the Log Analytics workspace - True or False'
        }
        allowedValues: [
          true
          false
        ]
        defaultValue: true
      }
    }
    policyRule: {
      if: {
        field: 'type'
        equals: 'Microsoft.Storage/storageAccounts/fileServices'
      }
      then: {
        effect: '[parameters(\'effect\')]'
        details: {
          type: 'Microsoft.Insights/diagnosticSettings'
          name: '[parameters(\'profileName\')]'
          existenceCondition: {
            allOf: [
              {
                field: 'Microsoft.Insights/diagnosticSettings/logs.enabled'
                equals: '[parameters(\'logsEnabled\')]'
              }
              {
                field: 'Microsoft.Insights/diagnosticSettings/metrics.enabled'
                equals: '[parameters(\'metricsEnabled\')]'
              }
              {
                field: 'Microsoft.Insights/diagnosticSettings/workspaceId'
                equals: '[parameters(\'logAnalytics\')]'
              }
            ]
          }
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa'
            '/providers/microsoft.authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
          ]
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                schema: 'http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  resourceName: {
                    type: 'string'
                  }
                  location: {
                    type: 'string'
                  }
                  logAnalytics: {
                    type: 'string'
                  }
                  metricsEnabled: {
                    type: 'bool'
                  }
                  logsEnabled: {
                    type: 'bool'
                  }
                  profileName: {
                    type: 'string'
                  }
                }
                variables: {}
                resources: [
                  {
                    type: 'Microsoft.Storage/storageAccounts/fileServices/providers/diagnosticSettings'
                    apiVersion: '2021-05-01-preview'
                    name: '[concat(parameters(\'resourceName\') \'/\' \'Microsoft.Insights/\' parameters(\'profileName\'))]'
                    location: '[parameters(\'location\')]'
                    dependsOn: []
                    properties: {
                      workspaceId: '[parameters(\'logAnalytics\')]'
                      metrics: [
                        {
                          category: 'Transaction'
                          enabled: '[parameters(\'metricsEnabled\')]'
                        }
                      ]
                    }
                  }
                ]
                outputs: {}
              }
              parameters: {
                location: {
                  value: '[field(\'location\')]'
                }
                resourceName: {
                  value: '[field(\'fullName\')]'
                }
                logAnalytics: {
                  value: '[parameters(\'logAnalytics\')]'
                }
                metricsEnabled: {
                  value: '[parameters(\'metricsEnabled\')]'
                }
                logsEnabled: {
                  value: '[parameters(\'logsEnabled\')]'
                }
                profileName: {
                  value: '[parameters(\'profileName\')]'
                }
              }
            }
          }
        }
      }
    }
  }
}


//4. policyDefinitionName vf-core-cm-diag-setting-for-SQL-db-to-log-analytics
resource polDefSqlDbLogAnalytics 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: polDefSqlDbLogAnalyticsName
  properties: {
    policyType: 'Custom' 
    mode: 'Indexed'
    description: 'This policy deploys a diagnostic setting for Microsoft SQL database to send Basic logs to the log analytics workspace'
    displayName: polDefSqlDbLogAnalyticsName
    metadata: {
      category : 'Monitoring'
    }
    parameters: {
      effect: {
        type: 'String'
        metadata: {
          displayName: 'Effect'
          description: 'Enable or disable the execution of the policy'
        }
        allowedValues: [
          'DeployIfNotExists'
          'Disabled'
        ]
        defaultValue: 'DeployIfNotExists'
      }
      diagnosticsSettingNameToUse: {
        type: 'String'
        metadata: {
          displayName: 'Setting name'
          description: 'Name of the policy for the diagnostics settings.'
        }
        defaultValue: 'setByPolicy'
      }
      logAnalytics: {
        type: 'String'
        metadata: {
          displayName: 'Log Analytics workspace'
          description: 'Select the Log Analytics workspace from dropdown list'
          strongType: 'omsWorkspace'
          assignPermissions: true
        }
      }
    }
    policyRule: {
      if: {
        field: 'type'
        equals: 'Microsoft.Sql/servers/databases'
      }
      then: {
        effect: '[parameters(\'effect\')]'
        details: {
          type: 'Microsoft.Insights/diagnosticSettings'
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
            '/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa'
          ]
          existenceCondition: {
            field: 'Microsoft.Insights/diagnosticSettings/workspaceId'
            equals: '[parameters(\'logAnalytics\')]'
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                schema: 'http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  diagnosticsSettingNameToUse: {
                    type: 'string'
                  }
                  resourceName: {
                    type: 'string'
                  }
                  logAnalytics: {
                    type: 'string'
                  }
                  location: {
                    type: 'string'
                  }
                }
                variables: {}
                resources: [
                  {
                    type: 'Microsoft.Storage/storageAccounts/providers/diagnosticSettings'
                    apiVersion: '2017-05-01-preview'
                    name: '[concat(parameters(\'resourceName\'), \'/\', \'Microsoft.Insights/\', parameters(\'diagnosticsSettingNameToUse\'))]'
                    location: '[parameters(\'location\')]'
                    dependsOn: []
                    properties: {
                      workspaceId: '[parameters(\'logAnalytics\')]'
                      metrics: [
                        {
                          category: 'Transaction'
                          enabled: true
                        }
                      ]
                    }
                  }
                ]
                outputs: {}
              }
              parameters: {
                diagnosticsSettingNameToUse: {
                  value: '[parameters(\'diagnosticsSettingNameToUse\')]'
                }
                logAnalytics: {
                  value: '[parameters(\'logAnalytics\')]'
                }
                location: {
                  value: '[field(\'location\')]'
                }
                resourceName: {
                  value: '[field(\'name\')]'
                }
              }
            }
          }
        }
      }
    }
  }
}


//5 policyDefinitionName vf-core-cm-diag-setting-for-postgreSQL-to-log-analytics

resource polDefPostgresSQLLogAnalytics 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: polDefPostgresSQLLogAnalyticsName
  properties: {
    policyType: 'Custom' 
    mode: 'Indexed'
    description: 'This policy deploys a diagnostic setting forMicrosoft Azure PostgreSQL Flexible Server database to send Basic logs to the log analytics workspace'
    displayName: polDefPostgresSQLLogAnalyticsName
    metadata: {
      category : 'Monitoring'
    }
    parameters: {
      effect: {
        type: 'String'
        metadata: {
          displayName: 'Effect'
          description: 'Enable or disable the execution of the policy'
        }
        allowedValues: [
          'DeployIfNotExists'
          'Disabled'
        ]
        defaultValue: 'DeployIfNotExists'
      }
      diagnosticsSettingNameToUse: {
        type: 'String'
        metadata: {
          displayName: 'Setting name'
          description: 'Name of the policy for the diagnostics settings.'
        }
        defaultValue: 'setByPolicy'
      }
      logAnalytics: {
        type: 'String'
        metadata: {
          displayName: 'Log Analytics workspace'
          description: 'Select the Log Analytics workspace from dropdown list'
          strongType: 'omsWorkspace'
          assignPermissions: true
        }
      }
    }
    policyRule: {
      if: {
        field: 'type'
        equals: 'Microsoft.DBforPostgreSQL/flexibleServers'
      }
      then: {
        effect: '[parameters(\'effect\')]'
        details: {
          type: 'Microsoft.Insights/diagnosticSettings'
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
            '/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa'
          ]
          existenceCondition: {
            field: 'Microsoft.Insights/diagnosticSettings/workspaceId'
            equals: '[parameters(\'logAnalytics\')]'
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                schema: 'http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  diagnosticsSettingNameToUse: {
                    type: 'string'
                  }
                  resourceName: {
                    type: 'string'
                  }
                  logAnalytics: {
                    type: 'string'
                  }
                  location: {
                    type: 'string'
                  }
                }
                variables: {}
                resources: [
                  {
                    type: 'Microsoft.DBforPostgreSQL/flexibleServers/providers/diagnosticSettingss'
                    apiVersion: '2017-05-01-preview'
                    name: '[concat(parameters(\'resourceName\'), \'/\', \'Microsoft.Insights/\', parameters(\'diagnosticsSettingNameToUse\'))]'
                    location: '[parameters(\'location\')]'
                    dependsOn: []
                    properties: {
                      workspaceId: '[parameters(\'logAnalytics\')]'
                      metrics: [
                        {
                          category: 'AllMetrics'
                          enabled: true
                        }
                      ]
                    }
                  }
                ]
                outputs: {}
              }
              parameters: {
                diagnosticsSettingNameToUse: {
                  value: '[parameters(\'diagnosticsSettingNameToUse\')]'
                }
                logAnalytics: {
                  value: '[parameters(\'logAnalytics\')]'
                }
                location: {
                  value: '[field(\'location\')]'
                }
                resourceName: {
                  value: '[field(\'name\')]'
                }
              }
            }
          }
        }
      }
    }
  }
}

//6 policyDefinitionName vf-core-cm-diag-setting-for-mySQL-db-to-log-analytics

resource polDefMySQLdbLogAnalytics 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: polDefMySQLdbLogAnalyticsName
  properties: {
    policyType: 'Custom' 
    mode: 'Indexed'
    description: 'This policy deploys a diagnostic setting for Microsoft Azure MySQL Flexible Server database to send AllMetrics logs to the log analytics workspace'
    displayName: polDefMySQLdbLogAnalyticsName    
    metadata: {
      category : 'Monitoring'
    }
    parameters: {
      effect: {
        type: 'String'
        metadata: {
          displayName: 'Effect'
          description: 'Enable or disable the execution of the policy'
        }
        allowedValues: [
          'DeployIfNotExists'
          'Disabled'
        ]
        defaultValue: 'DeployIfNotExists'
      }
      diagnosticsSettingNameToUse: {
        type: 'String'
        metadata: {
          displayName: 'Setting name'
          description: 'Name of the policy for the diagnostics settings.'
        }
        defaultValue: 'setByPolicy'
      }
      logAnalytics: {
        type: 'String'
        metadata: {
          displayName: 'Log Analytics workspace'
          description: 'Select the Log Analytics workspace from dropdown list'
          strongType: 'omsWorkspace'
          assignPermissions: true
        }
      }
    }
    policyRule: {
      if: {
        field: 'type'
        equals: 'Microsoft.DBforMySQL/flexibleServers'
      }
      then: {
        effect: '[parameters(\'effect\')]'
        details: {
          type: 'Microsoft.Insights/diagnosticSettings'
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
            '/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa'
          ]
          existenceCondition: {
            field: 'Microsoft.Insights/diagnosticSettings/workspaceId'
            equals: '[parameters(\'logAnalytics\')]'
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                schema: 'http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  diagnosticsSettingNameToUse: {
                    type: 'string'
                  }
                  resourceName: {
                    type: 'string'
                  }
                  logAnalytics: {
                    type: 'string'
                  }
                  location: {
                    type: 'string'
                  }
                }
                variables: {}
                resources: [
                  {
                    type: 'Microsoft.DBforMySQL/flexibleServers/providers/diagnosticSettings'
                    apiVersion: '2017-05-01-preview'
                    name: '[concat(parameters(\'resourceName\'), \'/\', \'Microsoft.Insights/\', parameters(\'diagnosticsSettingNameToUse\'))]'
                    location: '[parameters(\'location\')]'
                    dependsOn: []
                    properties: {
                      workspaceId: '[parameters(\'logAnalytics\')]'
                      metrics: [
                        {
                          category: 'AllMetrics'
                          enabled: true
                        }
                      ]
                    }
                  }
                ]
                outputs: {}
              }
              parameters: {
                diagnosticsSettingNameToUse: {
                  value: '[parameters(\'diagnosticsSettingNameToUse\')]'
                }
                logAnalytics: {
                  value: '[parameters(\'logAnalytics\')]'
                }
                location: {
                  value: '[field(\'location\')]'
                }
                resourceName: {
                  value: '[field(\'name\')]'
                }
              }
            }
          }
        }
      }
    }
  }
}


//7 policyDefinitionName vf-core-cm-diag-setting-for-application-gw-to-log-analytics

resource polDefAppGwLogAnalytics 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: polDefAppGwLogAnalyticsName
  properties: {
    policyType: 'Custom' 
    mode: 'Indexed'
    description: 'This policy deploys a diagnostic setting for Application Gateway to send AllMetrics logs to the log analytics workspace'
    displayName: polDefAppGwLogAnalyticsName
    metadata: {
      category : 'Monitoring'
    }
    parameters: {
      effect: {
        type: 'String'
        metadata: {
          displayName: 'Effect'
          description: 'Enable or disable the execution of the policy'
        }
        allowedValues: [
          'DeployIfNotExists'
          'Disabled'
        ]
        defaultValue: 'DeployIfNotExists'
      }
      diagnosticsSettingNameToUse: {
        type: 'String'
        metadata: {
          displayName: 'Setting name'
          description: 'Name of the policy for the diagnostics settings.'
        }
        defaultValue: 'setByPolicy'
      }
      logAnalytics: {
        type: 'String'
        metadata: {
          displayName: 'Log Analytics workspace'
          description: 'Select the Log Analytics workspace from dropdown list'
          strongType: 'omsWorkspace'
          assignPermissions: true
        }
      }
    }
    policyRule: {
      if: {
        field: 'type'
        equals: 'Microsoft.Network/applicationGateways'
      }
      then: {
        effect: '[parameters(\'effect\')]'
        details: {
          type: 'Microsoft.Insights/diagnosticSettings'
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
            '/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa'
          ]
          existenceCondition: {
            field: 'Microsoft.Insights/diagnosticSettings/workspaceId'
            equals: '[parameters(\'logAnalytics\')]'
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                schema: 'http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  diagnosticsSettingNameToUse: {
                    type: 'string'
                  }
                  resourceName: {
                    type: 'string'
                  }
                  logAnalytics: {
                    type: 'string'
                  }
                  location: {
                    type: 'string'
                  }
                }
                variables: {}
                resources: [
                  {
                    type: 'Microsoft.Network/applicationGateways/providers/diagnosticSettings'
                    apiVersion: '2017-05-01-preview'
                    name: '[concat(parameters(\'resourceName\'), \'/\', \'Microsoft.Insights/\', parameters(\'diagnosticsSettingNameToUse\'))]'
                    location: '[parameters(\'location\')]'
                    dependsOn: []
                    properties: {
                      workspaceId: '[parameters(\'logAnalytics\')]'
                      metrics: [
                        {
                          category: 'AllMetrics'
                          enabled: true
                        }
                      ]
                    }
                  }
                ]
                outputs: {}
              }
              parameters: {
                diagnosticsSettingNameToUse: {
                  value: '[parameters(\'diagnosticsSettingNameToUse\')]'
                }
                logAnalytics: {
                  value: '[parameters(\'logAnalytics\')]'
                }
                location: {
                  value: '[field(\'location\')]'
                }
                resourceName: {
                  value: '[field(\'name\')]'
                }
              }
            }
          }
        }
      }
    }
  }
}


//8 policyDefinitionName vf-core-cm-tag-resources

resource polDefTagResources 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: polDefTagResourcesName
  properties: {
    policyType: 'Custom' 
    mode: 'Indexed'
    description: 'Adds the specified tag and value when any resource missing this tag is created or updated. Existing resources can be remediated by triggering a remediation task. If the tag exists with a different value it will not be changed. Does not modify tags on resource groups.'
    displayName: polDefTagResourcesName
    metadata: {
      category : 'Monitoring'
    }
    parameters: {
      tagName: {
        type: 'String'
        metadata: {
          displayName: 'Tag Name'
          description: 'Name of the tag such as \'environment\''
        }
      }
      tagValue: {
        type: 'String'
        metadata: {
          displayName: 'Tag Value'
          description: 'Value of the tag such as \'production\''
        }
      }
    }
    policyRule: {
      if: {
        anyof: [
          {
            field: 'type'
            equals: 'Microsoft.Storage/storageAccounts'
          }
          {
            field: 'type'
            equals: 'Microsoft.Compute/VirtualMachines'
          }
          {
            field: 'type'
            equals: 'Microsoft.Network/applicationGateways'
          }
          {
            field: 'type'
            equals: 'Microsoft.Network/virtualNetworks'
          }
          {
            field: 'type'
            equals: 'Microsoft.DBforMySQL/flexibleServers'
          }
          {
            field: 'type'
            equals: 'Microsoft.DBforPostgreSQL/flexibleServers'
          }
          {
            field: 'type'
            equals: 'Microsoft.Sql/servers/databases'
          }
          {
            field: 'type'
            equals: 'Microsoft.Network/NetworkSecurityGroups'
          }
                  {
            field: 'type'
            equals: 'Microsoft.Network/LoadBalancers'
          }
        ]
      }
      then: {
        effect: 'modify'
        details: {
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
          ]
          operations: [
            {
              operation: 'add'
              field: '[concat(\'tags[\', parameters(\'tagName\'), \']\')]'
              value: '[parameters(\'tagValue\')]'
            }
          ]
        }
      }
    }
  }
}




// output resourceGroupid string = resourceGroup.id
// output resourceGroupname string = resourceGroup.name
// output subscriptionId string = subscription().id
