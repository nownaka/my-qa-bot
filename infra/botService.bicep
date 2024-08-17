/*============================================================================
  Parameters
============================================================================*/
param location string = 'global'
param name string
param displayName string
param botAppDomain string
param endpoint string = 'https://${botAppDomain}/api/messages'
param msaAppId string
param msaAppMSIResourceId string?
param msaAppType string = 'UserAssignedMSI'
param sku string
param msaAppTenantId string = tenant().tenantId

/*============================================================================
  Resources
============================================================================*/
resource botService 'Microsoft.BotService/botServices@2021-03-01' = {
  kind: 'azurebot'
  location: location
  name: name
  properties: {
    displayName: displayName
    endpoint: endpoint
    msaAppType: msaAppType
    msaAppId: msaAppId
    msaAppMSIResourceId: msaAppMSIResourceId
    msaAppTenantId: msaAppTenantId
  }
  sku: {
    name: sku
  }
}
