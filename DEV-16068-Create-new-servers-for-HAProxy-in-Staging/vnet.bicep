param virtualNetworkName string
param location string
param addressPrefix string
param subnetName string
param subnetAddressPrefix string

resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' = {
  parent: vnet
  name: subnetName
  properties: {
    addressPrefix: subnetAddressPrefix
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

output properties object = {
  name: virtualNetworkName
  location: location
  id: vnet.id
  subnets: vnet.properties.subnets
}
output snetPrefix string = subnet.properties.addressPrefix
output snetID string = subnet.id
output subnet string = subnet.name
