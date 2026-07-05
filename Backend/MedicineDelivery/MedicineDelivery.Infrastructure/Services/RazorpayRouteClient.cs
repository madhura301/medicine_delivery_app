using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using MedicineDelivery.Application.Interfaces;
using MedicineDelivery.Domain.Enums;
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
            // Resume from any ids already obtained in a previous (partial) attempt.
            var result = new RazorpayOnboardingResult
            {
                LinkedAccountId = request.ExistingLinkedAccountId,
                StakeholderId = request.ExistingStakeholderId,
                ProductConfigurationId = request.ExistingProductConfigurationId
            };

            // Step 1 — create linked account (skip if we already have one)
            if (!string.IsNullOrWhiteSpace(result.LinkedAccountId))
            {
                return await ContinueOnboardingAsync(request, result, ct);
            }

            var accountBody = new Dictionary<string, object?>
            {
                ["email"] = request.Email,
                ["phone"] = request.Phone,
                ["type"] = "route",
                ["legal_business_name"] = request.BusinessName,
                ["business_type"] = MapBusinessType(request.BusinessType),
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

            return await ContinueOnboardingAsync(request, result, ct);
        }

        /// <summary>
        /// Runs the remaining onboarding steps (stakeholder → product → bank), skipping any
        /// already completed in a previous attempt. Resumable after a partial failure.
        /// </summary>
        private async Task<RazorpayOnboardingResult> ContinueOnboardingAsync(
            RazorpayOnboardingRequest request, RazorpayOnboardingResult result, CancellationToken ct)
        {
            var accountId = result.LinkedAccountId!;

            // Step 2 — create stakeholder (skip if present)
            if (string.IsNullOrWhiteSpace(result.StakeholderId))
            {
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
            }

            // Step 3 — request the Route product configuration (skip if present)
            if (string.IsNullOrWhiteSpace(result.ProductConfigurationId))
            {
                var productBody = new Dictionary<string, object?>
                {
                    ["product_name"] = "route",
                    ["tnc_accepted"] = true
                };

                var productId = await PostForIdAsync($"v2/accounts/{accountId}/products", productBody, "RequestRouteProduct", result, ct);
                if (productId is null) return result;
                result.ProductConfigurationId = productId;
            }

            // Step 4 — submit bank settlement details
            return await UpdateBankConfigurationAsync(accountId, result.ProductConfigurationId, request.Bank, ct, result);
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
                // NOTE: verbose request logging for test debugging — includes bank details. Mask before production.
                _logger.LogInformation("Razorpay request UpdateBankConfiguration PATCH /v2/accounts/{AccountId}/products/{ProductId} body={Body}",
                    linkedAccountId, productConfigurationId, SafeJson(body));

                using var response = await SendAsync(HttpMethod.Patch, $"v2/accounts/{linkedAccountId}/products/{productConfigurationId}", body, ct);
                var json = await response.Content.ReadAsStringAsync(ct);

                if (!response.IsSuccessStatusCode)
                {
                    result.Success = false;
                    result.FailedStep = "UpdateBankConfiguration";
                    result.Error = ExtractError(json);
                    _logger.LogWarning("Razorpay UpdateBankConfiguration failed for {AccountId}: {Error}. Response={Response}", linkedAccountId, result.Error, json);
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

        public async Task<RazorpayTransferResult> CreateTransferOnPaymentAsync(RazorpayTransferRequest request, CancellationToken ct = default)
        {
            // POST /v1/payments/{paymentId}/transfers  with a transfers[] array.
            var body = new Dictionary<string, object?>
            {
                ["transfers"] = new[]
                {
                    new Dictionary<string, object?>
                    {
                        ["account"] = request.LinkedAccountId,
                        ["amount"] = request.AmountInPaise,
                        ["currency"] = request.Currency,
                        ["on_hold"] = request.OnHold
                    }
                }
            };

            try
            {
                using var response = await SendAsync(HttpMethod.Post, $"v1/payments/{request.PaymentId}/transfers", body, ct);
                var json = await response.Content.ReadAsStringAsync(ct);

                if (!response.IsSuccessStatusCode)
                {
                    var error = ExtractError(json);
                    _logger.LogWarning("Razorpay CreateTransfer failed for Payment={PaymentId}: {Error}",
                        request.PaymentId, error);
                    return new RazorpayTransferResult { Success = false, Error = error };
                }

                // Response is { "items": [ { "id": "trf_XXXX", ... } ] } (or an array).
                using var doc = JsonDocument.Parse(json);
                var root = doc.RootElement;
                var first = root.ValueKind == JsonValueKind.Array
                    ? (root.GetArrayLength() > 0 ? root[0] : default)
                    : (root.TryGetProperty("items", out var items) && items.GetArrayLength() > 0 ? items[0] : default);

                var transferId = first.ValueKind == JsonValueKind.Object && first.TryGetProperty("id", out var id)
                    ? id.GetString()
                    : null;

                return new RazorpayTransferResult { Success = true, TransferId = transferId };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error calling Razorpay CreateTransfer for Payment={PaymentId}", request.PaymentId);
                return new RazorpayTransferResult { Success = false, Error = "Network error while creating the transfer." };
            }
        }

        public async Task<RazorpayAccountStatusResult> GetAccountStatusAsync(string linkedAccountId, CancellationToken ct = default)
        {
            try
            {
                using var response = await _httpClient.GetAsync($"v2/accounts/{linkedAccountId}", ct);
                var json = await response.Content.ReadAsStringAsync(ct);

                if (!response.IsSuccessStatusCode)
                {
                    var error = ExtractError(json);
                    _logger.LogWarning("Razorpay GetAccountStatus failed for {AccountId}: {Error}", linkedAccountId, error);
                    return new RazorpayAccountStatusResult { Success = false, Error = error };
                }

                using var doc = JsonDocument.Parse(json);
                var rawStatus = doc.RootElement.TryGetProperty("status", out var st) ? st.GetString() : null;

                return new RazorpayAccountStatusResult
                {
                    Success = true,
                    RawStatus = rawStatus,
                    State = MapAccountState(rawStatus)
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error calling Razorpay GetAccountStatus for {AccountId}", linkedAccountId);
                return new RazorpayAccountStatusResult { Success = false, Error = "Network error while fetching account status." };
            }
        }

        private static RazorpayActivationState MapAccountState(string? status) =>
            (status ?? string.Empty).ToLowerInvariant() switch
            {
                "activated" => RazorpayActivationState.Activated,
                "rejected" => RazorpayActivationState.Rejected,
                "suspended" => RazorpayActivationState.Suspended,
                "needs_clarification" => RazorpayActivationState.NeedsClarification,
                _ => RazorpayActivationState.Pending // created / under_review / etc.
            };

        private static string SafeJson(object body)
        {
            try { return JsonSerializer.Serialize(body); }
            catch { return "<unserializable>"; }
        }

        /// <summary>
        /// Business types that are not registered entities and therefore have no company PAN.
        /// For these, legal_info.pan must be omitted — Razorpay rejects it with
        /// "The company pan field is invalid for business type: ...". The owner's individual
        /// PAN is submitted via the stakeholder's kyc.pan instead.
        /// </summary>
        private static readonly HashSet<BusinessType> UnregisteredBusinessTypes =
            new() { BusinessType.Individual, BusinessType.Proprietorship };

        /// <summary>Maps our BusinessType enum to Razorpay's Route `business_type` values.</summary>
        private static string MapBusinessType(BusinessType type) => type switch
        {
            BusinessType.Proprietorship => "proprietorship",
            BusinessType.Partnership => "partnership",
            BusinessType.PrivateLimited => "private_limited",
            BusinessType.PublicLimited => "public_limited",
            BusinessType.LLP => "llp",
            BusinessType.NGO => "ngo",
            BusinessType.Trust => "trust",
            BusinessType.Society => "society",
            BusinessType.Individual => "individual",
            _ => "individual"
        };

        private Dictionary<string, object?>? BuildLegalInfo(RazorpayOnboardingRequest request)
        {
            var legal = new Dictionary<string, object?>();

            // legal_info.pan is the COMPANY pan — only valid for registered entities.
            if (!UnregisteredBusinessTypes.Contains(request.BusinessType) &&
                !string.IsNullOrWhiteSpace(request.Pan))
            {
                legal["pan"] = request.Pan;
            }

            if (!string.IsNullOrWhiteSpace(request.Gst)) legal["gst"] = request.Gst;
            return legal.Count == 0 ? null : legal;
        }

        private async Task<string?> PostForIdAsync(string path, Dictionary<string, object?> body, string step, RazorpayOnboardingResult result, CancellationToken ct)
        {
            try
            {
                // NOTE: verbose request logging for test debugging — includes PAN/GST.
                // Mask or remove before production (PII).
                _logger.LogInformation("Razorpay request {Step} POST /{Path} body={Body}",
                    step, path, SafeJson(body));

                using var response = await SendAsync(HttpMethod.Post, path, body, ct);
                var json = await response.Content.ReadAsStringAsync(ct);

                if (!response.IsSuccessStatusCode)
                {
                    result.Success = false;
                    result.FailedStep = step;
                    result.Error = ExtractError(json);
                    _logger.LogWarning("Razorpay {Step} failed: {Error}. Response={Response}", step, result.Error, json);
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
            // Strip null-valued keys (e.g. omitted legal_info/kyc) — Razorpay rejects explicit nulls.
            var cleaned = body.Where(kv => kv.Value is not null)
                              .ToDictionary(kv => kv.Key, kv => kv.Value);

            var request = new HttpRequestMessage(method, path)
            {
                Content = JsonContent.Create(cleaned)
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
