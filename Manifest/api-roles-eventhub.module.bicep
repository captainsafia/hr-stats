@description('The location for the resource(s) to be deployed.')
param location string = resourceGroup().location

param eventhub_outputs_name string

param principalId string

resource eventhub 'Microsoft.EventHub/namespaces@2024-01-01' existing = {
  name: eventhub_outputs_name
}

resource eventhub_AzureEventHubsDataSender 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(eventhub.id, principalId, subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '2b629674-e913-4c01-ae53-ef4638d8f975'))
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '2b629674-e913-4c01-ae53-ef4638d8f975')
    principalType: 'ServicePrincipal'
  }
  scope: eventhub
}