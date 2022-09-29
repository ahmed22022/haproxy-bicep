param subnetName string
param subnetAddressPrefix string
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' = {
  name: subnetName
  properties: {
    addressPrefix: subnetAddressPrefix
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

output snetPrefix string = subnet.properties.addressPrefix
output snetID string = subnet.id
output subnet string = subnet.name
