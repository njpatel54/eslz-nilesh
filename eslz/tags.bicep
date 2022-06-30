targetScope = 'subscription'

param location string = 'USGovVirginia'
param ccsRgName string = 'ccs-rg'
param lzRgName string = 'lz01-rg'
param mgmtsubid string = 'aa2a513a-47e2-4a0d-8d39-0a3d5dd0f889'

var tags = json(loadTextContent('tags.json'))

@description('Required. utcfullvalue to be used in Tags.')
param utcfullvalue string = utcNow('F')

@description('Required. Assign utffullvaule to "CreatedOn" tag.')
param dynamictags object = ({
  CreatedOn: utcfullvalue
})

@description('Required. Combine Tags in dynamoctags object with Tags from parameter file.')
var ccsCombinedTags = union(dynamictags, tags.ccsTags.value)
var lzCombinedTags = union(dynamictags, tags.lz01Tags.value)

// Create Resoruce Group
module ccsRg 'modules/resourceGroups/deploy.bicep'= {
  name: 'rg-${take(uniqueString(deployment().name, location), 4)}-${ccsRgName}'
  scope: subscription(mgmtsubid)
  params: {
    name: ccsRgName
    location: location
    tags: ccsCombinedTags
  }
}

// Create Resoruce Group
module lzRg 'modules/resourceGroups/deploy.bicep'= {
  name: 'rg-${take(uniqueString(deployment().name, location), 4)}-${lzRgName}'
  scope: subscription(mgmtsubid)
  params: {
    name: lzRgName
    location: location
    tags: lzCombinedTags
  }
}
