

targetScope = 'subscription'

// custom Log Search vf-core-cm-blob-services-availability
resource polDefBlobServicesAvl 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: 'vf-cm-blob-services-avl-customerRG'
  properties: {
    policyType: 'Custom' 
    mode: 'Indexed'
    description: 'This policy definition will deploy alert for Storage Account Blob Service Availability has been below threshold value'
    displayName: 'vf-cm-blob-services-avl-customerRG'
    metadata: {
      category : 'Monitoring'
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Storage/storageAccounts'
          }
        ]
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Insights/scheduledQueryRules'
          existenceCondition: {
            allOf: [
              {
                field: 'name'
                equals: 'vf-core-cm-blob-services-availability-customerRG'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {}
                resources: [
                  {
                    type: 'Microsoft.Insights/scheduledQueryRules'
                    apiVersion: '2021-08-01'
                    name: 'vf-core-cm-blob-services-availability-customerRG'
                    location: 'Alocation'
                    properties: {
                      displayName: 'vf-core-cm-blob-services-availability-customerRG'
                      description: 'Storage Account Blob Service Availability has been below threshold value'
                      severity: 0
                      enabled: true
                      evaluationFrequency: 'PT5M'
                      scopes: [
                        'rgScope'
                      ]
                      targetResourceTypes: [
                        'Microsoft.Storage/storageAccounts'
                      ]
                      windowSize: 'PT5M'
                      overrideQueryTimeRange: 'P2D'
                      criteria: {
                        allOf: [
                          {
                            query: 'AzureMetrics\n| where ResourceProvider == "MICROSOFT.STORAGE" // /DATABASES\n| where _ResourceId contains "blobservices"\n| where MetricName in (\'Availability\')\n| summarize AVL_blob_Max = max(Maximum), AVL_blob_Min = min(Minimum), AVL_blob_Avg = avg(Average) by Resource , MetricName, _ResourceId'
                            timeAggregation: 'Average'
                            metricMeasureColumn: 'AVL_blob_Avg'
                            resourceIdColumn: '_ResourceId'
                            operator: 'LessThan'
                            threshold: 20
                            failingPeriods: {
                              numberOfEvaluationPeriods: 1
                              minFailingPeriodsToAlert: 1
                            }
                          }
                        ]
                      }
                      actions: {
                        actionGroups: [
                          'AactionGroupName'
                        ]
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}



// custom Log Search vf-core-cm-storage-account-availability
resource polDefStorageAccAvl 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: 'vf-cm-storage-account-avl-customerRG'
  properties: {
    policyType: 'Custom' 
    mode: 'Indexed'
    description: 'This policy definition will deploy alert for Storage Account Availability has been below threshold value'
    displayName: 'vf-cm-storage-account-avl-customerRG'
    metadata: {
      category : 'Monitoring'
    }
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Storage/storageAccounts'
          }
        ]
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Insights/scheduledQueryRules'
          existenceCondition: {
            allOf: [
              {
                field: 'name'
                equals: 'vf-core-cm-storage-account-availability-customerRG'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                resources: [
                  {
                    type: 'Microsoft.Insights/scheduledQueryRules'
                    apiVersion: '2021-08-01'
                    name: 'vf-core-cm-storage-account-availability-customerRG'
                    location: 'Alocation'
                    properties: {
                      displayName: 'vf-core-cm-storage-account-availability-customerRG'
                      description: 'Storage Account Availability has been below threshold value'
                      severity: 0
                      enabled: true
                      evaluationFrequency: 'PT5M'
                      scopes: [
                        'rgScope'
                      ]
                      targetResourceTypes: [
                        'Microsoft.Storage/storageAccounts'
                      ]
                      windowSize: 'PT5M'
                      overrideQueryTimeRange: 'P2D'
                      criteria: {
                        allOf: [
                          {
                            query: 'AzureMetrics\n| where ResourceProvider == "MICROSOFT.STORAGE" // /DATABASES\n| where TimeGenerated >= ago(60min)\n| where MetricName in (\'Availability\')\n| summarize AVL_Storage_Max = max(Maximum), AVL_Storage_Min = min(Minimum), AVL_Storage_Avg = avg(Average) by Resource , MetricName, _ResourceId'
                            timeAggregation: 'Average'
                            metricMeasureColumn: 'AVL_Storage_Avg'
                            resourceIdColumn: '_ResourceId'
                            operator: 'LessThan'
                            threshold: 20
                            failingPeriods: {
                              numberOfEvaluationPeriods: 1
                              minFailingPeriodsToAlert: 1
                            }
                          }
                        ]
                      }
                      actions: {
                        actionGroups: [
                          'AactionGroupName'
                        ]
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}




// custom Log Search vf-core-cm-file-services-availability
resource polDefFileServicesAvl 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: 'vf-cm-file-services-avl-customerRG'
  properties: {
    policyType: 'Custom' 
    mode: 'Indexed'
    description: 'This policy definition will deploy alert for Storage Account File Services Availability has been below threshold value'
    displayName: 'vf-cm-file-services-avl-customerRG'
    metadata: {
      category : 'Monitoring'
    }
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Storage/storageAccounts'
          }
        ]
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Insights/scheduledQueryRules'
          existenceCondition: {
            allOf: [
              {
                field: 'name'
                equals: 'vf-core-cm-file-services-availability-customerRG'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                resources: [
                  {
                    type: 'Microsoft.Insights/scheduledQueryRules'
                    apiVersion: '2021-08-01'
                    name: 'vf-core-cm-file-services-availability-customerRG'
                    location: 'Alocation'
                    properties: {
                      displayName: 'vf-core-cm-file-services-availability-customerRG'
                      description: 'Storage Account File Services Availability has been below threshold value'
                      severity: 0
                      enabled: true
                      evaluationFrequency: 'PT5M'
                      scopes: [
                        'rgScope'
                      ]
                      targetResourceTypes: [
                        'Microsoft.Storage/storageAccounts'
                      ]
                      windowSize: 'PT5M'
                      overrideQueryTimeRange: 'P2D'
                      criteria: {
                        allOf: [
                          {
                            query: 'AzureMetrics\n| where ResourceProvider == "MICROSOFT.STORAGE" // /DATABASES\n| where _ResourceId contains "fileservices" \n| where MetricName in (\'Availability\')\n| summarize AVL_fileservices_Max = max(Maximum), AVL_fileservices_Min = min(Minimum), AVL_fileservices_Avg = avg(Average) by Resource , MetricName, _ResourceId'
                            timeAggregation: 'Average'
                            metricMeasureColumn: 'AVL_fileservices_Avg'
                            resourceIdColumn: '_ResourceId'
                            operator: 'LessThan'
                            threshold: 20
                            failingPeriods: {
                              numberOfEvaluationPeriods: 1
                              minFailingPeriodsToAlert: 1
                            }
                          }
                        ]
                      }
                      actions: {
                        actionGroups: [
                          'AactionGroupName'
                        ]
                      }
                    }
                  }
                ]
              }
              
            }
          }
        }
      }
    }
  }
}



// custom Log Search vf-core-cm-SQL-server-cpu-percent
resource polDefSQLServerCPUPercent 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: 'vf-cm-SQL-server-cpu-per-customerRG'
  properties: {
    policyType: 'Custom' 
    mode: 'Indexed'
    description: 'This policy definition will deploy alert for The CPU percent for a Azure SQL Database has been crossed the threshold value'
    displayName: 'vf-cm-SQL-server-cpu-per-customerRG'
    metadata: {
      category : 'Monitoring'
    }
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Sql/servers'
          } 
        ]
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Insights/scheduledQueryRules'
          existenceCondition: {
            allOf: [
              {
                field: 'name'
                equals: 'vf-core-cm-SQL-server-cpu-per-customerRG'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                resources: [
                  {
                    type: 'Microsoft.Insights/scheduledQueryRules'
                    apiVersion: '2021-08-01'
                    name: 'vf-core-cm-SQL-server-cpu-per-customerRG'
                    location: 'Alocation'
                    properties: {
                      displayName: 'vf-core-cm-SQL-server-cpu-per-customerRG'
                      description: 'The CPU percent for a Azure SQL Database has been crossed the threshold value'
                      severity: 0
                      enabled: true
                      evaluationFrequency: 'PT5M'
                      scopes: [
                        'rgScope'
                      ]
                      targetResourceTypes: [
                        'Microsoft.Sql/servers'
                      ]
                      windowSize: 'PT5M'
                      overrideQueryTimeRange: 'P2D'
                      criteria: {
                        allOf: [
                          {
                            query: 'AzureMetrics\n| where ResourceProvider == "MICROSOFT.SQL" // /DATABASES\n| where TimeGenerated >= ago(60min)\n| where MetricName in (\'cpu_percent\')\n| summarize CPU_Maximum = max(Maximum), CPU_Minimum = min(Minimum), CPU_Average = avg(Average) by Resource , MetricName, _ResourceId'
                            timeAggregation: 'Average'
                            metricMeasureColumn: 'CPU_Average'
                            resourceIdColumn: '_ResourceId'
                            operator: 'GreaterThan'
                            threshold: 90
                            failingPeriods: {
                              numberOfEvaluationPeriods: 1
                              minFailingPeriodsToAlert: 1
                            }
                          }
                        ]
                      }
                      actions: {
                        actionGroups: [
                          'AactionGroupName'
                        ]
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}



// custom Log Search vf-core-cm-SQL-server-memory-percent
resource polDefSQLServerMemoryPercent 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: 'vf-cm-SQL-server-memory-per-customerRG'
  properties: {
    policyType: 'Custom' 
    mode: 'Indexed'
    description: 'This policy definition will deploy alert for the Memory percent for a Azure SQL Database has been crossed the threshold value'
    displayName: 'vf-cm-SQL-server-memory-per-customerRG'
    metadata: {
      category : 'Monitoring'
    }
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Sql/servers'
          }
        ]
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Insights/scheduledQueryRules'
          existenceCondition: {
            allOf: [
              {
                field: 'name'
                equals: 'vf-core-cm-SQL-server-memory-per-customerRG'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                resources: [
                  {
                    type: 'Microsoft.Insights/scheduledQueryRules'
                    apiVersion: '2021-08-01'
                    name: 'vf-core-cm-SQL-server-memory-per-customerRG'
                    location: 'Alocation'
                    properties: {
                      displayName: 'vf-core-cm-SQL-server-memory-per-customerRG'
                      description: 'The Memory percent for a Azure SQL Database has been crossed the threshold value'
                      severity: 0
                      enabled: true
                      evaluationFrequency: 'PT5M'
                      scopes: [
                        'rgScope'
                      ]
                      targetResourceTypes: [
                        'Microsoft.Sql/servers'
                      ]
                      windowSize: 'PT5M'
                      overrideQueryTimeRange: 'P2D'
                      criteria: {
                        allOf: [
                          {
                            query: 'AzureMetrics\n| where ResourceProvider == "MICROSOFT.SQL" // /DATABASES\n| where TimeGenerated >= ago(60min)\n| where MetricName in (\'memory_percent\')\n| summarize MEMORY_Maximum = max(Maximum), MEMORY_Minimum= min(Minimum), MEMORY_Average = avg(Average) by Resource , MetricName, _ResourceId'
                            timeAggregation: 'Average'
                            metricMeasureColumn: 'MEMORY_Average'
                            resourceIdColumn: '_ResourceId'
                            operator: 'GreaterThan'
                            threshold: 90
                            failingPeriods: {
                              numberOfEvaluationPeriods: 1
                              minFailingPeriodsToAlert: 1
                            }
                          }
                        ]
                      }
                      actions: {
                        actionGroups: [
                          'AactionGroupName'
                        ]
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}





// custom Log Search vf-core-cm-SQL-server-data-space-used-percent
resource polDefSQLServerDataUsedPercent 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: 'vf-cm-SQL-server-data-used-per-customerRG'
  properties: {
    policyType: 'Custom' 
    mode: 'Indexed'
    description: 'This policy definition will deploy alert for the Data space used percent for a Azure SQL Database has been crossed the threshold value'
    displayName: 'vf-cm-SQL-server-data-used-per-customerRG'
    metadata: {
      category : 'Monitoring'
    }
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Sql/servers'
          }
        ]
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Insights/scheduledQueryRules'
          existenceCondition: {
            allOf: [
              {
                field: 'name'
                equals: 'vf-core-cm-SQL-server-data-space-used-per-customerRG'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                resources: [
                  {
                    type: 'Microsoft.Insights/scheduledQueryRules'
                    apiVersion: '2021-08-01'
                    name: 'vf-core-cm-SQL-server-data-space-used-per-customerRG'
                    location: 'Alocation'
                    properties: {
                      displayName: 'vf-core-cm-SQL-server-data-space-used-per-customerRG'
                      description: 'The Data space used percent for a Azure SQL Database has been crossed the threshold value'
                      severity: 0
                      enabled: true
                      evaluationFrequency: 'PT5M'
                      scopes: [
                        'rgScope'
                      ]
                      targetResourceTypes: [
                        'Microsoft.Sql/servers'
                      ]
                      windowSize: 'PT5M'
                      overrideQueryTimeRange: 'P2D'
                      criteria: {
                        allOf: [
                          {
                            query: 'AzureMetrics\n| where ResourceProvider == "MICROSOFT.SQL" // /DATABASES\n| where TimeGenerated >= ago(60min)\n| where MetricName in (\'storage_percent\')\n| summarize STORAGE_Maximum = max(Maximum), STORAGE_Minimum = min(Minimum), STORAGE_Average = avg(Average) by Resource , MetricName, _ResourceId'
                            timeAggregation: 'Average'
                            metricMeasureColumn: 'STORAGE_Average'
                            resourceIdColumn: '_ResourceId'
                            operator: 'GreaterThan'
                            threshold: 90
                            failingPeriods: {
                              numberOfEvaluationPeriods: 1
                              minFailingPeriodsToAlert: 1
                            }
                          }
                        ]
                      }
                      actions: {
                        actionGroups: [
                          'AactionGroupName'
                        ]
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}





// custom Log Search vf-core-cm-SQL-server-failed-connection
resource polDefSQLServerFailedConn 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: 'vf-cm-SQL-server-failed-conn-customerRG'
  properties: {
    policyType: 'Custom' 
    mode: 'Indexed'
    description: 'This policy definition will deploy alert for the Failed Connection for a Azure SQL Database has been crossed the threshold value'
    displayName: 'vf-cm-SQL-server-failed-conn-customerRG'
    metadata: {
      category : 'Monitoring'
    }
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Sql/servers'
          }
        ]
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Insights/scheduledQueryRules'
          existenceCondition: {
            allOf: [
              {
                field: 'name'
                equals: 'vf-core-cm-SQL-server-failed-conn-customerRG'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                resources: [
                  {
                    type: 'Microsoft.Insights/scheduledQueryRules'
                    apiVersion: '2021-08-01'
                    name: 'vf-core-cm-SQL-server-failed-conn-customerRG'
                    location: 'Alocation'
                    properties: {
                      displayName: 'vf-core-cm-SQL-server-failed-conn-customerRG'
                      description: 'The Failed Connection for a Azure SQL Database has been crossed the threshold value'
                      severity: 1
                      enabled: true
                      evaluationFrequency: 'PT5M'
                      scopes: [
                        'rgScope'
                      ]
                      targetResourceTypes: [
                        'Microsoft.Sql/servers'
                      ]
                      windowSize: 'PT5M'
                      overrideQueryTimeRange: 'P2D'
                      criteria: {
                        allOf: [
                          {
                            query: 'AzureMetrics\n| where ResourceProvider == "MICROSOFT.SQL" // /DATABASES\n| where TimeGenerated >= ago(60min)\n| where MetricName in (\'connection_failed\')\n| summarize Failed_Connections_Max = max(Maximum), Failed_Connections_Min = min(Minimum), Failed_Connections_Avg = avg(Average) by Resource , MetricName, _ResourceId'
                            timeAggregation: 'Average'
                            metricMeasureColumn: 'Failed_Connections_Avg'
                            resourceIdColumn: '_ResourceId'
                            operator: 'GreaterThan'
                            threshold: 1
                            failingPeriods: {
                              numberOfEvaluationPeriods: 1
                              minFailingPeriodsToAlert: 1
                            }
                          }
                        ]
                      }
                      actions: {
                        actionGroups: [
                          'AactionGroupName'
                        ]
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}



// custom Log Search vf-core-cm-SQL-server-dtu-percent
resource polDefSQLServerDTUPercent 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: 'vf-cm-SQL-server-dtu-per-customerRG'
  properties: {
    policyType: 'Custom' 
    mode: 'Indexed'
    description: 'This policy definition will deploy alert for the DTU Percent Azure SQL Database has been crossed the threshold value'
    displayName: 'vf-cm-SQL-server-dtu-per-customerRG'
    metadata: {
      category : 'Monitoring'
    }
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Sql/servers'
          }
        ]
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Insights/scheduledQueryRules'
          existenceCondition: {
            allOf: [
              {
                field: 'name'
                equals: 'vf-core-cm-SQL-server-dtu-per-customerRG'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                resources: [
                  {
                    type: 'Microsoft.Insights/scheduledQueryRules'
                    apiVersion: '2021-08-01'
                    name: 'vf-core-cm-SQL-server-dtu-per-customerRG'
                    location: 'Alocation'
                    properties: {
                      displayName: 'vf-core-cm-SQL-server-dtu-per-customerRG'
                      description: 'The DTU Percent Azure SQL Database has been crossed the threshold value'
                      severity: 0
                      enabled: true
                      evaluationFrequency: 'PT5M'
                      scopes: [
                        'rgScope'
                      ]
                      targetResourceTypes: [
                        'Microsoft.Sql/servers'
                      ]
                      windowSize: 'PT5M'
                      overrideQueryTimeRange: 'P2D'
                      criteria: {
                        allOf: [
                          {
                            query: 'AzureMetrics\n| where ResourceProvider == "MICROSOFT.SQL" // /DATABASES\n| where TimeGenerated >= ago(60min)\n| where MetricName in (\'dtu_consumption_percent\')\n| summarize DTU_Maximum = max(Maximum), DTU_Minimum = min(Minimum), DTU_Average = avg(Average) by Resource , MetricName, _ResourceId'
                            timeAggregation: 'Average'
                            metricMeasureColumn: 'DTU_Average'
                            resourceIdColumn: '_ResourceId'
                            operator: 'GreaterThan'
                            threshold: 90
                            failingPeriods: {
                              numberOfEvaluationPeriods: 1
                              minFailingPeriodsToAlert: 1
                            }
                          }
                        ]
                      }
                      actions: {
                        actionGroups: [
                          'AactionGroupName'
                        ]
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}




// custom Log Search vf-core-cm-SQL-server-log-IO-per-connection
resource polDefSQLServerLogIOPercent 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: 'vf-cm-SQL-server-log-IO-per-conn-customerRG'
  properties: {
    policyType: 'Custom' 
    mode: 'Indexed'
    description: 'This policy definition will deploy alert for the SQL Server Log IO for a Azure SQL Database has been crossed the threshold value'
    displayName: 'vf-cm-SQL-server-log-IO-per-conn-customerRG'
    metadata: {
      category : 'Monitoring'
    }
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Sql/servers'
          }
        ]
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Insights/scheduledQueryRules'
          existenceCondition: {
            allOf: [
              {
                field: 'name'
                equals: 'vf-core-cm-SQL-server-log-IO-per-conn-customerRG'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                resources: [
                  {
                    type: 'Microsoft.Insights/scheduledQueryRules'
                    apiVersion: '2021-08-01'
                    name: 'vf-core-cm-SQL-server-log-IO-per-conn-customerRG'
                    location: 'Alocation'
                    properties: {
                      displayName: 'vf-core-cm-SQL-server-log-IO-per-conn-customerRG'
                      description: 'The SQL Server Log IO for a Azure SQL Database has been crossed the threshold value'
                      severity: 0
                      enabled: true
                      evaluationFrequency: 'PT5M'
                      scopes: [
                        'rgScope'
                      ]
                      targetResourceTypes: [
                        'Microsoft.Sql/servers'
                      ]
                      windowSize: 'PT5M'
                      overrideQueryTimeRange: 'P2D'
                      criteria: {
                        allOf: [
                          {
                            query: 'AzureMetrics\n| where ResourceProvider == "MICROSOFT.SQL" // /DATABASES\n| where TimeGenerated >= ago(60min)\n| where MetricName in (\'log_write_percent\')\n| summarize LOG_IO_Maximum = max(Maximum), LOG_IO_Minimum = min(Minimum), LOG_IO_Average = avg(Average) by Resource , MetricName, _ResourceId'
                            timeAggregation: 'Average'
                            metricMeasureColumn: 'LOG_IO_Average'
                            resourceIdColumn: '_ResourceId'
                            operator: 'GreaterThan'
                            threshold: 90
                            failingPeriods: {
                              numberOfEvaluationPeriods: 1
                              minFailingPeriodsToAlert: 1
                            }
                          }
                        ]
                      }
                      actions: {
                        actionGroups: [
                          'AactionGroupName'
                        ]
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}


// custom Log Search vf-core-cm-SQL-server-data-IO-percent
resource polDefSQLServerDataIOPercent 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: 'vf-cm-SQL-server-data-IO-per-customerRG'
  properties: {
    policyType: 'Custom' 
    mode: 'Indexed'
    description: 'This policy definition will deploy alert for the SQL Server Data IO for a Azure SQL Database has been crossed the threshold value'
    displayName: 'vf-cm-SQL-server-data-IO-per-customerRG'
    metadata: {
      category : 'Monitoring'
    }
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Sql/servers'
          }
        ]
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Insights/scheduledQueryRules'
          existenceCondition: {
            allOf: [
              {
                field: 'name'
                equals: 'vf-core-cm-SQL-server-data-IO-per-customerRG'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                resources: [
                  {
                    type: 'Microsoft.Insights/scheduledQueryRules'
                    apiVersion: '2021-08-01'
                    name: 'vf-core-cm-SQL-server-data-IO-per-customerRG'
                    location: 'Alocation'
                    properties: {
                      displayName: 'vf-core-cm-SQL-server-data-IO-per-customerRG'
                      description: 'The SQL Server Data IO for a Azure SQL Database has been crossed the threshold value'
                      severity: 0
                      enabled: true
                      evaluationFrequency: 'PT5M'
                      scopes: [
                        'rgScope'
                      ]
                      targetResourceTypes: [
                        'Microsoft.Sql/servers'
                      ]
                      windowSize: 'PT5M'
                      overrideQueryTimeRange: 'P2D'
                      criteria: {
                        allOf: [
                          {
                            query: 'AzureMetrics\n| where ResourceProvider == "MICROSOFT.SQL" // /DATABASES\n| where TimeGenerated >= ago(60min)\n| where MetricName in (\'physical_data_read_percent\')\n| summarize DATA_IO_Maximum = max(Maximum), DATA_IO_Minimum = min(Minimum), DATA_IO_Average = avg(Average) by Resource , MetricName, _ResourceId'
                            timeAggregation: 'Average'
                            metricMeasureColumn: 'DATA_IO_Average'
                            resourceIdColumn: '_ResourceId'
                            operator: 'GreaterThan'
                            threshold: 90
                            failingPeriods: {
                              numberOfEvaluationPeriods: 1
                              minFailingPeriodsToAlert: 1
                            }
                          }
                        ]
                      }
                      actions: {
                        actionGroups: [
                          'AactionGroupName'
                        ]
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}


// custom Log Search vf-core-cm-PostgreSQL-flx-server-cpu-percent
resource polDefPostgreSQLCPUPercent 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: 'vf-cm-PSQL-flx-server-cpu-per-customerRG'
  properties: {
    policyType: 'Custom' 
    mode: 'Indexed'
    description: 'This policy definition will deploy alert for the CPU percentage for a Azure PostgreSQL Flexible Server Database has been crossed the threshold value'
    displayName: 'vf-cm-PSQL-flx-server-cpu-per-customerRG'
    metadata: {
      category : 'Monitoring'
    }
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.DBforPostgreSQL/flexibleServers'
          }
        ]
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Insights/scheduledQueryRules'
          existenceCondition: {
            allOf: [
              {
                field: 'name'
                equals: 'vf-core-cm-PostgreSQL-flx-server-cpu-per-customerRG'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                resources: [
                  {
                    type: 'Microsoft.Insights/scheduledQueryRules'
                    apiVersion: '2021-08-01'
                    name: 'vf-core-cm-PostgreSQL-flx-server-cpu-per-customerRG'
                    location: 'Alocation'
                    properties: {
                      displayName: 'vf-core-cm-PostgreSQL-flx-server-cpu-per-customerRG'
                      description: 'The CPU percentage for a Azure PostgreSQL Flexible Server Database has been crossed the threshold value'
                      severity: 0
                      enabled: true
                      evaluationFrequency: 'PT5M'
                      scopes: [
                        'rgScope'
                      ]
                      targetResourceTypes: [
                        'Microsoft.DBforPostgreSQL/flexibleServers'
                      ]
                      windowSize: 'PT5M'
                      overrideQueryTimeRange: 'P2D'
                      criteria: {
                        allOf: [
                          {
                            query: 'AzureMetrics\n| where ResourceProvider == "MICROSOFT.DBFORPOSTGRESQL" // /DATABASES\n| where TimeGenerated >= ago(60min)\n| where MetricName in (\'cpu_percent\')\n| summarize CPU_Maximum = max(Maximum), CPU_Minimum = min(Minimum), CPU_Average = avg(Average) by Resource , MetricName, _ResourceId'
                            timeAggregation: 'Average'
                            metricMeasureColumn: 'CPU_Average'
                            resourceIdColumn: '_ResourceId'
                            operator: 'GreaterThan'
                            threshold: 90
                            failingPeriods: {
                              numberOfEvaluationPeriods: 1
                              minFailingPeriodsToAlert: 1
                            }
                          }
                        ]
                      }
                      actions: {
                        actionGroups: [
                          'AactionGroupName'
                        ]
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}

// custom Log Search vf-core-cm-PostgreSQL-flx-server-memory-percent
resource polDefPostgreSQLMemoryPercent 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: 'vf-cm-PSQL-flx-server-memory-per-customerRG'
  properties: {
    policyType: 'Custom' 
    mode: 'Indexed'
    description: 'This policy definition will deploy alert for the Memory percentage for a Azure PostgreSQL Flexible Server Database has been crossed the threshold value'
    displayName: 'vf-cm-PSQL-flx-server-memory-per-customerRG'
    metadata: {
      category : 'Monitoring'
    }
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.DBforPostgreSQL/flexibleServers'
          }
        ]
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Insights/scheduledQueryRules'
          existenceCondition: {
            allOf: [
              {
                field: 'name'
                equals: 'vf-core-cm-PostgreSQL-flx-server-memory-per-customerRG'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                resources: [
                  {
                    type: 'Microsoft.Insights/scheduledQueryRules'
                    apiVersion: '2021-08-01'
                    name: 'vf-core-cm-PostgreSQL-flx-server-memory-per-customerRG'
                    location: 'Alocation'
                    properties: {
                      displayName: 'vf-core-cm-PostgreSQL-flx-server-memory-per-customerRG'
                      description: 'The Memory percentage for a Azure PostgreSQL Flexible Server Database has been crossed the threshold value'
                      severity: 0
                      enabled: true
                      evaluationFrequency: 'PT5M'
                      scopes: [
                        'rgScope'
                      ]
                      targetResourceTypes: [
                        'Microsoft.DBforPostgreSQL/flexibleServers'
                      ]
                      windowSize: 'PT5M'
                      overrideQueryTimeRange: 'P2D'
                      criteria: {
                        allOf: [
                          {
                            query: 'AzureMetrics\n| where ResourceProvider == "MICROSOFT.DBFORPOSTGRESQL" // /DATABASES\n| where TimeGenerated >= ago(60min)\n| where MetricName in (\'memory_percent\')\n| summarize MEMORY_Maximum = max(Maximum), MEMORY_Minimum= min(Minimum), MEMORY_Average = avg(Average) by Resource , MetricName, _ResourceId'
                            timeAggregation: 'Average'
                            metricMeasureColumn: 'MEMORY_Average'
                            resourceIdColumn: '_ResourceId'
                            operator: 'GreaterThan'
                            threshold: 90
                            failingPeriods: {
                              numberOfEvaluationPeriods: 1
                              minFailingPeriodsToAlert: 1
                            }
                          }
                        ]
                      }
                      actions: {
                        actionGroups: [
                          'AactionGroupName'
                        ]
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}


// custom Log Search vf-core-cm-PostgreSQL-flx-server-storage-percent
resource polDefPostgreSQLStoragePercent 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: 'vf-cm-PSQL-flx-server-storage-per-customerRG'
  properties: {
    policyType: 'Custom' 
    mode: 'Indexed'
    description: 'This policy definition will deploy alert for the Storage percentage for a Azure PostgreSQL Flexible Server Database has been crossed the threshold value'
    displayName: 'vf-cm-PSQL-flx-server-storage-per-customerRG'
    metadata: {
      category : 'Monitoring'
    }
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.DBforPostgreSQL/flexibleServers'
          }
        ]
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Insights/scheduledQueryRules'
          existenceCondition: {
            allOf: [
              {
                field: 'name'
                equals: 'vf-core-cm-PostgreSQL-flx-server-storage-per-customerRG'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                resources: [
                  {
                    type: 'Microsoft.Insights/scheduledQueryRules'
                    apiVersion: '2021-08-01'
                    name: 'vf-core-cm-PostgreSQL-flx-server-storage-per-customerRG'
                    location: 'Alocation'
                    properties: {
                      displayName: 'vf-core-cm-PostgreSQL-flx-server-storage-per-customerRG'
                      description: 'The Storage percentage for a Azure PostgreSQL Flexible Server Database has been crossed the threshold value'
                      severity: 0
                      enabled: true
                      evaluationFrequency: 'PT5M'
                      scopes: [
                        'rgScope'
                      ]
                      targetResourceTypes: [
                        'Microsoft.DBforPostgreSQL/flexibleServers'
                      ]
                      windowSize: 'PT5M'
                      overrideQueryTimeRange: 'P2D'
                      criteria: {
                        allOf: [
                          {
                            query: 'AzureMetrics\n| where ResourceProvider == "MICROSOFT.DBFORPOSTGRESQL" // /DATABASES\n| where TimeGenerated >= ago(60min)\n| where MetricName in (\'storage_percent\')\n| summarize STORAGE_Maximum = max(Maximum), STORAGE_Minimum = min(Minimum), STORAGE_Average = avg(Average) by Resource , MetricName, _ResourceId'
                            timeAggregation: 'Average'
                            metricMeasureColumn: 'STORAGE_Average'
                            resourceIdColumn: '_ResourceId'
                            operator: 'GreaterThan'
                            threshold: 90
                            failingPeriods: {
                              numberOfEvaluationPeriods: 1
                              minFailingPeriodsToAlert: 1
                            }
                          }
                        ]
                      }
                      actions: {
                        actionGroups: [
                          'AactionGroupName'
                        ]
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}



// custom Log Search vf-core-cm-PostgreSQL-flx-server-act-conn-exceeded
resource polDefPostgreSQLActiveConnXceeded 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: 'vf-cm-PSQL-flx-server-act-conn-xceed-customerRG'
  properties: {
    policyType: 'Custom' 
    mode: 'Indexed'
    description: 'This policy definition will deploy alert for number of Active Connections for a Azure PostgreSQL Flexible Server Database has been crossed the threshold value'
    displayName: 'vf-cm-PSQL-flx-server-act-conn-xceed-customerRG'
    metadata: {
      category : 'Monitoring'
    }
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.DBforPostgreSQL/flexibleServers'
          }
        ]
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Insights/scheduledQueryRules'
          existenceCondition: {
            allOf: [
              {
                field: 'name'
                equals: 'vf-core-cm-PostgreSQL-flx-server-act-conn-exceeded-customerRG'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                resources: [
                  {
                    type: 'Microsoft.Insights/scheduledQueryRules'
                    apiVersion: '2021-08-01'
                    name: 'vf-core-cm-PostgreSQL-flx-server-act-conn-exceeded-customerRG'
                    location: 'Alocation'
                    properties: {
                      displayName: 'PostgreSQL Flexible Server Active Connection Exceeded-customerRG'
                      description: 'Number of Active Connections for a Azure PostgreSQL Flexible Server Database has been crossed the threshold value'
                      severity: 2
                      enabled: true
                      evaluationFrequency: 'PT5M'
                      scopes: [
                        'rgScope'
                      ]
                      targetResourceTypes: [
                        'Microsoft.DBforPostgreSQL/flexibleServers'
                      ]
                      windowSize: 'PT5M'
                      overrideQueryTimeRange: 'P2D'
                      criteria: {
                        allOf: [
                          {
                            query: 'AzureMetrics\n| where ResourceProvider == "MICROSOFT.DBFORPOSTGRESQL" // /DATABASES\n| where TimeGenerated >= ago(60min)\n| where MetricName in (\'active_connections\')\n| summarize Active_Connections_Max = max(Maximum), Active_Connections_Min = min(Minimum), Active_Connections_Avg = avg(Average) by Resource , MetricName, _ResourceId'
                            timeAggregation: 'Average'
                            metricMeasureColumn: 'Active_Connections_Avg'
                            resourceIdColumn: '_ResourceId'
                            operator: 'GreaterThan'
                            threshold: 300
                            failingPeriods: {
                              numberOfEvaluationPeriods: 1
                              minFailingPeriodsToAlert: 1
                            }
                          }
                        ]
                      }
                      actions: {
                        actionGroups: [
                          'AactionGroupName'
                        ]
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}



// custom Log Search vf-core-cm-PostgreSQL-flx-server-failed-connection
resource polDefPostgreSQLFailedConn 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: 'vf-cm-PSQL-flx-server-failed-conn-customerRG'
  properties: {
    policyType: 'Custom' 
    mode: 'Indexed'
    description: 'This policy definition will deploy alert for number of Falied Connections for a Azure PostgreSQL Flexible Server Database has been crossed the threshold valueNumber of Falied Connections for a Azure PostgreSQL Flexible Server Database has been crossed the threshold value'
    displayName: 'vf-cm-PSQL-flx-server-failed-conn-customerRG'
    metadata: {
      category : 'Monitoring'
    }
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.DBforPostgreSQL/flexibleServers'
          }
        ]
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Insights/scheduledQueryRules'
          existenceCondition: {
            allOf: [
              {
                field: 'name'
                equals: 'vf-core-cm-PostgreSQL-flx-server-failed-conn-customerRG'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                resources: [
                  {
                    type: 'Microsoft.Insights/scheduledQueryRules'
                    apiVersion: '2021-08-01'
                    name: 'vf-core-cm-PostgreSQL-flx-server-failed-conn-customerRG'
                    location: 'Alocation'
                    properties: {
                      displayName: 'PostgreSQL Flexible Server Failed Connection-customerRG'
                      description: 'Number of Falied Connections for a Azure PostgreSQL Flexible Server Database has been crossed the threshold valueNumber of Falied Connections for a Azure PostgreSQL Flexible Server Database has been crossed the threshold value'
                      severity: 1
                      enabled: true
                      evaluationFrequency: 'PT5M'
                      scopes: [
                        'rgScope'
                      ]
                      targetResourceTypes: [
                        'Microsoft.DBforPostgreSQL/flexibleServers'
                      ]
                      windowSize: 'PT5M'
                      overrideQueryTimeRange: 'P2D'
                      criteria: {
                        allOf: [
                          {
                            query: 'AzureMetrics\n| where ResourceProvider == "MICROSOFT.DBFORPOSTGRESQL" // /DATABASES\n| where TimeGenerated >= ago(60min)\n| where MetricName in (\'connections_failed\')\n| summarize Failed_Connections_Max = max(Maximum), Failed_Connections_Min = min(Minimum), Failed_Connections_Avg = avg(Average) by Resource , MetricName, _ResourceId'
                            timeAggregation: 'Average'
                            metricMeasureColumn: 'Failed_Connections_Avg'
                            resourceIdColumn: '_ResourceId'
                            operator: 'GreaterThan'
                            threshold: 1
                            failingPeriods: {
                              numberOfEvaluationPeriods: 1
                              minFailingPeriodsToAlert: 1
                            }
                          }
                        ]
                      }
                      actions: {
                        actionGroups: [
                          'AactionGroupName'
                        ]
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}

// custom Log Search vf-core-cm-PostgreSQL-flx-server-replication-lag
resource polDefPostgreSQLRepLag 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: 'vf-cm-PSQL-flx-server-rep-lag-customerRG'
  properties: {
    policyType: 'Custom' 
    mode: 'Indexed'
    description: 'This policy definition will deploy alert for number of Falied Connections for a Azure PostgreSQL Flexible Server Database has been crossed the threshold valueNumber of Falied Connections for a Azure PostgreSQL Flexible Server Database has been crossed the threshold value'
    displayName: 'vf-cm-PSQL-flx-server-rep-lag-customerRG'
    metadata: {
      category : 'Monitoring'
    }
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.DBforPostgreSQL/flexibleServers'
          }
        ]
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Insights/scheduledQueryRules'
          existenceCondition: {
            allOf: [
              {
                field: 'name'
                equals: 'vf-core-cm-PostgreSQL-flx-server-replication-lag-customerRG'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                resources: [
                  {
                    type: 'Microsoft.Insights/scheduledQueryRules'
                    apiVersion: '2021-08-01'
                    name: 'vf-core-cm-PostgreSQL-flx-server-replication-lag-customerRG'
                    location: 'Alocation'
                    properties: {
                      displayName: 'PostgreSQL Flexible Server Replication Lag-customerRG'
                      description: 'Number of Falied Connections for a Azure PostgreSQL Flexible Server Database has been crossed the threshold valueNumber of Falied Connections for a Azure PostgreSQL Flexible Server Database has been crossed the threshold value'
                      severity: 2
                      enabled: true
                      evaluationFrequency: 'PT5M'
                      scopes: [
                        'rgScope'
                      ]
                      targetResourceTypes: [
                        'Microsoft.DBforPostgreSQL/flexibleServers'
                      ]
                      windowSize: 'PT5M'
                      overrideQueryTimeRange: 'P2D'
                      criteria: {
                        allOf: [
                          {
                            query: 'AzureMetrics\n| where ResourceProvider == "MICROSOFT.DBFORPOSTGRESQL" // /DATABASES\n| where TimeGenerated >= ago(60min)\n| where MetricName in (\'physical_replication_delay_in_seconds\')\n| summarize Replica_Lag_Max = max(Maximum), Replica_Lag_Min = min(Minimum), Replica_Lag_Avg = avg(Average) by Resource , MetricName, _ResourceId'
                            timeAggregation: 'Average'
                            metricMeasureColumn: 'Replica_Lag_Avg'
                            resourceIdColumn: '_ResourceId'
                            operator: 'GreaterThan'
                            threshold: 10
                            failingPeriods: {
                              numberOfEvaluationPeriods: 1
                              minFailingPeriodsToAlert: 1
                            }
                          }
                        ]
                      }
                      actions: {
                        actionGroups: [
                          'AactionGroupName'
                        ]
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}


// custom Log Search vf-core-cm-MySQL-flx-server-host-cpu-percent
resource polDefMySQLHostCPUPercent 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: 'vf-cm-MySQL-flx-server-host-cpu-per-customerRG'
  properties: {
    policyType: 'Custom' 
    mode: 'Indexed'
    description: 'This policy definition will deploy alert for CPU percentage for a Azure MySQL Flexible Server Database has been crossed the threshold value'
    displayName: 'vf-cm-MySQL-flx-server-host-cpu-per-customerRG'
    metadata: {
      category : 'Monitoring'
    }
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.DBforMySQL/flexibleServers'
          }
        ]
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Insights/scheduledQueryRules'
          existenceCondition: {
            allOf: [
              {
                field: 'name'
                equals: 'vf-core-cm-MySQL-flx-server-host-cpu-per-customerRG'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                resources: [
                  {
                    type: 'Microsoft.Insights/scheduledQueryRules'
                    apiVersion: '2021-08-01'
                    name: 'vf-core-cm-MySQL-flx-server-host-cpu-per-customerRG'
                    location: 'Alocation'
                    properties: {
                      displayName: 'MySQL Flexible Server Host CPU Percent-customerRG'
                      description: 'CPU percentage for a Azure MySQL Flexible Server Database has been crossed the threshold value'
                      severity: 0
                      enabled: true
                      evaluationFrequency: 'PT5M'
                      scopes: [
                        'rgScope'
                      ]
                      targetResourceTypes: [
                        'Microsoft.DBforMySQL/flexibleServers'
                      ]
                      windowSize: 'PT5M'
                      overrideQueryTimeRange: 'P2D'
                      criteria: {
                        allOf: [
                          {
                            query: 'AzureMetrics\n| where ResourceProvider == "MICROSOFT.DBFORMYSQL" // /DATABASES\n| where TimeGenerated >= ago(60min)\n| where MetricName in (\'cpu_percent\')\n| summarize CPU_Maximum = max(Maximum), CPU_Minimum = min(Minimum), CPU_Average = avg(Average) by Resource , MetricName, _ResourceId'
                            timeAggregation: 'Average'
                            metricMeasureColumn: 'CPU_Average'
                            resourceIdColumn: '_ResourceId'
                            operator: 'GreaterThan'
                            threshold: 90
                            failingPeriods: {
                              numberOfEvaluationPeriods: 1
                              minFailingPeriodsToAlert: 1
                            }
                          }
                        ]
                      }
                      actions: {
                        actionGroups: [
                          'AactionGroupName'
                        ]
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}


// custom Log Search vf-core-cm-MySQL-flx-server-host-memory-percent
resource polDefMySQLHostMemoryPercent 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: 'vf-cm-MySQL-flx-server-host-memory-per-customerRG'
  properties: {
    policyType: 'Custom' 
    mode: 'Indexed'
    description: 'This policy definition will deploy alert for memory Percentage for a Azure MySQL Flexible Server Database has been crossed the threshold value'
    displayName: 'vf-cm-MySQL-flx-server-host-memory-per-customerRG'
    metadata: {
      category : 'Monitoring'
    }
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.DBforMySQL/flexibleServers'
          }
        ]
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Insights/scheduledQueryRules'
          existenceCondition: {
            allOf: [
              {
                field: 'name'
                equals: 'vf-core-cm-MySQL-flx-server-host-memory-per-customerRG'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                resources: [
                  {
                    type: 'Microsoft.Insights/scheduledQueryRules'
                    apiVersion: '2021-08-01'
                    name: 'vf-core-cm-MySQL-flx-server-host-memory-per-customerRG'
                    location: 'Alocation'
                    properties: {
                      displayName: 'MySQL Flexible Server Host Memory Percent-customerRG'
                      description: 'Memory Percentage for a Azure MySQL Flexible Server Database has been crossed the threshold value'
                      severity: 0
                      enabled: true
                      evaluationFrequency: 'PT5M'
                      scopes: [
                        'rgScope'
                      ]
                      targetResourceTypes: [
                        'Microsoft.DBforMySQL/flexibleServers'
                      ]
                      windowSize: 'PT5M'
                      overrideQueryTimeRange: 'P2D'
                      criteria: {
                        allOf: [
                          {
                            query: 'AzureMetrics\n| where ResourceProvider == "MICROSOFT.DBFORMYSQL" // /DATABASES\n| where TimeGenerated >= ago(60min)\n| where MetricName in (\'memory_percent\')\n| summarize MEMORY_Maximum = max(Maximum), MEMORY_Minimum= min(Minimum), MEMORY_Average = avg(Average) by Resource , MetricName, _ResourceId'
                            timeAggregation: 'Average'
                            metricMeasureColumn: 'MEMORY_Average'
                            resourceIdColumn: '_ResourceId'
                            operator: 'GreaterThan'
                            threshold: 90
                            failingPeriods: {
                              numberOfEvaluationPeriods: 1
                              minFailingPeriodsToAlert: 1
                            }
                          }
                        ]
                      }
                      actions: {
                        actionGroups: [
                          'AactionGroupName'
                        ]
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}

// custom Log Search vf-core-cm-MySQL-flx-server-storage-percent
resource polDefMySQLHostStoragePercent 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: 'vf-cm-MySQL-flx-server-storage-per-customerRG'
  properties: {
    policyType: 'Custom' 
    mode: 'Indexed'
    description: 'This policy definition will deploy alert for Storage Percentage for a Azure MySQL Flexible Server Database has been crossed the threshold value'
    displayName: 'vf-cm-MySQL-flx-server-storage-per-customerRG'
    metadata: {
      category : 'Monitoring'
    }
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.DBforMySQL/flexibleServers'
          }
        ]
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Insights/scheduledQueryRules'
          existenceCondition: {
            allOf: [
              {
                field: 'name'
                equals: 'vf-core-cm-MySQL-flx-server-storage-per-customerRG'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                resources: [
                  {
                    type: 'Microsoft.Insights/scheduledQueryRules'
                    apiVersion: '2021-08-01'
                    name: 'vf-core-cm-MySQL-flx-server-storage-per-customerRG'
                    location: 'Alocation'
                    properties: {
                      displayName: 'MySQL Flexible Server Host Storage Percent-customerRG'
                      description: 'Storage Percentage for a Azure MySQL Flexible Server Database has been crossed the threshold value'
                      severity: 0
                      enabled: true
                      evaluationFrequency: 'PT5M'
                      scopes: [
                        'rgScope'
                      ]
                      targetResourceTypes: [
                        'Microsoft.DBforMySQL/flexibleServers'
                      ]
                      windowSize: 'PT5M'
                      overrideQueryTimeRange: 'P2D'
                      criteria: {
                        allOf: [
                          {
                            query: 'AzureMetrics\n| where ResourceProvider == "MICROSOFT.DBFORMYSQL" // /DATABASES\n| where TimeGenerated >= ago(60min)\n| where MetricName in (\'storage_percent\')\n| summarize STORAGE_Maximum = max(Maximum), STORAGE_Minimum = min(Minimum), STORAGE_Average = avg(Average) by Resource , MetricName, _ResourceId'
                            timeAggregation: 'Average'
                            metricMeasureColumn: 'STORAGE_Average'
                            resourceIdColumn: '_ResourceId'
                            operator: 'GreaterThan'
                            threshold: 90
                            failingPeriods: {
                              numberOfEvaluationPeriods: 1
                              minFailingPeriodsToAlert: 1
                            }
                          }
                        ]
                      }
                      actions: {
                        actionGroups: [
                          'AactionGroupName'
                        ]
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}


// custom Log Search vf-core-cm-MySQL-flx-server-act-conn-exceeded
//diagnostic log checker
resource polDefMySQLActiveConnXceeded 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: 'vf-cm-MySQL-flx-server-act-conn-xceed-customerRG'
  properties: {
    policyType: 'Custom' 
    mode: 'Indexed'
    description: 'This policy definition will deploy alert for Number of Active Connection for a Azure MySQL Flexible Server Database has been crossed the threshold value'
    displayName: 'vf-cm-MySQL-flx-server-act-conn-xceed-customerRG'
    metadata: {
      category : 'Monitoring'
    }
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.DBforMySQL/flexibleServers'
          }
        ]
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Insights/scheduledQueryRules'
          existenceCondition: {
            allOf: [
              {
                field: 'name'
                equals: 'vf-core-cm-MySQL-flx-server-act-conn-exceeded-customerRG'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                resources: [
                  {
                    type: 'Microsoft.Insights/scheduledQueryRules'
                    apiVersion: '2021-08-01'
                    name: 'vf-core-cm-MySQL-flx-server-act-conn-exceeded-customerRG'
                    location: 'Alocation'
                    properties: {
                      displayName: 'MySQL Flexible Server Active Connections Exceeded-customerRG'
                      description: 'Number of Active Connection for a Azure MySQL Flexible Server Database has been crossed the threshold value'
                      severity: 2
                      enabled: true
                      evaluationFrequency: 'PT5M'
                      scopes: [
                        'rgScope'
                      ]
                      targetResourceTypes: [
                        'Microsoft.DBforMySQL/flexibleServers'
                      ]
                      windowSize: 'PT5M'
                      overrideQueryTimeRange: 'P2D'
                      criteria: {
                        allOf: [
                          {
                            query: 'AzureMetrics\n| where ResourceProvider == "MICROSOFT.DBFORMYSQL" // /DATABASES\n| where TimeGenerated >= ago(60min)\n| where MetricName in (\'active_connections\')\n| summarize Active_Connections_Max = max(Maximum), Active_Connections_Min = min(Minimum), Active_Connections_Avg = avg(Average) by Resource , MetricName, _ResourceId'
                            timeAggregation: 'Average'
                            metricMeasureColumn: 'Active_Connections_Avg'
                            resourceIdColumn: '_ResourceId'
                            operator: 'GreaterThan'
                            threshold: 300
                            failingPeriods: {
                              numberOfEvaluationPeriods: 1
                              minFailingPeriodsToAlert: 1
                            }
                          }
                        ]
                      }
                      actions: {
                        actionGroups: [
                          'AactionGroupName'
                        ]
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}


// custom Log Search vf-core-cm-MySQL-flx-server-aborted-connection
//diagnostic log checker
resource polDefMySQLAbortedConn 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: 'vf-cm-MySQL-flx-server-aborted-conn-customerRG'
  properties: {
    policyType: 'Custom' 
    mode: 'Indexed'
    description: 'This policy definition will deploy alert for number of Aborted Connection for a Azure MySQL Flexible Server Database has been crossed the threshold value'
    displayName: 'vf-cm-MySQL-flx-server-aborted-conn-customerRG'
    metadata: {
      category : 'Monitoring'
    }
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.DBforMySQL/flexibleServers'
          }
        ]
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Insights/scheduledQueryRules'
          existenceCondition: {
            allOf: [
              {
                field: 'name'
                equals: 'vf-core-cm-MySQL-flx-server-aborted-conn-customerRG'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                resources: [
                  {
                    type: 'Microsoft.Insights/scheduledQueryRules'
                    apiVersion: '2021-08-01'
                    name: 'vf-core-cm-MySQL-flx-server-aborted-conn-customerRG'
                    location: 'Alocation'
                    properties: {
                      displayName: 'MySQL Flexible Server Aborted Connections-customerRG'
                      description: 'Number of Aborted Connection for a Azure MySQL Flexible Server Database has been crossed the threshold value'
                      severity: 1
                      enabled: true
                      evaluationFrequency: 'PT5M'
                      scopes: [
                        'rgScope'
                      ]
                      targetResourceTypes: [
                        'Microsoft.DBforMySQL/flexibleServers'
                      ]
                      windowSize: 'PT5M'
                      overrideQueryTimeRange: 'P2D'
                      criteria: {
                        allOf: [
                          {
                            query: 'AzureMetrics\n| where ResourceProvider == "MICROSOFT.DBFORMYSQL" // /DATABASES\n| where TimeGenerated >= ago(60min)\n| where MetricName in (\'aborted_connections\')\n| summarize Aborted_Connections_Max = max(Maximum), Aborted_Connections_Min = min(Minimum), Aborted_Connections_Avg = avg(Average) by Resource , MetricName, _ResourceId'
                            timeAggregation: 'Average'
                            metricMeasureColumn: 'Aborted_Connections_Avg'
                            resourceIdColumn: '_ResourceId'
                            operator: 'GreaterThan'
                            threshold: 1
                            failingPeriods: {
                              numberOfEvaluationPeriods: 1
                              minFailingPeriodsToAlert: 1
                            }
                          }
                        ]
                      }
                      actions: {
                        actionGroups: [
                          'AactionGroupName'
                        ]
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}


// custom Log Search vf-core-cm-MySQL-flx-server-replica-lag
//diagnostic log checker
resource polDefMySQLReplicaLag 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: 'vf-cm-MySQL-flx-server-replica-lag-customerRG'
  properties: {
    policyType: 'Custom' 
    mode: 'Indexed'
    description: 'This policy definition will deploy alert for the Replica lag for a Azure MySQL Flexible Server Database has been crossed the threshold value'
    displayName: 'vf-cm-MySQL-flx-server-replica-lag-customerRG'
    metadata: {
      category : 'Monitoring'
    }
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.DBforMySQL/flexibleServers'
          }
        ]
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Insights/scheduledQueryRules'
          existenceCondition: {
            allOf: [
              {
                field: 'name'
                equals: 'vf-core-cm-MySQL-flx-server-replica-lag-customerRG'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                resources: [
                  {
                    type: 'Microsoft.Insights/scheduledQueryRules'
                    apiVersion: '2021-08-01'
                    name: 'vf-core-cm-MySQL-flx-server-replica-lag-customerRG'
                    location: 'Alocation'
                    properties: {
                      displayName: 'MySQL Flexible Server Replication Lag-customerRG'
                      description: 'The Replica lag for a Azure MySQL Flexible Server Database has been crossed the threshold value'
                      severity: 2
                      enabled: true
                      evaluationFrequency: 'PT5M'
                      scopes: [
                        'rgScope'
                      ]
                      targetResourceTypes: [
                        'Microsoft.DBforMySQL/flexibleServers'
                      ]
                      windowSize: 'PT5M'
                      overrideQueryTimeRange: 'P2D'
                      criteria: {
                        allOf: [
                          {
                            query: 'AzureMetrics\n| where ResourceProvider == "MICROSOFT.DBFORMYSQL" // /DATABASES\n| where TimeGenerated >= ago(60min)\n| where MetricName in (\'replication_lag\')\n| summarize Replica_Lag_Max = max(Maximum), Replica_Lag_Min = min(Minimum), Replica_Lag_Avg = avg(Average) by Resource , MetricName, _ResourceId'
                            timeAggregation: 'Average'
                            metricMeasureColumn: 'Replica_Lag_Avg'
                            resourceIdColumn: '_ResourceId'
                            operator: 'GreaterThan'
                            threshold: 10
                            failingPeriods: {
                              numberOfEvaluationPeriods: 1
                              minFailingPeriodsToAlert: 1
                            }
                          }
                        ]
                      }
                      actions: {
                        actionGroups: [
                          'AactionGroupName'
                        ]
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}


// custom Log Search vf-core-cm-app-gw-unhealthyhost-count
//diagnostic log checker
resource polDefAppGWUnhealthyCount 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: 'vf-cm-app-gw-unhealthyhost-count-lag-customerRG'
  properties: {
    policyType: 'Custom' 
    mode: 'Indexed'
    description: 'This policy definition will deploy alert for unhealthy host for an Application Gateway has been crossed the threshold value'
    displayName: 'vf-cm-app-gw-unhealthyhost-count-lag-customerRG'
    metadata: {
      category : 'Monitoring'
    }
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Network/applicaitonGateways'
          }
        ]
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Insights/scheduledQueryRules'
          existenceCondition: {
            allOf: [
              {
                field: 'name'
                equals: 'vf-core-cm-app-gw-unhealthyhost-count-customerRG'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                resources: [
                  {
                    type: 'Microsoft.Insights/scheduledQueryRules'
                    apiVersion: '2021-08-01'
                    name: 'vf-core-cm-app-gw-unhealthyhost-count-customerRG'
                    location: 'Alocation'
                    properties: {
                      displayName: 'Application Gateway Unhealthy Host Count-customerRG'
                      description: 'Unhealthy host for an Application Gateway has been crossed the threshold value'
                      severity: 1
                      enabled: true
                      evaluationFrequency: 'PT5M'
                      scopes: [
                        'rgScope'
                      ]
                      targetResourceTypes: [
                        'Microsoft.Network/applicaitonGateways'
                      ]
                      windowSize: 'PT5M'
                      overrideQueryTimeRange: 'P2D'
                      criteria: {
                        allOf: [
                          {
                            query: 'AzureMetrics\n| where ResourceProvider == "MICROSOFT.NETWORK" // /DATABASES\n| where TimeGenerated >= ago(60min)\n| where MetricName in (\'UnhealthyHostCount\')\n| summarize Total = sum(Total) by Resource , MetricName, _ResourceId'
                            timeAggregation: 'Total'
                            metricMeasureColumn: 'Total'
                            resourceIdColumn: '_ResourceId'
                            operator: 'GreaterThan'
                            threshold: 5
                            failingPeriods: {
                              numberOfEvaluationPeriods: 1
                              minFailingPeriodsToAlert: 1
                            }
                          }
                        ]
                      }
                      actions: {
                        actionGroups: [
                          'AactionGroupName'
                        ]
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}

// custom Log Search vf-core-cm-app-gw-failed-req
//diagnostic log checker
resource polDefAppGWFailedRequests 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: 'vf-cm-app-gw-failed-req-customerRG'
  properties: {
    policyType: 'Custom' 
    mode: 'Indexed'
    description: 'This policy definition will deploy alert for number of Failed Request for an Application Gateway has been crossed the threshold value'
    displayName: 'vf-cm-app-gw-failed-req-customerRG'
    metadata: {
      category : 'Monitoring'
    }
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Network/applicaitonGateways'
          }
        ]
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Insights/scheduledQueryRules'
          
          existenceCondition: {
            allOf: [
              {
                field: 'name'
                equals: 'vf-core-cm-app-gw-failed-req-customerRG'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                resources: [
                  {
                    type: 'Microsoft.Insights/scheduledQueryRules'
                    apiVersion: '2021-08-01'
                    name: 'vf-core-cm-app-gw-failed-req-customerRG'
                    location: 'Alocation'
                    properties: {
                      displayName: 'Application Gateway Failed Requests-customerRG'
                      description: 'Number of Failed Request for an Application Gateway has been crossed the threshold value'
                      severity: 1
                      enabled: true
                      evaluationFrequency: 'PT5M'
                      scopes: [
                        'rgScope'
                      ]
                      targetResourceTypes: [
                        'Microsoft.Network/applicaitonGateways'
                      ]
                      windowSize: 'PT5M'
                      overrideQueryTimeRange: 'P2D'
                      criteria: {
                        allOf: [
                          {
                            query: 'AzureMetrics\n| where ResourceProvider == "MICROSOFT.NETWORK" // /DATABASES\n| where TimeGenerated >= ago(60min)\n| where MetricName in (\'FailedRequests\')\n| summarize Total = sum(Total) by Resource , MetricName, _ResourceId'
                            timeAggregation: 'Total'
                            metricMeasureColumn: 'Total'
                            resourceIdColumn: '_ResourceId'
                            operator: 'GreaterThan'
                            threshold: 5
                            failingPeriods: {
                              numberOfEvaluationPeriods: 1
                              minFailingPeriodsToAlert: 1
                            }
                          }
                        ]
                      }
                      actions: {
                        actionGroups: [
                          'AactionGroupName'
                        ]
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}

