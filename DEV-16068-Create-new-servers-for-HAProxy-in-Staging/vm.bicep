@description('General params')
param vmName string 
param index string
param env string
param adminUsername string
param publisher string
param offer string
param osDiskType string
param snetname string
param nsgID string
param snetID string
param lbName string
param lbBackendName string
param avalibititySetID string
param authenticationType string

param adminPass string
param OSVersion string
param location string = resourceGroup().location
param vmSize string = 'Standard_B2s'

@description('Virtual machine resource')
resource vm 'Microsoft.Compute/virtualMachines@2022-03-01' = {
    name: '${vmName}${index}-vm-${env}'
    location: location
    properties: {
      hardwareProfile: {
        vmSize: vmSize
      }
      storageProfile: {
        osDisk: {
          createOption: 'FromImage'
          managedDisk: {
            storageAccountType: osDiskType
          }
        }
        imageReference: {
          publisher: publisher
          offer: offer
          sku: OSVersion
          version: 'latest'
        }
      }
      availabilitySet:{
        id:avalibititySetID
      }
      networkProfile: {
        networkInterfaces: [
          {
            id: networkInterface.outputs.nicID
          }
        ]
      }
      osProfile: {
        computerName: vmName
        adminUsername: adminUsername
        adminPassword: adminPass
      }
    }
  }
 

module networkInterface 'interface.bicep' = {
  name: '${vmName}-nic-${env}'
  params:{
    name: vmName
    location: location
    nsgId: nsgID
    sNetName: snetname
    ipConfigName: '${vmName}-ipconfig-${index}'
    env: env
    index:index
    privateIPAllocationMethod:'dynamic'
    snetID: snetID
    lbName: lbName
    lbBackendName: lbBackendName
  }
}



