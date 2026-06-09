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
    /// HttpClient-based implementation of the Razorpay Route v2 Accounts onboarding APIs.
    /// Uses a raw HTTP wrapper (rather than the SDK) for full control over the v2 endpoints
    /// that create linked accounts, stakeholders and Route product configurations.
    /// </summary>
    public class RazorpayRouteClient : IRazorpayRouteClient
    {
        private const string BaseUrl = "https://api.razorpay.com/";

        private readonly HttpClient _httpClient;
        private readonly ILogger<RazorpayRouteClient> _logger;

        public RazorpayRouteClient(HttpClient httpClient, IConfiguration configuration, ILogger<RazorpayRouteClient> logger)
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

        public async Task<RazorpayOnboardingResult> CreateLinkedAccountAsync(RazorpayOnboardingRequest request, CancellationToken ct = default)
        {
            var result = new RazorpayOnboardingResult();

            // Step 1 — create linked account
            var accountBody = new Dictionary<string, object?>
            {
                ["email"] = request.Email,
                ["phone"] = request.Phone,
                ["type"] = "route",
                ["legal_business_name"] = request.BusinessName,
                ["business_type"] = "proprietorship",
                ["contact_name"] = request.ContactName,
                ["profile"] = new Dictionary<string, object?>
                {
                    ["category"] = "healthcare",
                    ["subcategory"] = "pharmacy",
                    ["addresses"] = new Dictionary<string, object?>
                    {
                        ["registered"] = new Dictionary<string, object?>
                        {
                            ["street1"] = request.Street1,
                            ["street2"] = request.Street2,
                            ["city"] = request.City,
                            ["state"] = request.State,
                            ["postal_code"] = request.PostalCode,
                            ["country"] = request.Country
                        }
                    }
                },
                ["legal_info"] = BuildLegalInfo(request)
            };

            var accountId = await PostForIdAsync("v2/accounts", accountBody, "CreateLinkedAccount", result, ct);
            if (accountId is null) return result;
            result.LinkedAccountId = accountId;

            // Step 2 — create stakeholder
            var stakeholderBody = new Dictionary<string, object?>
            {
                ["name"] = request.ContactName,
                ["email"] = request.Email,
                ["kyc"] = string.IsNullOrWhiteSpace(request.Pan)
                    ? null
                    : new Dictionary<string, object?> { ["pan"] = request.Pan }
            };

            var stakeholderId = await PostForIdAsync($"v2/accounts/{accountId}/stakeholders", stakeholderBody, "CreateStakeholder", result, ct);
            if (stakeholderId is null) return result;
            result.StakeholderId = stakeholderId;

            // Step 3 — request the Route product configuration
            var productBody = new Dictionary<string, object?>
            {
                ["product_name"] = "route",
                ["tnc_accepted"] = true
            };

            var productId = await PostForIdAsync($"v2/accounts/{accountId}/products", productBody, "RequestRouteProduct", result, ct);
            if (productId is null) return result;
            result.ProductConfigurationId = productId;

            // Step 4 — submit bank settlement details
            return await UpdateBankConfigurationAsync(accountId, productId, request.Bank, ct, result);
        }

        public Task<RazorpayOnboardingResult> UpdateBankConfigurationAsync(string linkedAccountId, string? productConfigurationId, RazorpayBankDetails bank, CancellationToken ct = default)
            => UpdateBankConfigurationAsync(linkedAccountId, productConfigurationId, bank, ct, new RazorpayOnboardingResult { LinkedAccountId = linkedAccountId, ProductConfigurationId = productConfigurationId });

        private async Task<RazorpayOnboardingResult> UpdateBankConfigurationAsync(
            string linkedAccountId, string? productConfigurationId, RazorpayBankDetails bank, CancellationToken ct, RazorpayOnboardingResult result)
        {
            if (string.IsNullOrWhiteSpace(productConfigurationId))
            {
                result.Success = false;
                result.FailedStep = "UpdateBankConfiguration";
                result.Error = "Missing Route product configuration id; cannot submit bank details.";
                return result;
            }

            var body = new Dictionary<string, object?>
            {
                ["settlements"] = new Dictionary<string, object?>
                {
                    ["account_number"] = bank.AccountNumber,
                    ["ifsc_code"] = bank.IfscCode,
                    ["beneficiary_name"] = bank.BeneficiaryName
                },
                ["tnc_accepted"] = true
            };

            try
            {
                using var response = await SendAsync(HttpMethod.Patch, $"v2/accounts/{linkedAccountId}/products/{productConfigurationId}", body, ct);
                var json = await response.Content.ReadAsStringAsync(ct);

                if (!response.IsSuccessStatusCode)
                {
                    result.Success = false;
                    result.FailedStep = "UpdateBankConfiguration";
                    result.Error = ExtractError(json);
                    _logger.LogWarning("Razorpay UpdateBankConfiguration failed for {AccountId}: {Error}", linkedAccountId, result.Error);
                    return result;
                }

                result.Success = true;
                result.State = MapActivationState(json);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error calling Razorpay UpdateBankConfiguration for {AccountId}", linkedAccountId);
                result.Success = false;
                result.FailedStep = "UpdateBankConfiguration";
                result.Error = "Network error while submitting bank details to Razorpay.";
                return result;
            }
        }

        private static Dictionary<string, object?>? BuildLegalInfo(RazorpayOnboardingRequest request)
        {
            var legal = new Dictionary<string, object?>();
            if (!string.IsNullOrWhiteSpace(request.Pan)) legal["pan"] = request.Pan;
            if (!string.IsNullOrWhiteSpace(request.Gst)) legal["gst"] = request.Gst;
            return legal.Count == 0 ? null : legal;
        }

        private async Task<string?> PostForIdAsync(string path, Dictionary<string, object?> body, string step, RazorpayOnboardingResult result, CancellationToken ct)
        {
            try
            {
                using var response = await SendAsync(HttpMethod.Post, path, body, ct);
                var json = await response.Content.ReadAsStringAsync(ct);

                if (!response.IsSuccessStatusCode)
                {
                    result.Success = false;
                    result.FailedStep = step;
                    result.Error = ExtractError(json);
                    _logger.LogWarning("Razorpay {Step} failed: {Error}", step, result.Error);
                    return null;
                }

                using var doc = JsonDocument.Parse(json);
                if (doc.RootElement.TryGetProperty("id", out var idElement))
                    return idElement.GetString();

                result.Success = false;
                result.FailedStep = step;
                result.Error = "Razorpay response did not contain an id.";
                return null;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error calling Razorpay {Step}", step);
                result.Success = false;
                result.FailedStep = step;
                result.Error = $"Network error during {step}.";
                return null;
            }
        }

        private Task<HttpResponseMessage> SendAsync(HttpMethod method, string path, Dictionary<string, object?> body, CancellationToken ct)
        {
            var request = new HttpRequestMessage(method, path)
            {
                Content = JsonContent.Create(body)
            };
            return _httpClient.SendAsync(request, ct);
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

        private static RazorpayActivationState MapActivationState(string json)
        {
            try
            {
                using var doc = JsonDocument.Parse(json);
                if (doc.RootElement.TryGetProperty("activation_status", out var status))
                {
                    return (status.GetString() ?? string.Empty).ToLowerInvariant() switch
                    {
                        "activated" => RazorpayActivationState.Activated,
                        "rejected" => RazorpayActivationState.Rejected,
                        "suspended" => RazorpayActivationState.Suspended,
                        "needs_clarification" => RazorpayActivationState.NeedsClarification,
                        _ => RazorpayActivationState.Pending
                    };
                }
            }
            catch
            {
                // fall through
            }
            return RazorpayActivationState.Pending;
        }
    }
}
