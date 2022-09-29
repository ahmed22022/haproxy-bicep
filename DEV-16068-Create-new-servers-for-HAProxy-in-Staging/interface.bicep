param location string
param env string
param ipConfigName string
param sNetName string
param privateIPAllocationMethod string = 'Dynamic'
param nsgId string
param index string
param name string
param snetID string
param lbBackendName string
param lbName string

resource nic 'Microsoft.Network/networkInterfaces@2022-01-01' = {
  name: '${name}${index}-nic-${env}'
  location: location
  properties: {

    ipConfigurations: [
      {
        name: ipConfigName
        properties: {
          loadBalancerBackendAddressPools:[
            {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, lbBackendName)
            }
          ]
          subnet: {
            name:sNetName
            id: snetID
          }
          privateIPAllocationMethod: privateIPAllocationMethod
          
        }
      
      }
    ]
    networkSecurityGroup: {
      id: nsgId
    }
  }
}
output nicID string = nic.id

output nicName string = nic.name
