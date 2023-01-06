@description('The name of the Managed Cluster resource.')
param clusterName string

@description('The location of the Managed Cluster resource.')
param location string = resourceGroup().location

@description('Optional DNS prefix to use with hosted Kubernetes API server FQDN.')
param dnsPrefix string = clusterName

@description('The location of the Managed Cluster resource.')
param k8sversion string = '1.24.6'

@description('Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0


@description('The minimum number of nodes for the system nodepool of cluster.')
@minValue(1)
@maxValue(50)
param sysMinNodeCount int = 1

@description('The maximumn number of nodes for the system nodepool of cluster.')
@minValue(1)
@maxValue(50)
param sysMaxNodeCount int = 2

@description('The minimum number of nodes for the user nodepool of cluster.')
@minValue(1)
@maxValue(50)
param userMinNodeCount int = 1

@description('The maximumn number of nodes for the user nodepool of cluster.')
@minValue(1)
@maxValue(50)
param userMaxNodeCount int = 4

@description('The size of the Virtual Machine.')
param agentVMSize string = 'Standard_A4_v2'

@description('User name for the Linux Virtual Machines.')
param linuxAdminUsername string = 'azureuser'

@description('Configure all linux machines with the SSH RSA public key string. Your key should include three parts, for example \'ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm\'')
param sshRSAPublicKey string

resource aks 'Microsoft.ContainerService/managedClusters@2022-09-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: dnsPrefix
    kubernetesVersion: k8sversion
    agentPoolProfiles: [
      {
        name: 'system'
        osDiskSizeGB: osDiskSizeGB
        count: sysMinNodeCount
        enableAutoScaling:true
        minCount: sysMinNodeCount
        maxCount: sysMaxNodeCount
        vmSize: agentVMSize
        osType: 'Linux'
        mode: 'System'
      }
      {
        name: 'user'
        osDiskSizeGB: osDiskSizeGB
        count: userMinNodeCount
        enableAutoScaling:true
        minCount: userMinNodeCount
        maxCount: userMaxNodeCount
        vmSize: agentVMSize
        osType: 'Linux'
        mode: 'user'
      }
    ]
    linuxProfile: {
      adminUsername: linuxAdminUsername
      ssh: {
        publicKeys: [
          {
            keyData: sshRSAPublicKey
          }
        ]
      }
    }
    networkProfile: {
      networkPlugin: 'none'
    }
  }
}

output controlPlaneFQDN string = aks.properties.fqdn
