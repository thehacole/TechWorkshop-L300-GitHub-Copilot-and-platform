@description('Environment name (e.g. dev, staging, prod)')
param environmentName string = 'dev'

@description('Azure region for all resources')
param location string = 'westus3'

@description('Application name used for resource naming')
param appName string = 'zavastorefront'

@description('Container image to deploy to App Service')
param containerImage string = 'mcr.microsoft.com/appsvc/staticsite:latest'

var tags = {
  environment: environmentName
  application: appName
  managedBy: 'azd'
}

var resourceNames = {
  appServicePlan: 'asp-${appName}-${environmentName}'
  appService: 'app-${appName}-${environmentName}'
  acr: 'acr${appName}${environmentName}'
  appInsights: 'appi-${appName}-${environmentName}'
  logAnalyticsWorkspace: 'law-${appName}-${environmentName}'
  foundry: 'foundry-${appName}-${environmentName}'
}

// ACR login server is always <name>.azurecr.io – compute it without a circular reference
var acrLoginServer = '${resourceNames.acr}.azurecr.io'

// Application Insights and Log Analytics Workspace
module appInsights 'app-insights.bicep' = {
  name: 'appInsightsDeploy'
  params: {
    name: resourceNames.appInsights
    logAnalyticsWorkspaceName: resourceNames.logAnalyticsWorkspace
    location: location
    tags: tags
  }
}

// App Service Plan and Linux Web App with system-assigned managed identity
module appService 'app-service.bicep' = {
  name: 'appServiceDeploy'
  params: {
    planName: resourceNames.appServicePlan
    appName: resourceNames.appService
    location: location
    tags: tags
    appInsightsConnectionString: appInsights.outputs.connectionString
    appInsightsInstrumentationKey: appInsights.outputs.instrumentationKey
    acrLoginServer: acrLoginServer
    containerImage: containerImage
  }
}

// Azure Container Registry with AcrPull role for App Service MSI
module acr 'acr.bicep' = {
  name: 'acrDeploy'
  params: {
    name: resourceNames.acr
    location: location
    tags: tags
    appServicePrincipalId: appService.outputs.appServicePrincipalId
  }
}

// Azure AI Foundry with GPT-4 and Phi model deployments
module foundry 'foundry.bicep' = {
  name: 'foundryDeploy'
  params: {
    name: resourceNames.foundry
    location: location
    tags: tags
  }
}

output appServiceUrl string = 'https://${appService.outputs.defaultHostName}'
output acrLoginServer string = acr.outputs.loginServer
output appInsightsName string = appInsights.outputs.appInsightsName
output foundryEndpoint string = foundry.outputs.endpoint

