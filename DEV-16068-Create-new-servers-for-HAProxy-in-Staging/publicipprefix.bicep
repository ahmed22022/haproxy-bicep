param sku string
param tier string
param env string
param name string
param location string = resourceGroup().location
param creationDate string = utcNow('d')

resource pipPrefix 'Microsoft.Network/publicIPPrefixes@2022-01-01' = {
  name: name
  location: location
  tags: {
    CreationDate: creationDate
    env: env
  }
  sku: {
    name: sku
    tier: tier
  }
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    prefixLength: 31
    publicIPAddressVersion: 'IPv4'
    ipTags: []
  }
}

output properties object = {
  name: '${name}-pipp-${env}'
  location: location
  id: pipPrefix.id
}
