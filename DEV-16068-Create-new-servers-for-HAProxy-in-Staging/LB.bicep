param location string
param sku string
param env string
param creationDate string
param tier string
param pipID string
param backPool string
param vetnetID string
param snetID string
param vmName string
param name string = '${vmName}-LB-${env}'

var LbFrontendIPConfigName = 'LbFrontendIPConfiguration'
param number_of_VMs int

// var VMrulesRdp = [for sIndex in range(0, number_of_VMs): {
//   name: 'RDP-${sIndex+1}-vm-${env}'
//   properties: {
//     frontendIPConfiguration: {
//       id: '${resourceId('Microsoft.Network/loadBalancers', name)}/frontendIpConfigurations/${LbFrontendIPConfigName}'
//     }
//     backendAddressPool: {
//       id: '${resourceId('Microsoft.Network/loadBalancers', name)}/backendAddressPools/${backPool}'
//     }
//     frontendPort: 33389+sIndex
//     backendPort: 3389
//     enableFloatingIP: false
//     idleTimeoutInMinutes: 4
//     protocol: 'Tcp'
//     enableTcpReset: false
//   }
// }]

var VMrulesPS = [for sIndex in range(0, number_of_VMs): {
    name: 'PSRemote-${sIndex+1}-vm-${env}'
    properties: {
      frontendIPConfiguration: {
        id: '${resourceId('Microsoft.Network/loadBalancers', name)}/frontendIpConfigurations/${LbFrontendIPConfigName}'
      }
      backendAddressPool: {
        id: '${resourceId('Microsoft.Network/loadBalancers', name)}/backendAddressPools/${backPool}'
      }
      frontendPort: 5986+sIndex
      backendPort: 5986
      enableFloatingIP: false
      idleTimeoutInMinutes: 4
      protocol: 'Tcp'
      enableTcpReset: false
    }
}]
// var SSH = [for sIndex in range(0, number_of_VMs): {
//   name: 'SSH-${sIndex+1}-vm-${env}'
//   properties: {
//     frontendIPConfiguration: {
//       id: '${resourceId('Microsoft.Network/loadBalancers', name)}/frontendIpConfigurations/${LbFrontendIPConfigName}'
//     }
//     backendAddressPool: {
//       id: '${resourceId('Microsoft.Network/loadBalancers', name)}/backendAddressPools/${backPool}'
//     }
//     frontendPort: 33381+sIndex
//     backendPort: 22
//     enableFloatingIP: false
//     idleTimeoutInMinutes: 4
//     protocol: 'Tcp'
//     enableTcpReset: false
//   }
// }]

var VMrulesDeploy = [for sIndex in range(0, number_of_VMs): {
  name: 'deploy-${sIndex+1}-vm-${env}'
  properties: {
    frontendIPConfiguration: {
      id: '${resourceId('Microsoft.Network/loadBalancers', name)}/frontendIpConfigurations/${LbFrontendIPConfigName}'
    }
    backendAddressPool: {
      id: '${resourceId('Microsoft.Network/loadBalancers', name)}/backendAddressPools/${backPool}'
    }
    frontendPort: 8172+sIndex
    backendPort: 8172
    enableFloatingIP: false
    idleTimeoutInMinutes: 4
    protocol: 'Tcp'
    enableTcpReset: true
  }
}]

var VMrulesOther = [
  {
    name: 'HA-Proxy'
    properties: {
      frontendIPConfiguration: {
        id: '${resourceId('Microsoft.Network/loadBalancers', name)}/frontendIpConfigurations/${LbFrontendIPConfigName}'
      }
      frontendPort: 33394
      backendPort: 8086
      enableFloatingIP: false
      idleTimeoutInMinutes: 4
      protocol: 'Tcp'
      enableTcpReset: false
    }
  }
]

var VMrules = concat(VMrulesPS, VMrulesDeploy, VMrulesOther)
resource lb 'Microsoft.Network/loadBalancers@2022-01-01' = {
  name: name
  sku: {
    name:sku
    tier: tier
  }
  location: location
  tags:{
      CreationDate: creationDate
      env: env
  }
  properties:{
   
    frontendIPConfigurations:[
      {
        name: LbFrontendIPConfigName

        properties:{
          privateIPAllocationMethod:'Dynamic'
          publicIPAddress:{
            id: pipID
          }
        }
      }
    ]
    backendAddressPools:[
      {
        name:backPool
        properties:{
          loadBalancerBackendAddresses:[
            {
              name: backPool
              properties:{
                loadBalancerFrontendIPConfiguration:{
                  id: '${resourceId('Microsoft.Network/loadBalancers', name)}/frontendIpConfigurations/${LbFrontendIPConfigName}'
                }
                virtualNetwork: {
                  id:vetnetID
                }
                subnet:{
                  id: snetID
                }

              }
            }
          ]
        }
      }
    ]
    probes: [
      {
        name: 'RDP-Alive'
        properties: {
          protocol: 'Tcp'
          port: 3389
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
      {
        name: 'HTTP-Alive'
        properties: {
          protocol: 'Tcp'
          port: 8086
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
    inboundNatRules: [for rule in VMrules: {
      name: rule.name
      properties: {
        frontendIPConfiguration: {
          id: rule.properties.frontendIPConfiguration.id
        }
        frontendPort: rule.properties.frontendPort
        backendPort: rule.properties.backendPort
        enableFloatingIP: rule.properties.enableFloatingIP
        idleTimeoutInMinutes: rule.properties.idleTimeoutInMinutes
        protocol: rule.properties.protocol
        enableTcpReset: rule.properties.enableTcpReset
        
      }
    }]
    outboundRules: [
      {
        name: 'Allow-All'
        properties: {
          allocatedOutboundPorts: 10664
          protocol: 'All'
          enableTcpReset: true
          idleTimeoutInMinutes: 4
          backendAddressPool: {
            id: '${resourceId('Microsoft.Network/loadBalancers', name)}/backendAddressPools/${backPool}'
          }
          frontendIPConfigurations: [
            {
              id: '${resourceId('Microsoft.Network/loadBalancers', name)}/frontendIpConfigurations/${LbFrontendIPConfigName}'
            }
          ]
        }
      }
    ]
  }
}
output backendname string = lb.properties.backendAddressPools[0].name
