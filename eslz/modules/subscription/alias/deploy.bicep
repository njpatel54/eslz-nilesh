targetScope = 'managementGroup'

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// "billingScope" -	Billing scope of the subscription.                                                                                              //
// For CustomerLed and FieldLed - /billingAccounts/{billingAccountName}/billingProfiles/{billingProfileName}/invoiceSections/{invoiceSectionName}   //
// For PartnerLed - /billingAccounts/{billingAccountName}/customers/{customerName}                                                                  //
// For Legacy EA - /billingAccounts/{billingAccountName}/enrollmentAccounts/{enrollmentAccountName}                                                 //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@description('EnrollmentAccount used for subscription billing')
param enrollmentAccount string

@description('BillingAccount used for subscription billing')
param billingAccount string

@description('Alias to assign to the subscription')
param subscriptionAlias string

@description('Display name for the subscription')
param subscriptionDisplayName string

@description('Workload type for the subscription')
param subscriptionWorkload string

@description('Management Group target for the subscription')
param managementGroupId string

@description('Subscription Owner Id for the subscription')
param subscriptionOwnerId string

@description('Optional. Tags of the storage account resource.')
param tags object = {}

resource alias 'Microsoft.Subscription/aliases@2021-10-01' = {
  scope: tenant()
  name: subscriptionAlias
  properties: {
    additionalProperties: {
      managementGroupId: managementGroupId
      subscriptionOwnerId: subscriptionOwnerId
      tags: tags
    }
    workload: subscriptionWorkload
    displayName: subscriptionDisplayName
    billingScope: tenantResourceId('Microsoft.Billing/billingAccounts/enrollmentAccounts', billingAccount, enrollmentAccount)
  }
}

output subscriptionId string = alias.properties.subscriptionId
