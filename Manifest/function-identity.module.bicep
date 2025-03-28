@description('The location for the resource(s) to be deployed.')
param location string = resourceGroup().location

resource function_identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: take('function_identity-${uniqueString(resourceGroup().id)}', 128)
  location: location
}

output id string = function_identity.id

output clientId string = function_identity.properties.clientId

output principalId string = function_identity.properties.principalId

output principalName string = function_identity.name