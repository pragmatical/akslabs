@description('The name of the Managed Cluster resource.')
param name string

@description('The location of the Managed Cluster resource.')
param location string = resourceGroup().location

resource symbolicname 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: name
  location: location
  sku: {
    name: 'StandardLRS'
  }
  kind: 'StorageV2'
}
