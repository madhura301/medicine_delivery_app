using System.Net.Http;
using MedicineDelivery.IntegrationTests.Infrastructure;

namespace MedicineDelivery.IntegrationTests.Support;

public class TestContext
{
    public HttpClient Client { get; set; } = null!;
    public TestWebApplicationFactory Factory { get; set; } = null!;
    public HttpResponseMessage? LastResponse { get; set; }
    public string? AuthToken { get; set; }
}

