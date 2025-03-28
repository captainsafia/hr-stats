@description('The location for the resource(s) to be deployed.')
param location string = resourceGroup().location

param eventhub_outputs_name string

param principalId string

resource eventhub 'Microsoft.EventHub/namespaces@2024-01-01' existing = {
  name: eventhub_outputs_name
}

resource eventhub_AzureEventHubsDataReceiver 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(eventhub.id, principalId, subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'a638d3c7-ab3a-418d-83e6-5f17a39d4fde'))
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'a638d3c7-ab3a-418d-83e6-5f17a39d4fde')
    principalType: 'ServicePrincipal'
  }
  scope: eventhub
}