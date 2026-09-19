namespace MedicineDelivery.Application.Common
{
    /// <summary>
    /// Rules that decide which chemist an order can reach. Kept in one place because several screens
    /// explain routing to staff — the customer map, the Order Log, reassignment — and they must agree
    /// with what the router actually does.
    /// </summary>
    public static class OrderRoutingRules
    {
        /// <summary>
        /// How far from a delivery address a chemist can be and still receive the order, measured
        /// in a straight line (haversine). Applies only when the address has map coordinates;
        /// otherwise chemists are matched by pin code.
        /// </summary>
        public const double ChemistSearchRadiusKm = 5.0;
    }
}
