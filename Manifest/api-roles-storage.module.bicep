@description('The location for the resource(s) to be deployed.')
param location string = resourceGroup().location

param storage_outputs_name string

param principalId string

resource storage 'Microsoft.Storage/storageAccounts@2024-01-01' existing = {
  name: storage_outputs_name
}

resource storage_StorageTableDataReader 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storage.id, principalId, subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '76199698-9eea-4c19-bc75-cec21354c6b6'))
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '76199698-9eea-4c19-bc75-cec21354c6b6')
    principalType: 'ServicePrincipal'
  }
  scope: storage
}