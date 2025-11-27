using Microsoft.Extensions.Configuration;

namespace MedicineDelivery.IntegrationTests.Support;

public class TestConfiguration
{
    private static readonly Lazy<TestConfiguration> _instance = new(() => new TestConfiguration());
    public static TestConfiguration Instance => _instance.Value;

    public bool UseExternalApi { get; }
    public string ExternalApiBaseUrl { get; }

    private TestConfiguration()
    {
        var builder = new ConfigurationBuilder()
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true)
            .AddEnvironmentVariables();

        var configuration = builder.Build();

        // Check environment variable first (takes precedence), then appsettings.json
        var useExternalApiEnv = Environment.GetEnvironmentVariable("USE_EXTERNAL_API");
        UseExternalApi = useExternalApiEnv != null 
            ? bool.Parse(useExternalApiEnv) 
            : configuration.GetValue<bool>("TestSettings:UseExternalApi", false);

        var externalApiUrlEnv = Environment.GetEnvironmentVariable("EXTERNAL_API_BASE_URL");
        ExternalApiBaseUrl = externalApiUrlEnv ?? 
            configuration.GetValue<string>("TestSettings:ExternalApiBaseUrl") ?? 
            "http://localhost:5000";
    }
}


