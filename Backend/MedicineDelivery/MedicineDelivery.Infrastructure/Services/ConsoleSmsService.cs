using Microsoft.Extensions.Logging;
using MedicineDelivery.Domain.Interfaces;

namespace MedicineDelivery.Infrastructure.Services
{
    /// <summary>
    /// Development stub — logs the OTP to the console instead of sending a real SMS.
    /// Replace this with MSG91SmsService or TwilioSmsService once you have API credentials.
    /// Register the real implementation in Program.cs by swapping the DI registration.
    /// </summary>
    public class ConsoleSmsService : ISmsService
    {
        private readonly ILogger<ConsoleSmsService> _logger;

        public ConsoleSmsService(ILogger<ConsoleSmsService> logger)
        {
            _logger = logger;
        }

        public Task<bool> SendOtpAsync(string phoneNumber, string otpCode, string? recipientName = null)
        {
            // In production, replace this with an actual SMS API call (MSG91 / Twilio).
            _logger.LogWarning(
                "[DEV ONLY] OTP for {PhoneNumber} ({RecipientName}): {OtpCode} — replace ConsoleSmsService with a real provider before going live.",
                phoneNumber, recipientName ?? "n/a", otpCode);

            return Task.FromResult(true);
        }

        public Task<bool> SendPaymentConfirmationAsync(string phoneNumber, string customerName, string orderNumber, string storeName)
        {
            _logger.LogWarning(
                "[DEV ONLY] Payment confirmation SMS for {PhoneNumber}: Name={CustomerName}, Order={OrderNumber}, Store={StoreName} — replace ConsoleSmsService with a real provider before going live.",
                phoneNumber, customerName, orderNumber, storeName);

            return Task.FromResult(true);
        }
    }
}
