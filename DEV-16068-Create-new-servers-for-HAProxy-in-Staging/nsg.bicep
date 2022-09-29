param networkSecurityGroupName string
param location string
param securityRules array


resource nsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: securityRules
  }
}

output nsgID string = nsg.id
