@description('The name of you Virtual Machine. and the number of vms')
param vmName string
param number_of_VMs int
param osUsed string //Getting the OS type from the user (Linux or Windows)
@description('Descripe the type of env')
param env string = 'stag'

@description('Username for the Virtual Machine.')
param adminUsername string
@description('Type of authentication to use on the Virtual Machine. SSH key is recommended.')
@allowed([
  // 'sshPublicKey'
  'password'
])
param authenticationType string = 'password'

@description('SSH Key or password for the Virtual Machine. SSH key is recommended.')
@secure()
param adminPasswordOrKey string

@description('Adding the appropriate OS to the machine')

var osVersion = osUsed == 'linux' ? '22_04-lts' : '2022-Datacenter'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The size of the VM')
param vmSize string = osUsed == 'windows' ? 'Standard_DS1_v2' : 'Standard_B2s'
@description('Name of the VNET')
param virtualNetworkName string = 'vNet'

@description('Name of the subnet in the virtual network')
param subnetName string = 'Subnet'

@description('Name of the Network Security Group')
param networkSecurityGroupName string = '${vmName}-nsg-${env}'
var publicIPAddressName = 'pip'
// var networkInterfaceName = 'nic'
var osDiskType = 'Standard_LRS'
param subnetAddressPrefix  string
param addressPrefix string

@description('Load Balancer params')
param creationDate string = utcNow('d')
module nsg 'nsg.bicep' = {
  name: networkSecurityGroupName
  params:{
    location: location
    securityRules: [
      {
        name: 'SSH'
        properties: {
          priority: 1000
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
    ]
    networkSecurityGroupName: networkSecurityGroupName
  }
  
}
module vnet 'vnet.bicep' = {
  name: '${vmName}-${virtualNetworkName}-${env}'
  params:{
    location: location
    addressPrefix: addressPrefix
    virtualNetworkName: '${vmName}-${virtualNetworkName}-${env}'
    subnetAddressPrefix: subnetAddressPrefix
    subnetName: '${vmName}-${subnetName}-${env}'

  }
}
//USE THIS TO CREATE PUBLIC IP PREFIX
// module pipPrefix 'publicipprefix.bicep' = {
//   name: '${vmName}-ippre-${env}'
//   params:{
//     name: '${vmName}-ippref-${env}' 
//     env: env
//     sku: 'Standard'
//     tier: 'Regional'
//     location:location
//   }
// }
// module publicIP 'publicIP.bicep' = [for i in range(1,number_of_VMs): {
//   name: '${vmName}${i}${publicIPAddressName}-${env}'
//   params:{
//     name: '${vmName}${i}${publicIPAddressName}-${env}'
//     env: env
//     publicIPName: '${vmName}${i}${publicIPAddressName}-${env}'
//     location:location
//     publicIPPrefixId:pipPrefix.outputs.properties.id
//     publicIPAllocationMethod: 'static'
//   }
// }]
module publicIP 'publicIP.bicep' = {
  name: '${vmName}${publicIPAddressName}-${env}'
  params:{
    location:location
    name: '${vmName}${publicIPAddressName}-${env}'
    env: env
    publicIPName: '${vmName}${publicIPAddressName}-${env}'
  }
  
}

module availabilitySet 'availabilitySet.bicep' = {
  name: '${vmName}-avail-${env}'
  params: {
    location:location
    env: env
    name: '${vmName}-avail-${env}'
    platformFaultDomainCount:2
    platformUpdateDomainCount:2
    sku:'Aligned'
  }
}

module vm 'vm.bicep' = [for i in range(1,number_of_VMs): {
  name:'${vmName}${i}-vm-${env}'
  params:{
    location:location
    osDiskType: osDiskType
    adminPass: adminPasswordOrKey
    OSVersion: osVersion
    vmName: '${vmName}${i}'
    index: '${i}'
    adminUsername: adminUsername
    publisher: osUsed =='windows' ? 'MicrosoftWindowsServer' : 'Canonical'
    env: env
    offer: osUsed == 'linux' ? '0001-com-ubuntu-server-jammy' : 'WindowsServer' 
    vmSize:vmSize
    snetname:vnet.outputs.subnet
    nsgID:nsg.outputs.nsgID
    snetID: vnet.outputs.snetID
    lbName:lb.name
    lbBackendName: lb.outputs.backendname
    avalibititySetID: availabilitySet.outputs.properties.id
    authenticationType: authenticationType
  }
  dependsOn:[
    lb
  ]
}]

module lb 'LB.bicep' = {
  scope: resourceGroup('haproxynextgen-rg-test')
  name: '${vmName}-LB-${env}'
  params: {
    name: '${vmName}-LB-${env}'
    backPool: '${vmName}-pool-${env}'
    creationDate: creationDate
    env: env
    location: location
    pipID: publicIP.outputs.properties.id
    sku: 'Standard'
    snetID: vnet.outputs.snetID
    tier: 'regional'
    vetnetID: vnet.outputs.properties.id
    number_of_VMs: number_of_VMs
    vmName: vmName
  }
}
output adminUsername string = adminUsername
// output sshCommand string = 'ssh ${adminUsername}@${publicIP.outputs.properties.id}'
