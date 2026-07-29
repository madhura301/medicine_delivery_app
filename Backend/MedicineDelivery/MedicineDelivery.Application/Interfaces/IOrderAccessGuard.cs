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

        /// <summary>True when the user operates the given medical store (or has full access).</summary>
        Task<bool> CanAccessMedicalStoreAsync(string userId, bool hasFullAccess, Guid medicalStoreId, CancellationToken cancellationToken = default);
    }
}
