using MedicineDelivery.Application.Interfaces;

namespace MedicineDelivery.Infrastructure.Services
{
    /// <summary>
    /// Order-value slab implementation of the Platform Technology Fee.
    /// Pure / deterministic — no I/O — so it is trivially unit-testable.
    ///
    /// Slab (per order, flat ₹):
    ///   First 30 days after activation → ₹0
    ///   ₹0–200 → ₹5, ₹201–500 → ₹10, ₹501–1,500 → ₹15,
    ///   ₹1,501–3,000 → ₹20, ₹3,001–5,000 → ₹50, above ₹5,000 → ₹100.
    /// </summary>
    public class PlatformFeeCalculator : IPlatformFeeCalculator
    {
        private const int FreeWindowDays = 30;

        /// <summary>Slab upper bounds (inclusive) and the fee for that band, ascending.</summary>
        private static readonly (decimal UpperBoundInclusive, decimal Fee)[] Slabs =
        {
            (200m, 5m),
            (500m, 10m),
            (1500m, 15m),
            (3000m, 20m),
            (5000m, 50m)
        };

        private const decimal AboveTopSlabFee = 100m;

        public decimal CalculateFee(decimal billAmount, DateTime? storeActivatedOn, DateTime? asOfUtc = null)
        {
            if (billAmount <= 0)
                return 0m;

            var asOf = asOfUtc ?? DateTime.UtcNow;

            // First 30 days after activation are free.
            if (storeActivatedOn.HasValue && asOf <= storeActivatedOn.Value.AddDays(FreeWindowDays))
                return 0m;

            foreach (var slab in Slabs)
            {
                if (billAmount <= slab.UpperBoundInclusive)
                    return slab.Fee;
            }

            return AboveTopSlabFee;
        }
    }
}
