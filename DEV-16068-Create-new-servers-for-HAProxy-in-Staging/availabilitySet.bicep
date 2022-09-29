param env string
param name string
param location string = resourceGroup().location
param sku string = 'Aligned'
param platformFaultDomainCount int = 3
param platformUpdateDomainCount int = 6

resource availSet 'Microsoft.Compute/availabilitySets@2021-07-01' = {
  name: '${name}-avail-${env}'
  location: location
  sku:{
     name: sku
  }
  properties: {
     platformFaultDomainCount: platformFaultDomainCount
     platformUpdateDomainCount: platformUpdateDomainCount
  }
}

output properties object = {
  name: '${name}-avail-${env}'
  location: location
  sku: sku
  id: availSet.id
  platformFaultDomainCount: platformFaultDomainCount
  platformUpdateDomainCount: platformUpdateDomainCount
}
