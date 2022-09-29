// param publicIPAddressName string
// param location string

// resource publicIP 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
//   name: publicIPAddressName
//   location: location
//   sku: {
//     name: 'Standard'
//   }
//   properties: {
//     publicIPAllocationMethod: 'static'
//     publicIPAddressVersion: 'IPv4'
//     idleTimeoutInMinutes: 4
//   }
// }
// output publicIP string = publicIP.properties.ipAddress
// output publicIPId string = publicIP.id


param env string
param name string
param index string = ''
param publicIPPrefixId string = ''
param publicIPAllocationMethod string = 'Static'
param location string = resourceGroup().location
param publicIPName string

resource pip 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: publicIPName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
    // publicIPPrefix: publicIPPrefixId == ('') ? null : {
    //   id: publicIPPrefixId
    // }
    
  }
}

output properties object = {
  name: '${name}${index}-pip-${env}'
  location: location
  id: pip.id
  publicIPAllocationMethod: publicIPAllocationMethod
  publicIpPrefixId: publicIPPrefixId
}
