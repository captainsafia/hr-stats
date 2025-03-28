@description('The location for the resource(s) to be deployed.')
param location string = resourceGroup().location

param function_identity_outputs_id string

param function_identity_outputs_clientid string

param funcstoragefeed4_outputs_blobendpoint string

param funcstoragefeed4_outputs_queueendpoint string

param funcstoragefeed4_outputs_tableendpoint string

param eventhub_outputs_eventhubsendpoint string

param storage_outputs_tableendpoint string

param outputs_azure_container_apps_environment_id string

param outputs_azure_container_registry_endpoint string

param outputs_azure_container_registry_managed_identity_id string

param function_containerimage string

resource function 'Microsoft.App/containerApps@2024-03-01' = {
  name: 'function'
  location: location
  properties: {
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: false
        targetPort: 8080
        transport: 'http'
      }
      registries: [
        {
          server: outputs_azure_container_registry_endpoint
          identity: outputs_azure_container_registry_managed_identity_id
        }
      ]
    }
    environmentId: outputs_azure_container_apps_environment_id
    template: {
      containers: [
        {
          image: function_containerimage
          name: 'function'
          env: [
            {
              name: 'OTEL_DOTNET_EXPERIMENTAL_OTLP_EMIT_EXCEPTION_LOG_ATTRIBUTES'
              value: 'true'
            }
            {
              name: 'OTEL_DOTNET_EXPERIMENTAL_OTLP_EMIT_EVENT_LOG_ATTRIBUTES'
              value: 'true'
            }
            {
              name: 'OTEL_DOTNET_EXPERIMENTAL_OTLP_RETRY'
              value: 'in_memory'
            }
            {
              name: 'ASPNETCORE_FORWARDEDHEADERS_ENABLED'
              value: 'true'
            }
            {
              name: 'FUNCTIONS_WORKER_RUNTIME'
              value: 'dotnet-isolated'
            }
            {
              name: 'AzureFunctionsJobHost__telemetryMode'
              value: 'OpenTelemetry'
            }
            {
              name: 'ASPNETCORE_URLS'
              value: 'http://+:8080'
            }
            {
              name: 'AzureWebJobsStorage__blobServiceUri'
              value: funcstoragefeed4_outputs_blobendpoint
            }
            {
              name: 'AzureWebJobsStorage__queueServiceUri'
              value: funcstoragefeed4_outputs_queueendpoint
            }
            {
              name: 'AzureWebJobsStorage__tableServiceUri'
              value: funcstoragefeed4_outputs_tableendpoint
            }
            {
              name: 'Aspire__Azure__Storage__Blobs__AzureWebJobsStorage__ServiceUri'
              value: funcstoragefeed4_outputs_blobendpoint
            }
            {
              name: 'Aspire__Azure__Storage__Queues__AzureWebJobsStorage__ServiceUri'
              value: funcstoragefeed4_outputs_queueendpoint
            }
            {
              name: 'Aspire__Azure__Storage__Tables__AzureWebJobsStorage__ServiceUri'
              value: funcstoragefeed4_outputs_tableendpoint
            }
            {
              name: 'heartrate__fullyQualifiedNamespace'
              value: eventhub_outputs_eventhubsendpoint
            }
            {
              name: 'Aspire__Azure__Messaging__EventHubs__EventHubProducerClient__heartrate__FullyQualifiedNamespace'
              value: eventhub_outputs_eventhubsendpoint
            }
            {
              name: 'Aspire__Azure__Messaging__EventHubs__EventHubConsumerClient__heartrate__FullyQualifiedNamespace'
              value: eventhub_outputs_eventhubsendpoint
            }
            {
              name: 'Aspire__Azure__Messaging__EventHubs__EventProcessorClient__heartrate__FullyQualifiedNamespace'
              value: eventhub_outputs_eventhubsendpoint
            }
            {
              name: 'Aspire__Azure__Messaging__EventHubs__PartitionReceiver__heartrate__FullyQualifiedNamespace'
              value: eventhub_outputs_eventhubsendpoint
            }
            {
              name: 'Aspire__Azure__Messaging__EventHubs__EventHubBufferedProducerClient__heartrate__FullyQualifiedNamespace'
              value: eventhub_outputs_eventhubsendpoint
            }
            {
              name: 'Aspire__Azure__Messaging__EventHubs__EventHubProducerClient__heartrate__EventHubName'
              value: 'heartrate'
            }
            {
              name: 'Aspire__Azure__Messaging__EventHubs__EventHubConsumerClient__heartrate__EventHubName'
              value: 'heartrate'
            }
            {
              name: 'Aspire__Azure__Messaging__EventHubs__EventProcessorClient__heartrate__EventHubName'
              value: 'heartrate'
            }
            {
              name: 'Aspire__Azure__Messaging__EventHubs__PartitionReceiver__heartrate__EventHubName'
              value: 'heartrate'
            }
            {
              name: 'Aspire__Azure__Messaging__EventHubs__EventHubBufferedProducerClient__heartrate__EventHubName'
              value: 'heartrate'
            }
            {
              name: 'stats__tableServiceUri'
              value: storage_outputs_tableendpoint
            }
            {
              name: 'Aspire__Azure__Storage__Tables__stats__ServiceUri'
              value: storage_outputs_tableendpoint
            }
            {
              name: 'AZURE_CLIENT_ID'
              value: function_identity_outputs_clientid
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
      }
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${function_identity_outputs_id}': { }
      '${outputs_azure_container_registry_managed_identity_id}': { }
    }
  }
}