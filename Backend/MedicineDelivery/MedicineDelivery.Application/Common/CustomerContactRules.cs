using MedicineDelivery.Domain.Enums;

namespace MedicineDelivery.Application.Common
{
    /// <summary>
    /// When a chemist may see the phone number of the customer whose order they are handling.
    /// Kept apart from the access guard so the rule can be tested on its own.
    /// </summary>
    public static class CustomerContactRules
    {
        /// <summary>
        /// The stages in which the store on the order is still working on it: from assignment,
        /// so the chemist can clarify the order before accepting, until the delivery partner
        /// has it. Rejected, escalated, completed and cancelled orders are excluded — a rejected
        /// order keeps its MedicalStoreId while support handles it, so the store alone is not enough.
        /// </summary>
        public static readonly IReadOnlySet<OrderStatus> ContactStages = new HashSet<OrderStatus>
        {
            OrderStatus.AssignedToChemist,
            OrderStatus.AcceptedByChemist,
            OrderStatus.BillUploaded,
            OrderStatus.Paid,
            OrderStatus.OutForDelivery,
        };

        /// <summary>
        /// True when <paramref name="callerStoreId"/> is the store currently handling the order and
        /// the order is in one of the <see cref="ContactStages"/>. Reassignment moves the order's
        /// MedicalStoreId to the new store, so the previous store loses access at that moment.
        /// </summary>
        public static bool StoreMaySeeCustomerContact(Guid? orderStoreId, OrderStatus status, Guid callerStoreId) =>
            orderStoreId.HasValue
            && orderStoreId.Value == callerStoreId
            && ContactStages.Contains(status);
    }
}
