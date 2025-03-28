using Azure;
using Azure.Data.Tables;
using Microsoft.Extensions.Logging;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.DependencyInjection;

public class ProcessHeartRateFunction(TableServiceClient client, ILogger<ProcessHeartRateFunction> logger)
{
    [Function("ProcessHeartRate")]
    public async Task Run(
        [EventHubTrigger("heartrate", Connection = "heartrate")] string[] events)
    { 
        var tableClient = client.GetTableClient("stats");
        await tableClient.CreateIfNotExistsAsync();
        foreach (string eventData in events)
        {
            try
            {
                // Decode the heart rate value from the event.
                if (!int.TryParse(eventData, out int heartRate))
                {
                    logger.LogWarning("Invalid heart rate value: {Message}", eventData);
                    continue;
                }

                // We'll use a fixed partition and row key to store rolling metrics.
                string partitionKey = "Metrics";
                string rowKey = "Latest";

                HeartRateMetricsEntity entity;
                try
                {
                    // Attempt to retrieve the existing metrics.
                    var response = await tableClient.GetEntityAsync<HeartRateMetricsEntity>(partitionKey, rowKey);
                    entity = response.Value;
                }
                catch (RequestFailedException ex) when (ex.Status == 404)
                {
                    // If no record exists, create a new one.
                    entity = new HeartRateMetricsEntity
                    {
                        PartitionKey = partitionKey,
                        RowKey = rowKey,
                        RollingAverage = 0,
                        High = heartRate,
                        Low = heartRate,
                        Count = 0
                    };
                }

                // Update the rolling metrics.
                entity.Count++;
                // Calculate new rolling average.
                entity.RollingAverage = ((entity.RollingAverage * (entity.Count - 1)) + heartRate) / entity.Count;
                entity.High = Math.Max(entity.High, heartRate);
                entity.Low = Math.Min(entity.Low, heartRate);

                // Upsert (insert or update) the entity in the table.
                await tableClient.UpsertEntityAsync(entity);
                logger.LogInformation("Processed heart rate {HeartRate}. Updated metrics: Avg: {Avg}, High: {High}, Low: {Low}", heartRate, entity.RollingAverage, entity.High, entity.Low);
            }
            catch (Exception ex)
            {
                logger.LogError("Error processing event: {Message}", ex.Message);
            }
        }
    }
}

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