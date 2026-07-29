namespace MedicineDelivery.Application.Interfaces
{
    /// <summary>
    /// Computes the flat Platform Technology Fee retained by Pharmaish per order.
    /// The fee is a flat ₹ amount decided by the order's bill value (a slab), with a
    /// free grace window for the first 30 days after store activation.
    /// </summary>
    public interface IPlatformFeeCalculator
    {
        /// <summary>
        /// Returns the platform fee for an order.
        /// </summary>
        /// <param name="billAmount">The medicine/bill value the slab is applied to.</param>
        /// <param name="storeActivatedOn">Store activation date; null means not activated.</param>
        /// <param name="asOfUtc">Evaluation time (defaults to now); used for the free-window check.</param>
        decimal CalculateFee(decimal billAmount, DateTime? storeActivatedOn, DateTime? asOfUtc = null);

        /// <summary>
        /// Returns the platform fee together with the GST charged on it. The chemist is paid
        /// the bill minus <see cref="PlatformFeeBreakdown.FeeInclusiveOfGst"/>, e.g. a ₹1,000
        /// bill with a ₹50 fee at 18% GST → Pharmaish retains ₹59, chemist receives ₹941.
        /// </summary>
        /// <param name="gstPercent">GST percentage applied to the fee (e.g. 18).</param>
        PlatformFeeBreakdown CalculateFeeBreakdown(decimal billAmount, DateTime? storeActivatedOn, decimal gstPercent, DateTime? asOfUtc = null);
    }

    /// <summary>Platform technology fee split into its net and GST components.</summary>
    /// <param name="Fee">Slab fee, excluding GST.</param>
    /// <param name="Gst">GST charged on <paramref name="Fee"/>.</param>
    public readonly record struct PlatformFeeBreakdown(decimal Fee, decimal Gst)
    {
        /// <summary>Total deducted from the chemist's payout = Fee + Gst.</summary>
        public decimal FeeInclusiveOfGst => Fee + Gst;
    }
}
