namespace MedicineDelivery.Domain.Enums
{
    /// <summary>
    /// Why an order-placement attempt was recorded in <c>OrderLogs</c>. Stored as an int so the
    /// value is stable even if the display wording changes.
    /// </summary>
    public enum OrderLogReason
    {
        /// <summary>Fallback for an attempt whose cause could not be classified.</summary>
        Unknown = 0,

        /// <summary>
        /// The delivery area is not fully serviceable — at least one of chemist / customer support /
        /// delivery partner was unavailable. The three boolean columns say which.
        /// </summary>
        ServiceAreaUnavailable = 1,

        /// <summary>The customer record was missing or deactivated.</summary>
        CustomerNotFound = 2,

        /// <summary>The chosen delivery address was missing, deactivated, or not owned by the customer.</summary>
        AddressNotFound = 3,

        /// <summary>The submitted payload was rejected (missing text, missing/invalid file, bad type).</summary>
        ValidationFailed = 4,

        /// <summary>An unexpected server-side error interrupted order creation.</summary>
        UnexpectedError = 5
    }
}
