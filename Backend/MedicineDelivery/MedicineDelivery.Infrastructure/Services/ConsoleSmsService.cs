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

        public Task<bool> SendOtpAsync(string phoneNumber, string otpCode)
        {
            // In production, replace this with an actual SMS API call (MSG91 / Twilio).
            _logger.LogWarning(
                "[DEV ONLY] OTP for {PhoneNumber}: {OtpCode} — replace ConsoleSmsService with a real provider before going live.",
                phoneNumber, otpCode);

            return Task.FromResult(true);
        }
    }
}
