targetScope = 'managementGroup'

@description('subscriptionId for the deployment')
param subscriptionId string

@description('Location for the deployments and the resources')
param location string

@description('Required. Array containing Budgets.')
param budgets array

// 1. Create Budget
module budget '../../modules/consumption/budgets/deploy.bicep' = [for (budget, i) in budgets: {
  name: 'budget-${take(uniqueString(deployment().name, location), 4)}-${i}'
  scope: subscription(subscriptionId)
  params: {
    name: '${budget.resetPeriod}-${budget.category}-Budget'
    amount: budget.amount
    category: budget.category
    resetPeriod: budget.resetPeriod
    thresholds: budget.thresholds
    contactEmails: budget.contactEmails
  }
}]
