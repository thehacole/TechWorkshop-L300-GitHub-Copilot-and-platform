@description('Name of the Azure AI Foundry (AI Services) resource')
param name string

@description('Azure region for all resources')
param location string = resourceGroup().location

@description('Resource tags')
param tags object = {}

resource aiFoundry 'Microsoft.CognitiveServices/accounts@2024-04-01-preview' = {
  name: name
  location: location
  tags: tags
  kind: 'AIServices'
  sku: {
    name: 'S0'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    customSubDomainName: name
  }
}

resource gpt4Deployment 'Microsoft.CognitiveServices/accounts/deployments@2024-04-01-preview' = {
  parent: aiFoundry
  name: 'gpt-4'
  sku: {
    name: 'Standard'
    capacity: 10
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4'
      version: '0613'
    }
  }
}

resource phiDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-04-01-preview' = {
  parent: aiFoundry
  name: 'phi-3'
  dependsOn: [gpt4Deployment]
  sku: {
    name: 'Standard'
    capacity: 10
  }
  properties: {
    model: {
      format: 'Microsoft'
      name: 'Phi-3-mini-4k-instruct'
      version: '4'
    }
  }
}

output foundryId string = aiFoundry.id
output foundryName string = aiFoundry.name
output endpoint string = aiFoundry.properties.endpoint
