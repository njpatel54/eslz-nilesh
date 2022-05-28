param deploymentId string = substring(uniqueString(utcNow()),0,6)

// From Parameters File
param onboardmg string
param requireAuthorizationForGroupCreation bool
param managementGroups array
param subscriptions array
param tenantid string

targetScope = 'tenant'

// Create Management Groups
@batchSize(1)
resource resource_managementGroups 'Microsoft.Management/managementGroups@2021-04-01' = [for managementGroup in managementGroups: {
    name: managementGroup.name
    properties:{
        displayName: managementGroup.displayName
        details:{
            parent:{
                id: '/providers/Microsoft.Management/managementGroups/${managementGroup.parentMGName}'
            }
        }
    }    
}]


// Move Subscriptions to Management Groups
module movesubs 'movesub.bicep' = [for subscription in subscriptions: {
    name: 'deploy-movesubs-${subscription.subscriptionId}-${deploymentId}'
    dependsOn: resource_managementGroups
    params: {
        subscriptionId: subscription.subscriptionId
        managementGroupName:  subscription.managementGroupName
    }
}]


// Configure Default Management Group Settings

resource rootmg 'Microsoft.Management/managementGroups@2021-04-01' existing = {
    name: tenantid
}

resource mg_settings 'Microsoft.Management/managementGroups/settings@2021-04-01' = {
    parent: rootmg
    name: 'default'
    dependsOn: resource_managementGroups
    properties: {
        defaultManagementGroup: '/providers/Microsoft.Management/managementGroups/${onboardmg}'
        requireAuthorizationForGroupCreation: requireAuthorizationForGroupCreation
    }
}

