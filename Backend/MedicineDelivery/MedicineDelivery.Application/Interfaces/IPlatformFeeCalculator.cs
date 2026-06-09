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
    }
}
