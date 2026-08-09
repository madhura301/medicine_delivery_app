using MedicineDelivery.Application.Interfaces;
using MedicineDelivery.Domain.Enums;
using MedicineDelivery.Domain.Interfaces;
using Microsoft.Extensions.Logging;

namespace MedicineDelivery.Infrastructure.Services
{
    /// <summary>
    /// Ownership/relationship checks for orders — see <see cref="IOrderAccessGuard"/> (finding C-02).
    /// Each role's link to an order is resolved through its own entity's <c>UserId</c>.
    /// </summary>
    public class OrderAccessGuard : IOrderAccessGuard
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ILogger<OrderAccessGuard> _logger;

        public OrderAccessGuard(IUnitOfWork unitOfWork, ILogger<OrderAccessGuard> logger)
        {
            _unitOfWork = unitOfWork;
            _logger = logger;
        }

        public async Task<bool> CanAccessOrderAsync(string userId, bool hasFullAccess, int orderId, CancellationToken cancellationToken = default)
        {
            if (hasFullAccess) return true;
            if (string.IsNullOrWhiteSpace(userId)) return false;

            var order = await _unitOfWork.Orders.FirstOrDefaultAsync(o => o.OrderId == orderId);
            if (order == null) return true;   // let the action return its own 404

            // The order's customer.
            var customer = await _unitOfWork.Customers.FirstOrDefaultAsync(c => c.UserId == userId);
            if (customer != null && customer.CustomerId == order.CustomerId) return true;

            // The chemist fulfilling it.
            if (order.MedicalStoreId.HasValue)
            {
                var store = await _unitOfWork.MedicalStores.FirstOrDefaultAsync(s => s.UserId == userId);
                if (store != null && store.MedicalStoreId == order.MedicalStoreId.Value) return true;
            }

            // The delivery partner it is assigned to.
            if (order.DeliveryId.HasValue)
            {
                var delivery = await _unitOfWork.Deliveries.FirstOrDefaultAsync(d => d.UserId == userId);
                if (delivery != null && delivery.Id == order.DeliveryId.Value) return true;
            }

            // The customer-support agent handling a rejected order.
            if (order.CustomerSupportId.HasValue)
            {
                var support = await _unitOfWork.CustomerSupports.FirstOrDefaultAsync(cs => cs.UserId == userId);
                if (support != null && support.CustomerSupportId == order.CustomerSupportId.Value) return true;
            }

            // The manager an order was escalated to.
            if (order.ManagerId.HasValue)
            {
                var manager = await _unitOfWork.Managers.FirstOrDefaultAsync(m => m.UserId == userId);
                if (manager != null && manager.ManagerId == order.ManagerId.Value) return true;
            }

            _logger.LogWarning("Order access denied: UserId {UserId} is not a party to Order {OrderId}", userId, orderId);
            return false;
        }

        public async Task<bool> CanAccessCustomerAsync(string userId, bool hasFullAccess, Guid customerId, CancellationToken cancellationToken = default)
        {
            if (hasFullAccess) return true;
            if (string.IsNullOrWhiteSpace(userId)) return false;

            // Staff who handle orders (chemist / support / manager) may look up a customer's orders.
            var customer = await _unitOfWork.Customers.FirstOrDefaultAsync(c => c.UserId == userId);
            if (customer != null) return customer.CustomerId == customerId;

            var isStaff =
                await _unitOfWork.MedicalStores.AnyAsync(s => s.UserId == userId) ||
                await _unitOfWork.CustomerSupports.AnyAsync(cs => cs.UserId == userId) ||
                await _unitOfWork.Managers.AnyAsync(m => m.UserId == userId);

            if (!isStaff)
                _logger.LogWarning("Customer-orders access denied: UserId {UserId} for Customer {CustomerId}", userId, customerId);
            return isStaff;
        }

        public async Task<bool> CanAccessCustomerRecordAsync(string userId, bool hasFullAccess, Guid customerId, CancellationToken cancellationToken = default)
        {
            if (hasFullAccess) return true;
            if (string.IsNullOrWhiteSpace(userId)) return false;

            // Strictly the customer themselves — no implicit staff bypass (finding H-01).
            var customer = await _unitOfWork.Customers.FirstOrDefaultAsync(c => c.UserId == userId);
            if (customer != null && customer.CustomerId == customerId) return true;

            _logger.LogWarning("Customer-record access denied: UserId {UserId} for Customer {CustomerId}", userId, customerId);
            return false;
        }

        public async Task<bool> CanAccessMedicalStoreAsync(string userId, bool hasFullAccess, Guid medicalStoreId, CancellationToken cancellationToken = default)
        {
            if (hasFullAccess) return true;
            if (string.IsNullOrWhiteSpace(userId)) return false;

            var store = await _unitOfWork.MedicalStores.FirstOrDefaultAsync(s => s.UserId == userId);
            if (store != null) return store.MedicalStoreId == medicalStoreId;

            // Support/manager staff legitimately review store queues during re-assignment.
            var isStaff =
                await _unitOfWork.CustomerSupports.AnyAsync(cs => cs.UserId == userId) ||
                await _unitOfWork.Managers.AnyAsync(m => m.UserId == userId);

            if (!isStaff)
                _logger.LogWarning("Store-orders access denied: UserId {UserId} for Store {StoreId}", userId, medicalStoreId);
            return isStaff;
        }

        public async Task<string?> GetVisibleOtpAsync(string userId, int orderId, CancellationToken cancellationToken = default)
        {
            if (string.IsNullOrWhiteSpace(userId)) return null;

            var order = await _unitOfWork.Orders.FirstOrDefaultAsync(o => o.OrderId == orderId);
            if (order == null || string.IsNullOrWhiteSpace(order.OTP)) return null;

            // (1) Only once the order is fully paid.
            if (order.OrderPaymentStatus != OrderPaymentStatus.FullyPaid) return null;

            // (2) Only to the customer who owns the order.
            var customer = await _unitOfWork.Customers.FirstOrDefaultAsync(c => c.UserId == userId);
            if (customer == null || customer.CustomerId != order.CustomerId) return null;

            return order.OTP;
        }

        public async Task<IReadOnlyDictionary<int, string>> GetVisibleOtpsAsync(string userId, IEnumerable<int> orderIds, CancellationToken cancellationToken = default)
        {
            var result = new Dictionary<int, string>();
            if (string.IsNullOrWhiteSpace(userId)) return result;

            var ids = orderIds?.Distinct().ToList() ?? new List<int>();
            if (ids.Count == 0) return result;

            // Resolve the caller's customer identity once.
            var customer = await _unitOfWork.Customers.FirstOrDefaultAsync(c => c.UserId == userId);
            if (customer == null) return result;

            var orders = await _unitOfWork.Orders.FindAsync(o =>
                ids.Contains(o.OrderId) &&
                o.CustomerId == customer.CustomerId &&
                o.OrderPaymentStatus == OrderPaymentStatus.FullyPaid);

            foreach (var o in orders)
            {
                if (!string.IsNullOrWhiteSpace(o.OTP)) result[o.OrderId] = o.OTP!;
            }

            return result;
        }
    }
}
