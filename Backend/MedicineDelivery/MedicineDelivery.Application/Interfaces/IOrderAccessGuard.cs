namespace MedicineDelivery.Application.Interfaces
{
    /// <summary>
    /// Object-level authorization for orders (security finding C-02).
    ///
    /// Permission checks alone are insufficient: every role that can read an order holds the same
    /// <c>ReadOrders</c> permission, so without an ownership test any authenticated customer could
    /// read and mutate ANY order in the system. These methods answer "is this caller actually a
    /// party to this order?".
    ///
    /// Callers holding <c>ListAllOrders</c> (Admin, Manager) bypass the check via
    /// <paramref name="hasFullAccess"/>.
    /// </summary>
    public interface IOrderAccessGuard
    {
        /// <summary>True when the user is the order's customer, chemist, delivery partner,
        /// assigned customer-support agent or escalation manager.</summary>
        Task<bool> CanAccessOrderAsync(string userId, bool hasFullAccess, int orderId, CancellationToken cancellationToken = default);

        /// <summary>True when the user IS the given customer (or has full access).</summary>
        Task<bool> CanAccessCustomerAsync(string userId, bool hasFullAccess, Guid customerId, CancellationToken cancellationToken = default);

        /// <summary>
        /// Strict ownership test for a customer's own personal records — addresses and their GPS
        /// coordinates (finding H-01).
        ///
        /// Unlike <see cref="CanAccessCustomerAsync"/>, this does NOT grant blanket access to any
        /// staff member: a chemist or delivery partner must obtain a delivery address through the
        /// order they are fulfilling, not by browsing a customer's address book. Only the customer
        /// themselves, or a caller with full access (<c>AllCustomerRead</c> — Admin/Manager/
        /// CustomerSupport), may read these records.
        /// </summary>
        Task<bool> CanAccessCustomerRecordAsync(string userId, bool hasFullAccess, Guid customerId, CancellationToken cancellationToken = default);

        /// <summary>True when the user operates the given medical store (or has full access).</summary>
        Task<bool> CanAccessMedicalStoreAsync(string userId, bool hasFullAccess, Guid medicalStoreId, CancellationToken cancellationToken = default);

        /// <summary>
        /// Returns the order's delivery OTP ONLY when both conditions hold (finding H-02):
        /// (1) the order is fully paid, and (2) <paramref name="userId"/> is the order's own customer.
        /// Returns null in every other case — including for staff, chemists and delivery partners,
        /// and for the customer's own order while it is unpaid.
        /// </summary>
        Task<string?> GetVisibleOtpAsync(string userId, int orderId, CancellationToken cancellationToken = default);

        /// <summary>Bulk form of <see cref="GetVisibleOtpAsync"/> for list endpoints: maps orderId → OTP
        /// for those the caller may see.</summary>
        Task<IReadOnlyDictionary<int, string>> GetVisibleOtpsAsync(string userId, IEnumerable<int> orderIds, CancellationToken cancellationToken = default);
    }
}
