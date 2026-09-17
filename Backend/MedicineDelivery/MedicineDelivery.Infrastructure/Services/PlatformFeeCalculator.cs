using MedicineDelivery.Application.Interfaces;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace MedicineDelivery.Infrastructure.Services
{
    /// <summary>
    /// Order-value slab implementation of the Platform Technology Fee.
    /// Deterministic — no I/O — so it is trivially unit-testable.
    ///
    /// The free period and the slab table come from configuration (<see cref="PlatformFeeOptions"/>).
    /// Defaults, used when nothing is configured:
    ///   First 30 days after activation → ₹0
    ///   ₹0–200 → ₹5, ₹201–500 → ₹10, ₹501–1,500 → ₹15,
    ///   ₹1,501–3,000 → ₹20, ₹3,001–5,000 → ₹50, above ₹5,000 → ₹100.
    /// </summary>
    public class PlatformFeeCalculator : IPlatformFeeCalculator
    {
        private readonly PlatformFeeSchedule _schedule;
        private readonly ILogger<PlatformFeeCalculator> _logger;

        public PlatformFeeCalculator(IOptions<PlatformFeeOptions> options, ILogger<PlatformFeeCalculator> logger)
        {
            _schedule = PlatformFeeSchedule.From(options.Value);
            _logger = logger;
        }

        public decimal CalculateFee(decimal billAmount, DateTime? storeActivatedOn, DateTime? asOfUtc = null)
        {
            if (billAmount <= 0)
                return 0m;

            var asOf = asOfUtc ?? DateTime.UtcNow;

            // No fee during the free period after activation.
            if (storeActivatedOn.HasValue && _schedule.FreeWindowDays > 0
                && asOf <= storeActivatedOn.Value.AddDays(_schedule.FreeWindowDays))
            {
                _logger.LogDebug("Platform fee waived (within {FreeWindowDays}-day free window) for BillAmount={BillAmount}, ActivatedOn={ActivatedOn}",
                    _schedule.FreeWindowDays, billAmount, storeActivatedOn);
                return 0m;
            }

            var fee = _schedule.FeeFor(billAmount);
            _logger.LogDebug("Platform fee calculated: BillAmount={BillAmount} -> Fee={Fee}", billAmount, fee);
            return fee;
        }

        public PlatformFeeBreakdown CalculateFeeBreakdown(decimal billAmount, DateTime? storeActivatedOn, decimal gstPercent, DateTime? asOfUtc = null)
        {
            var fee = CalculateFee(billAmount, storeActivatedOn, asOfUtc);
            if (fee <= 0m || gstPercent <= 0m)
                return new PlatformFeeBreakdown(fee, 0m);

            var gst = Math.Round(fee * gstPercent / 100m, 2, MidpointRounding.AwayFromZero);
            _logger.LogDebug("Platform fee GST: Fee={Fee}, GstPercent={GstPercent} -> Gst={Gst}", fee, gstPercent, gst);
            return new PlatformFeeBreakdown(fee, gst);
        }
    }
}
