@description('The location for the resource(s) to be deployed.')
param location string = resourceGroup().location

param sku string = 'Standard'

resource eventhub 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: take('eventhub-${uniqueString(resourceGroup().id)}', 256)
  location: location
  sku: {
    name: sku
  }
  tags: {
    'aspire-resource-name': 'eventhub'
  }
}

resource heartrate 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  name: 'heartrate'
  parent: eventhub
}

output eventHubsEndpoint string = eventhub.properties.serviceBusEndpoint

output name string = eventhub.name