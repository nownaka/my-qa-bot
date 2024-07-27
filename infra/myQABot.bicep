/*============================================================================
  Parameters
============================================================================*/
param location string = resourceGroup().location
param systemName string
param environment string
param suffix string

// app service plan
param appServicePlanName string = 'asp-${systemName}-${suffix}'
param appServicePlanSku string = 'F1'

// web app
param webAppName string = 'app-${systemName}-${suffix}'

// bot service
param botName string = 'bot-${systemName}-${environment}-${suffix}'
param botDisplayName string
param botSku string = 'F0'
param entraAppClientId string

// User Assigned Identity
param userAssignedIdentityName string = 'id-${systemName}-${environment}-${suffix}'

/*============================================================================
  Resources
============================================================================*/
// app service plan
module appServicePlan './appService/appServicePlan.bicep' = {
  name: 'Deploy_${appServicePlanName}'
  params: {
    name: appServicePlanName
    location: location
    sku: appServicePlanSku
  }
}

// web app
module webApp './appService/webApp.bicep' = {
  name: 'Deploy_${webAppName}'
  params: {
    name: webAppName
    location: location
    appServicePlanId: appServicePlan.outputs.id
    userAssignedIdentityId: userAssignedIdentity.outputs.id
  }
}

// bot service
module botService 'botService.bicep' = {
  name: 'Deploy_${botName}'
  params: {
    name: botName
    botAppDomain: webApp.outputs.defaultHostName
    displayName: botDisplayName
    entraAppClientId: entraAppClientId
    sku: botSku
  }
}

// User Assigned Identity
module userAssignedIdentity 'userAssignedIdentity.bicep' = {
  name: 'Deploy_${userAssignedIdentityName}'
  params: {
    name: userAssignedIdentityName
    location: location
  }
}
