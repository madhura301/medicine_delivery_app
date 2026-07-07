using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using MedicineDelivery.Application.Interfaces;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace MedicineDelivery.Infrastructure.Services
{
    /// <summary>
    /// HttpClient-based implementation of the Razorpay Payment Links API (v1/payment_links),
    /// used to collect the chemist activation/onboarding fee.
    /// </summary>
    public class RazorpayPaymentLinkClient : IRazorpayPaymentLinkClient
    {
        private const string BaseUrl = "https://api.razorpay.com/";

        private readonly HttpClient _httpClient;
        private readonly ILogger<RazorpayPaymentLinkClient> _logger;

        public RazorpayPaymentLinkClient(HttpClient httpClient, IConfiguration configuration, ILogger<RazorpayPaymentLinkClient> logger)
        {
            _httpClient = httpClient;
            _logger = logger;

            var keyId = configuration["RazorpaySettings:KeyId"] ?? string.Empty;
            var keySecret = configuration["RazorpaySettings:KeySecret"] ?? string.Empty;

            if (_httpClient.BaseAddress is null)
                _httpClient.BaseAddress = new Uri(BaseUrl);

            var token = Convert.ToBase64String(Encoding.UTF8.GetBytes($"{keyId}:{keySecret}"));
            _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Basic", token);
        }

        public async Task<PaymentLinkResult> CreatePaymentLinkAsync(PaymentLinkRequest request, CancellationToken ct = default)
        {
            var body = new Dictionary<string, object?>
            {
                ["amount"] = request.AmountInPaise,
                ["currency"] = request.Currency,
                ["accept_partial"] = false,
                ["description"] = request.Description,
                ["customer"] = new Dictionary<string, object?>
                {
                    ["name"] = request.CustomerName,
                    ["email"] = request.CustomerEmail,
                    ["contact"] = request.CustomerContact
                },
                ["notify"] = new Dictionary<string, object?>
                {
                    ["sms"] = true,
                    ["email"] = true
                },
                ["reminder_enable"] = true,
                ["notes"] = new Dictionary<string, object?>
                {
                    ["reference"] = request.ReferenceNote
                }
            };

            try
            {
                _logger.LogInformation(
                    "Razorpay request CreatePaymentLink POST /v1/payment_links AmountInPaise={AmountInPaise}, Reference={ReferenceNote}",
                    request.AmountInPaise, request.ReferenceNote);

                using var httpRequest = new HttpRequestMessage(HttpMethod.Post, "v1/payment_links")
                {
                    Content = JsonContent.Create(body)
                };
                using var response = await _httpClient.SendAsync(httpRequest, ct);
                var json = await response.Content.ReadAsStringAsync(ct);

                if (!response.IsSuccessStatusCode)
                {
                    var error = ExtractError(json);
                    _logger.LogWarning("Razorpay CreatePaymentLink failed: {Error}", error);
                    return new PaymentLinkResult { Success = false, Error = error };
                }

                using var doc = JsonDocument.Parse(json);
                var root = doc.RootElement;
                var result = new PaymentLinkResult
                {
                    Success = true,
                    PaymentLinkId = root.TryGetProperty("id", out var id) ? id.GetString() : null,
                    ShortUrl = root.TryGetProperty("short_url", out var url) ? url.GetString() : null,
                    Status = root.TryGetProperty("status", out var st) ? st.GetString() : null
                };

                _logger.LogInformation("Razorpay CreatePaymentLink succeeded. PaymentLinkId={PaymentLinkId}, ShortUrl={ShortUrl}",
                    result.PaymentLinkId, result.ShortUrl);

                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error calling Razorpay CreatePaymentLink");
                return new PaymentLinkResult { Success = false, Error = "Network error while creating the payment link." };
            }
        }

        private static string ExtractError(string json)
        {
            try
            {
                using var doc = JsonDocument.Parse(json);
                if (doc.RootElement.TryGetProperty("error", out var error) &&
                    error.TryGetProperty("description", out var desc))
                {
                    return desc.GetString() ?? "Unknown Razorpay error.";
                }
            }
            catch
            {
                // fall through
            }
            return "Unknown Razorpay error.";
        }
    }
}
