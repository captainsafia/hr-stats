using Microsoft.Azure.Functions.Worker.Builder;
using Microsoft.Extensions.Hosting;

var builder = FunctionsApplication.CreateBuilder(args);

builder.ConfigureFunctionsWebApplication();
builder.AddServiceDefaults();
builder.AddAzureTableClient("stats", configureSettings: settings =>
{
    // Workaround for https://github.com/dotnet/aspire/pull/8357
    settings.ServiceUri = new Uri(builder.Configuration["Aspire:Azure:Storage:Tables:stats:ServiceUri"]);
});

builder.Build().Run();
