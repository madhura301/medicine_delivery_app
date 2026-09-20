using System.Net;
using System.Text.Json;
using MedicineDelivery.Infrastructure.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging.Abstractions;
using Xunit;

namespace MedicineDelivery.UnitTests;

/// <summary>
/// Pins the exact request sent to MSG91 for the bill-ready SMS.
///
/// MSG91 silently substitutes an empty string for any template variable key it does not recognise,
/// so a misspelt key sends a blank SMS with no error anywhere — the delivery-OTP text once went out
/// empty for exactly that reason. These tests capture the real HTTP body instead of trusting it.
/// </summary>
public class Msg91BillReadySmsTests
{
    private const string BillReadyTemplateId = "6aa6dcc62be02e22be0e6fa3";

    /// <summary>Records the request instead of sending it, and answers like MSG91 does on success.</summary>
    private sealed class CapturingHandler : HttpMessageHandler
    {
        public HttpRequestMessage? Request { get; private set; }
        public string? Body { get; private set; }

        protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken ct)
        {
            Request = request;
            Body = request.Content is null ? null : await request.Content.ReadAsStringAsync(ct);
            return new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new StringContent("{\"type\":\"success\",\"message\":\"test\"}")
            };
        }
    }

    private static (Msg91SmsService Service, CapturingHandler Handler) NewService(string? templateId = BillReadyTemplateId)
    {
        var settings = new Dictionary<string, string?>
        {
            ["SmsSettings:AuthKey"] = "test-auth-key",
            ["SmsSettings:BillReadyTemplateId"] = templateId,
        };
        var configuration = new ConfigurationBuilder().AddInMemoryCollection(settings).Build();
        var handler = new CapturingHandler();
        return (new Msg91SmsService(new HttpClient(handler), configuration, NullLogger<Msg91SmsService>.Instance), handler);
    }

    private static JsonElement FirstRecipient(string body) =>
        JsonDocument.Parse(body).RootElement.GetProperty("recipients")[0];

    [Fact]
    public async Task Sends_the_configured_template_with_exactly_the_alp_and_num_variables()
    {
        var (service, handler) = NewService();

        var sent = await service.SendBillReadyAsync("9876543210", "Priya", 417m);

        Assert.True(sent);
        var root = JsonDocument.Parse(handler.Body!).RootElement;
        Assert.Equal(BillReadyTemplateId, root.GetProperty("template_id").GetString());

        var recipient = FirstRecipient(handler.Body!);
        Assert.Equal("919876543210", recipient.GetProperty("mobiles").GetString());
        Assert.Equal("Priya", recipient.GetProperty("alp").GetString());
        Assert.Equal("417.00", recipient.GetProperty("num").GetString());

        // Nothing else: an unexpected key means a variable name has drifted from the template.
        var keys = recipient.EnumerateObject().Select(p => p.Name).OrderBy(k => k).ToArray();
        Assert.Equal(new[] { "alp", "mobiles", "num" }, keys);
    }

    [Theory]
    [InlineData(417, "417.00")]
    [InlineData(1250.5, "1250.50")]      // no thousands separator
    [InlineData(99.999, "100.00")]
    [InlineData(0.5, "0.50")]
    public async Task Formats_the_amount_as_plain_digits(decimal amount, string expected)
    {
        var (service, handler) = NewService();

        await service.SendBillReadyAsync("9876543210", "Priya", amount);

        Assert.Equal(expected, FirstRecipient(handler.Body!).GetProperty("num").GetString());
    }

    [Theory]
    [InlineData(null, "Customer")]
    [InlineData("", "Customer")]
    [InlineData("   ", "Customer")]
    [InlineData("  Anup  ", "Anup")]
    public async Task Falls_back_to_a_neutral_greeting_without_a_name(string? name, string expected)
    {
        var (service, handler) = NewService();

        await service.SendBillReadyAsync("9876543210", name!, 417m);

        Assert.Equal(expected, FirstRecipient(handler.Body!).GetProperty("alp").GetString());
    }

    [Fact]
    public async Task Truncates_a_name_longer_than_DLT_allows()
    {
        var (service, handler) = NewService();

        await service.SendBillReadyAsync("9876543210", new string('A', 45), 417m);

        Assert.Equal(30, FirstRecipient(handler.Body!).GetProperty("alp").GetString()!.Length);
    }

    [Fact]
    public async Task Does_not_call_MSG91_when_the_template_id_is_not_configured()
    {
        var (service, handler) = NewService(templateId: null);

        var sent = await service.SendBillReadyAsync("9876543210", "Priya", 417m);

        Assert.False(sent);
        Assert.Null(handler.Request);
    }
}
