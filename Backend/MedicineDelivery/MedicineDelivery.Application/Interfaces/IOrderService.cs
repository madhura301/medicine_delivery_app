using System.Threading;
using System.Threading.Tasks;
using MedicineDelivery.Application.DTOs;

namespace MedicineDelivery.Application.Interfaces
{
    public interface IOrderService
    {
        Task<OrderDto> CreateOrderAsync(CreateOrderDto createDto, CancellationToken cancellationToken = default);
        Task<OrderDto?> GetOrderByIdAsync(int orderId, CancellationToken cancellationToken = default);
        Task<IEnumerable<OrderDto>> GetOrdersByCustomerIdAsync(Guid customerId, CancellationToken cancellationToken = default);
        Task<IEnumerable<OrderDto>> GetActiveOrdersByCustomerIdAsync(Guid customerId, CancellationToken cancellationToken = default);
        Task<IEnumerable<OrderDto>> GetActiveOrdersByMedicalStoreIdAsync(Guid medicalStoreId, CancellationToken cancellationToken = default);
        Task<IEnumerable<OrderDto>> GetAcceptedOrdersByMedicalStoreIdAsync(Guid medicalStoreId, CancellationToken cancellationToken = default);
        Task<IEnumerable<OrderDto>> GetRejectedOrdersByMedicalStoreIdAsync(Guid medicalStoreId, CancellationToken cancellationToken = default);
        Task<IEnumerable<OrderDto>> GetAllOrdersByMedicalStoreIdAsync(Guid medicalStoreId, CancellationToken cancellationToken = default);
        Task<OrderDto> AcceptOrderByChemistAsync(int orderId, CancellationToken cancellationToken = default);
        Task<OrderDto> RejectOrderByChemistAsync(int orderId, RejectOrderDto rejectDto, CancellationToken cancellationToken = default);
        Task<OrderDto> CompleteOrderAsync(int orderId, CompleteOrderDto completeDto, CancellationToken cancellationToken = default);
        Task<OrderDto> AssignOrderToMedicalStoreAsync(AssignOrderDto assignDto, CancellationToken cancellationToken = default);
        Task AssignOrderToNearestChemist(int orderId);
        Task<OrderDto> UploadOrderBillAsync(UploadOrderBillDto uploadDto, CancellationToken cancellationToken = default);
        Task<OrderDto> AssignOrderToDeliveryAsync(AssignOrderToDeliveryDto assignDto, CancellationToken cancellationToken = default);
        Task<IEnumerable<OrderDto>> GetAllOrdersAsync(CancellationToken cancellationToken = default);
    }
}


