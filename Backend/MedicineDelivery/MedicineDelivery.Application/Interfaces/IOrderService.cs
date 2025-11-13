using System.Threading;
using System.Threading.Tasks;
using MedicineDelivery.Application.DTOs;

namespace MedicineDelivery.Application.Interfaces
{
    public interface IOrderService
    {
        Task<OrderDto> CreateOrderAsync(CreateOrderDto createDto, CancellationToken cancellationToken = default);
        Task<OrderDto?> GetOrderByIdAsync(int orderId, CancellationToken cancellationToken = default);
    }
}


