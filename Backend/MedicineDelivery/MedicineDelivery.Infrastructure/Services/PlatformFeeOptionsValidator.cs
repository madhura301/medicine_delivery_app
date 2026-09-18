using Microsoft.Extensions.Options;

namespace MedicineDelivery.Infrastructure.Services
{
    /// <summary>
    /// Rejects invalid platform fee settings at startup with the specific problem in the message,
    /// so a bad environment variable fails the deployment visibly instead of mis-paying chemists.
    /// </summary>
    public sealed class PlatformFeeOptionsValidator : IValidateOptions<PlatformFeeOptions>
    {
        public ValidateOptionsResult Validate(string? name, PlatformFeeOptions options) =>
            PlatformFeeSchedule.TryCreate(options, out _, out var error)
                ? ValidateOptionsResult.Success
                : ValidateOptionsResult.Fail(error);
    }
}
