namespace MedicineDelivery.Application.DTOs
{
    /// <summary>
    /// Every chemist within the routing radius of a point, and whether each would actually receive an
    /// order placed there. Staff use it on the customer page to see, at a glance, why a customer can
    /// or cannot order.
    /// </summary>
    public class ChemistsNearLocationDto
    {
        /// <summary>The radius searched — the same one order routing uses.</summary>
        public double RadiusKm { get; set; }

        /// <summary>How many of <see cref="Chemists"/> would receive an order placed at this point.</summary>
        public int ReceivingOrdersCount { get; set; }

        /// <summary>Nearest first.</summary>
        public List<ChemistNearLocationDto> Chemists { get; set; } = new();
    }

    public class ChemistNearLocationDto
    {
        public Guid MedicalStoreId { get; set; }
        public string MedicalName { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public string PostalCode { get; set; } = string.Empty;
        public decimal Latitude { get; set; }
        public decimal Longitude { get; set; }

        /// <summary>Straight-line distance, rounded to 10 m.</summary>
        public double DistanceKm { get; set; }

        public bool IsActive { get; set; }

        /// <summary>A Razorpay payout account in the Active state.</summary>
        public bool PayoutActive { get; set; }

        /// <summary>The one-time activation fee is paid.</summary>
        public bool ActivationPaid { get; set; }

        /// <summary>
        /// All three conditions order routing checks. False means an order placed here would never be
        /// routed to this store, however close it is — see <see cref="NotReceivingReasons"/>.
        /// </summary>
        public bool ReceivesOrders => IsActive && PayoutActive && ActivationPaid;

        /// <summary>Plain-language reasons, empty when <see cref="ReceivesOrders"/> is true.</summary>
        public List<string> NotReceivingReasons { get; set; } = new();
    }
}
