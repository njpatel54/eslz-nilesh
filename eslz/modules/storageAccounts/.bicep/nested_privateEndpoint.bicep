param privateEndpointResourceId string
param privateEndpointVnetLocation string
param privateEndpointObj object
param tags object

var privateEndpointResourceName = last(split(privateEndpointResourceId, '/'))
var privateEndpointVar = {
  name: (contains(privateEndpointObj, 'name') ? (empty(privateEndpointObj.name) ? '${privateEndpointResourceName}-${privateEndpointObj.service}' : privateEndpointObj.name) : '${privateEndpointResourceName}-${privateEndpointObj.service}')
  subnetResourceId: privateEndpointObj.subnetResourceId
  service: [
    privateEndpointObj.service
  ]
  privateDnsZoneResourceIds: (contains(privateEndpointObj, 'privateDnsZoneResourceIds') ? ((empty(privateEndpointObj.privateDnsZoneResourceIds) ? [] : privateEndpointObj.privateDnsZoneResourceIds)) : [])
  customDnsConfigs: (contains(privateEndpointObj, 'customDnsConfigs') ? (empty(privateEndpointObj.customDnsConfigs) ? null : privateEndpointObj.customDnsConfigs) : null)
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointVar.name
  location: privateEndpointVnetLocation
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: privateEndpointVar.name
        properties: {
          privateLinkServiceId: privateEndpointResourceId
          groupIds: privateEndpointVar.service
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    subnet: {
      id: privateEndpointVar.subnetResourceId
    }
    customDnsConfigs: privateEndpointVar.customDnsConfigs
  }

  resource privateDnsZoneGroups 'privateDnsZoneGroups@2021-02-01' = {
    name: 'default'
    properties: {
      privateDnsZoneConfigs: [for privateDnsZoneResourceId in privateEndpointVar.privateDnsZoneResourceIds: {
        name: last(split(privateDnsZoneResourceId, '/'))
        properties: {
          privateDnsZoneId: privateDnsZoneResourceId
        }
      }]
    }
  }
}
