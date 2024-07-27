/*============================================================================
  Parameters
============================================================================*/
param location string = 'global'
param name string
param displayName string
param botAppDomain string
param entraAppClientId string
param sku string

/*============================================================================
  Resources
============================================================================*/
resource botService 'Microsoft.BotService/botServices@2021-03-01' = {
  kind: 'azurebot'
  location: location
  name: name
  properties: {
    displayName: displayName
    endpoint: 'https://${botAppDomain}/api/messages'
    msaAppId: entraAppClientId
  }
  sku: {
    name: sku
  }
}
