using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using MedicineDelivery.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace MedicineDelivery.API.Controllers
{
    /// <summary>
    /// Receives Razorpay webhooks. Phase 1 handles <c>payment_link.paid</c> to activate a
    /// chemist once their onboarding fee is paid. (Route transfer/account webhooks are Phase 3.)
    /// </summary>
    [ApiController]
    [Route("api/razorpay/webhook")]
    [AllowAnonymous]
    public class RazorpayWebhookController : ControllerBase
    {
        private readonly IChemistActivationService _activationService;
        private readonly IConfiguration _configuration;
        private readonly ILogger<RazorpayWebhookController> _logger;

        public RazorpayWebhookController(
            IChemistActivationService activationService,
            IConfiguration configuration,
            ILogger<RazorpayWebhookController> logger)
        {
            _activationService = activationService;
            _configuration = configuration;
            _logger = logger;
        }

        [HttpPost]
        public async Task<IActionResult> Handle(CancellationToken ct)
        {
            // Read the raw body — required for signature verification.
            Request.EnableBuffering();
            string rawBody;
            using (var reader = new StreamReader(Request.Body, Encoding.UTF8, leaveOpen: true))
            {
                rawBody = await reader.ReadToEndAsync(ct);
                Request.Body.Position = 0;
            }

            if (!VerifySignature(rawBody))
            {
                _logger.LogWarning("Razorpay webhook signature verification failed.");
                return Unauthorized(new { message = "Invalid signature." });
            }

            try
            {
                using var doc = JsonDocument.Parse(rawBody);
                var root = doc.RootElement;
                var eventType = root.TryGetProperty("event", out var ev) ? ev.GetString() : null;

                _logger.LogInformation("Razorpay webhook received: {Event}", eventType);

                if (eventType == "payment_link.paid")
                {
                    var (linkId, paymentId) = ExtractPaymentLinkIds(root);
                    if (!string.IsNullOrWhiteSpace(linkId))
                    {
                        await _activationService.MarkPaidFromWebhookAsync(linkId!, paymentId, ct);
                    }
                    else
                    {
                        _logger.LogWarning("payment_link.paid webhook missing payment_link id.");
                    }
                }

                // Always 200 for accepted/ignored events so Razorpay stops retrying.
                return Ok(new { received = true });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing Razorpay webhook.");
                // 200 to avoid infinite retries on a malformed/unhandled payload we can't fix by retrying.
                return Ok(new { received = true });
            }
        }

        private bool VerifySignature(string rawBody)
        {
            var secret = _configuration["RazorpaySettings:WebhookSecret"];
            if (string.IsNullOrWhiteSpace(secret))
            {
                // No secret configured (e.g. local dev). Process but warn — do NOT do this in prod.
                _logger.LogWarning("RazorpaySettings:WebhookSecret not configured; skipping webhook signature check.");
                return true;
            }

            var signature = Request.Headers["X-Razorpay-Signature"].FirstOrDefault();
            if (string.IsNullOrWhiteSpace(signature))
                return false;

            var expected = ComputeHmacSha256(rawBody, secret);
            return CryptographicOperations.FixedTimeEquals(
                Encoding.UTF8.GetBytes(expected),
                Encoding.UTF8.GetBytes(signature));
        }

        private static (string? linkId, string? paymentId) ExtractPaymentLinkIds(JsonElement root)
        {
            string? linkId = null;
            string? paymentId = null;

            if (root.TryGetProperty("payload", out var payload))
            {
                if (payload.TryGetProperty("payment_link", out var pl) &&
                    pl.TryGetProperty("entity", out var plEntity) &&
                    plEntity.TryGetProperty("id", out var plId))
                {
                    linkId = plId.GetString();
                }

                if (payload.TryGetProperty("payment", out var pay) &&
                    pay.TryGetProperty("entity", out var payEntity) &&
                    payEntity.TryGetProperty("id", out var payId))
                {
                    paymentId = payId.GetString();
                }
            }

            return (linkId, paymentId);
        }

        private static string ComputeHmacSha256(string payload, string secret)
        {
            using var hmac = new HMACSHA256(Encoding.UTF8.GetBytes(secret));
            var hash = hmac.ComputeHash(Encoding.UTF8.GetBytes(payload));
            return Convert.ToHexString(hash).ToLowerInvariant();
        }
    }
}
