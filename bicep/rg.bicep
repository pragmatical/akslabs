targetScope = 'subscription'

param RG_Name string = 'rg-k6labs'
@description('AKS Service, Node Pool, and supporting services (KeyVault, App Gateway, etc) region. This needs to be the same region as the vnet provided in these parameters.')
@allowed([
  'centralus'
  'eastus'
  'westus3'
])
param location string = 'westus3'

resource bicepRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: RG_Name
  location: location
}
