param actionRules_APR_Weekly_Maintenance_Window_name string = 'APR - Weekly Maintenance Window'

resource actionRules_APR_Weekly_Maintenance_Window_name_resource 'Microsoft.AlertsManagement/actionRules@2021-08-08' = {
  name: actionRules_APR_Weekly_Maintenance_Window_name
  location: 'Global'
  properties: {
    scopes: [
      '/subscriptions/df3b1809-17d0-47a0-9241-d2724780bdac'
    ]
    schedule: {
      effectiveFrom: '2022-11-24T00:00:00'
      effectiveUntil: '2023-12-31T23:59:59'
      timeZone: 'Eastern Standard Time'
      recurrences: [
        {
          daysOfWeek: [
            'Saturday'
          ]
          recurrenceType: 'Weekly'
          startTime: '09:00:00'
          endTime: '17:00:00'
        }
      ]
    }
    conditions: [
      {
        field: 'TargetResourceType'
        operator: 'Equals'
        values: [
          'microsoft.compute/virtualmachines'
        ]
      }
      {
        field: 'AlertRuleName'
        operator: 'Equals'
        values: [
          'lz50 - Metric - Percentage CPU Greater Than 80 Percent'
          'lz50 - Metric - Percentage CPU GreaterOrLessThan Dynamic Thresholds'
          'lz50 - Metric - Percentage CPU Less Than 30 Percent'
        ]
      }
      {
        field: 'TargetResourceGroup'
        operator: 'Equals'
        values: [
          '/subscriptions/df3b1809-17d0-47a0-9241-d2724780bdac/resourceGroups/rg-lz50-usva-wl01'
        ]
      }
    ]
    enabled: false
    actions: [
      {
        actionType: 'RemoveAllActionGroups'
      }
    ]
  }
}