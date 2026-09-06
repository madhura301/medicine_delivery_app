using MedicineDelivery.Domain.Enums;

namespace MedicineDelivery.Domain.Entities
{
    /// <summary>
    /// An audit row written every time a customer tries to place an order and it is refused.
    ///
    /// The refusal reason previously existed only in the application log file, so support staff had
    /// no way to answer "why couldn't my customer order?". This table captures the same information
    /// in a queryable form and is surfaced in the staff console under "Order Log".
    ///
    /// Rows are written on a best-effort basis: a failure to record the log never changes the
    /// outcome of the customer's request.
    /// </summary>
    public class OrderLog
    {
        public long OrderLogId { get; set; }

        public Guid? CustomerId { get; set; }

        /// <summary>Full name captured at the time of the attempt — kept even if the customer is later renamed.</summary>
        public string? CustomerName { get; set; }

        public string? CustomerMobileNumber { get; set; }

        public Guid? CustomerAddressId { get; set; }

        /// <summary>The delivery address as a single readable line, flattened at the time of the attempt.</summary>
        public string? DeliveryAddress { get; set; }

        public string? PostalCode { get; set; }

        public decimal? Latitude { get; set; }

        public decimal? Longitude { get; set; }

        public OrderLogReason Reason { get; set; } = OrderLogReason.Unknown;

        /// <summary>Short human-readable summary shown in the list view.</summary>
        public string ReasonSummary { get; set; } = string.Empty;

        /// <summary>True when no eligible chemist (active payout + paid activation) could serve the address.</summary>
        public bool ChemistUnavailable { get; set; }

        /// <summary>True when no active customer support agent covers the address's pin code.</summary>
        public bool CustomerSupportUnavailable { get; set; }

        /// <summary>True when no active delivery partner covers the address's pin code.</summary>
        public bool DeliveryBoyUnavailable { get; set; }

        /// <summary>
        /// Everything known about the attempt, as free text — the same detail that goes to the
        /// application log, so support can diagnose without pulling log files.
        /// </summary>
        public string? Details { get; set; }

        public DateTime CreatedOn { get; set; } = DateTime.UtcNow;
    }
}
