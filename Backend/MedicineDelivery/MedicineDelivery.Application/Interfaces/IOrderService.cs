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
        Task<IEnumerable<OrderDto>> GetActiveOrdersByMedicalStoreIdAsync(Guid medicalStoreId, CancellationToken cancellationToken = default);
        Task<OrderDto> AcceptOrderByChemistAsync(int orderId, CancellationToken cancellationToken = default);
        Task<OrderDto> RejectOrderByChemistAsync(int orderId, RejectOrderDto rejectDto, CancellationToken cancellationToken = default);
    }
}


