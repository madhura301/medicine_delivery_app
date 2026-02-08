using MedicineDelivery.Application.DTOs;

namespace MedicineDelivery.Application.Interfaces
{
    public interface IPaymentService
    {
        Task<PaymentDto> RecordPaymentAsync(RecordPaymentDto paymentDto, CancellationToken ct = default);
        Task<IEnumerable<PaymentDto>> GetPaymentsByOrderIdAsync(int orderId, CancellationToken ct = default);
        Task<decimal> GetTotalPaidAmountAsync(int orderId, CancellationToken ct = default);
    }
}
