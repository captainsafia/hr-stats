using System.Runtime.CompilerServices;
using Azure;
using Azure.Data.Tables;
using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Producer;

var builder = WebApplication.CreateBuilder(args);

builder.AddServiceDefaults();
builder.AddAzureEventHubProducerClient("heartrate");
builder.AddAzureTableClient("stats");

var app = builder.Build();

app.MapGet("/", (CancellationToken cancellationToken, EventHubProducerClient client) =>
{
    async IAsyncEnumerable<string> GetHeartRate(
        [EnumeratorCancellation] CancellationToken cancellationToken)
    {
        while (!cancellationToken.IsCancellationRequested)
        {
            var heartRate = Random.Shared.Next(60, 100);
            var eventData = new EventData(new BinaryData(heartRate.ToString()));
            await client.SendAsync([eventData], cancellationToken: cancellationToken);
            yield return $"Hear Rate: {heartRate} bpm";
            await Task.Delay(2000, cancellationToken);
        }
    }

    return TypedResults.ServerSentEvents(GetHeartRate(cancellationToken), eventType: "heartRate");
});

app.MapGet("/stats", async (CancellationToken cancellationToken, TableServiceClient client) =>
{
    var tableClient = client.GetTableClient("stats");
    await tableClient.CreateIfNotExistsAsync(cancellationToken: cancellationToken);
    var response = await tableClient.GetEntityAsync<HeartRateMetricsEntity>("Metrics", "Latest", cancellationToken: cancellationToken);
    return TypedResults.Ok(response.Value);
});

app.Run();


internal class HeartRateMetricsEntity : ITableEntity
{
    public required string PartitionKey { get; set; }
    public required string RowKey { get; set; }
    public DateTimeOffset? Timestamp { get; set; }
    public ETag ETag { get; set; }
    
    // Rolling metrics
    public double RollingAverage { get; set; }
    public int High { get; set; }
    public int Low { get; set; }
    public int Count { get; set; }
}