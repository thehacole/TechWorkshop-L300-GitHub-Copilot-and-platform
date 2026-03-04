@description('Name of the Azure Container Registry')
param name string

@description('Azure region for all resources')
param location string = resourceGroup().location

@description('Resource tags')
param tags object = {}

@description('Principal ID of the App Service managed identity to grant AcrPull role')
param appServicePrincipalId string

// AcrPull built-in role definition ID
var acrPullRoleDefinitionId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '7f951dda-4ed3-4680-a7ca-43fe172d538d'
)

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Enabled'
  }
}

resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistry.id, appServicePrincipalId, acrPullRoleDefinitionId)
  scope: containerRegistry
  properties: {
    roleDefinitionId: acrPullRoleDefinitionId
    principalId: appServicePrincipalId
    principalType: 'ServicePrincipal'
  }
}

output acrId string = containerRegistry.id
output acrName string = containerRegistry.name
output loginServer string = containerRegistry.properties.loginServer
