using Azure.Provisioning.EventHubs;
using Azure.Provisioning.Storage;

var builder = DistributedApplication.CreateBuilder(args);

// Needed to support role assignments
builder.AddAzureContainerAppsInfrastructure();

// Event hub for streaming heart rate data
var eventHubs = builder.AddAzureEventHubs("eventhub");
var hub = eventHubs.AddHub("heartrate");

// Azure Storage tables for saving averages and highs/lows
var storage = builder.AddAzureStorage("storage");
var stats = storage.AddTables("stats");

// Azure Functions reads heart rate data from the event hub and
// writes to the storage tables
builder.AddAzureFunctionsProject<Projects.Function>("function")
    .WithReference(hub)
    .WithReference(stats)
    .WithRoleAssignments(eventHubs, EventHubsBuiltInRole.AzureEventHubsDataReceiver)
    .WithRoleAssignments(storage, StorageBuiltInRole.StorageTableDataContributor);

// API service pushes heart rate data to the event hub
// and reads stats from the storage tables
builder.AddProject<Projects.Api>("api")
    .WithExternalHttpEndpoints()
    .WithReference(hub)
    .WithReference(stats)
    .WithRoleAssignments(storage, StorageBuiltInRole.StorageTableDataReader)
    .WithRoleAssignments(eventHubs, EventHubsBuiltInRole.AzureEventHubsDataSender);

builder.Build().Run();
