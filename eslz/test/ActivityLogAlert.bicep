@description('Unique name (within the Resource Group) for the Activity log alert.')
param activityLogAlertName string

@description('Indicates whether or not the alert is enabled.')
param activityLogAlertEnabled bool = true

@description('Resource Id for the Action group.')
param actionGroupResourceId string

resource activityLogAlert 'Microsoft.Insights/activityLogAlerts@2017-04-01' = {
  name: activityLogAlertName
  location: 'Global'
  properties: {
    enabled: activityLogAlertEnabled
    scopes: [
      subscription().id
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.Network/VirtualNetworks/write'
        }
        {
          field: 'resourceType'
          equals: 'Microsoft.Network/VirtualNetworks'
        }
        {
          field: 'status'
          equals: 'Succeeded'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: actionGroupResourceId
        }
      ]
    }
  }
}
