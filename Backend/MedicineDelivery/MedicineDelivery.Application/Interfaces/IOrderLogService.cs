using System.Threading;
using System.Threading.Tasks;
using MedicineDelivery.Application.DTOs;

namespace MedicineDelivery.Application.Interfaces
{
    /// <summary>
    /// Read-only access to the audit trail of refused order attempts. Rows are written by
    /// <c>IOrderService.CreateOrderAsync</c>; nothing in the application edits or deletes them.
    /// </summary>
    public interface IOrderLogService
    {
        Task<PagedResultDto<OrderLogListItemDto>> GetOrderLogsAsync(OrderLogQueryDto query, CancellationToken cancellationToken = default);

        Task<OrderLogDto?> GetOrderLogByIdAsync(long orderLogId, CancellationToken cancellationToken = default);
    }
}
