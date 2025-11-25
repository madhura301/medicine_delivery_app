using System.Net.Http;
using MedicineDelivery.IntegrationTests.Infrastructure;

namespace MedicineDelivery.IntegrationTests.Support;

public class TestContext
{
    public HttpClient Client { get; set; } = null!;
    public TestWebApplicationFactory? Factory { get; set; }
    public HttpResponseMessage? LastResponse { get; set; }
    public string? AuthToken { get; set; }
    public string? MobileNumber { get; set; }
    public string? Password { get; set; }
    public Guid? CustomerId { get; set; }
    public Guid? SecondCustomerId { get; set; }
    public string? AdminMobileNumber { get; set; }
    public string? AdminPassword { get; set; }
    public object? UpdateData { get; set; }
}

