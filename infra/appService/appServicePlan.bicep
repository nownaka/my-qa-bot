/*============================================================================
  Parameters
============================================================================*/
param location string
param name string
param sku string

/*============================================================================
  Resources
============================================================================*/
resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: name
  location: location
  kind: 'app'
  properties: {
    reserved: true
  }
  sku: {
    name: sku
  }
}

/*============================================================================
  Outputs
============================================================================*/
output id string = appServicePlan.id
output name string = appServicePlan.name
output sku string = appServicePlan.sku.name
