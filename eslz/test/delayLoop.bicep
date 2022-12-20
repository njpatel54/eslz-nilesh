param counter int = 5

var locationSettings = {
  westeurope: {
    abbreviation: 'weu'
  }
  switzerlandnorth: {
    abbreviation: 'chn'
  }
  eastus2: {
    abbreviation: 'eus2'
  }
  eastasia: {
    abbreviation: 'ea'
  }
}
var rgName = 'rg-delay-${locationSettings[resourceGroup().location].abbreviation}'

module DelayDeployment_rg './nested_DelayDeployment_rg.bicep' = {
  name: 'DelayDeployment--${rgName}'
  scope: resourceGroup(rgName)
  params: {
    counter: counter
  }
}