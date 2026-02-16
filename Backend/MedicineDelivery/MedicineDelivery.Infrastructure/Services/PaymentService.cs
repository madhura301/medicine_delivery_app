using AutoMapper;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;
using MedicineDelivery.Domain.Entities;
using MedicineDelivery.Domain.Enums;
using MedicineDelivery.Domain.Interfaces;
using Microsoft.Extensions.Logging;

namespace MedicineDelivery.Infrastructure.Services
{
    public class PaymentService : IPaymentService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private readonly ILogger<PaymentService> _logger;

        public PaymentService(IUnitOfWork unitOfWork, IMapper mapper, ILogger<PaymentService> logger)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _logger = logger;
        }

        public async Task<PaymentDto> RecordPaymentAsync(RecordPaymentDto paymentDto, CancellationToken ct = default)
        {
            ArgumentNullException.ThrowIfNull(paymentDto);
            ct.ThrowIfCancellationRequested();

            // Validate order exists
            var order = await _unitOfWork.Orders.FirstOrDefaultAsync(o => o.OrderId == paymentDto.OrderId);
            if (order == null)
            {
                _logger.LogWarning("RecordPaymentAsync failed: Order {OrderId} not found", paymentDto.OrderId);
                throw new KeyNotFoundException($"Order with ID {paymentDto.OrderId} not found.");
            }

            // Create payment record
            var payment = new Payment
            {
                OrderId = paymentDto.OrderId,
                PaymentMode = paymentDto.PaymentMode,
                TransactionId = paymentDto.TransactionId,
                Amount = paymentDto.Amount,
                PaymentStatus = paymentDto.PaymentStatus,
                PaidOn = DateTime.UtcNow
            };

            await _unitOfWork.Payments.AddAsync(payment);
            await _unitOfWork.SaveChangesAsync();

            _logger.LogInformation("Payment recorded for Order {OrderId}: Amount={Amount}, Mode={PaymentMode}, Status={PaymentStatus}, TransactionId={TransactionId}",
                paymentDto.OrderId, paymentDto.Amount, paymentDto.PaymentMode, paymentDto.PaymentStatus, paymentDto.TransactionId);

            // Update order payment status if this payment was successful
            if (paymentDto.PaymentStatus == PaymentStatus.Success)
            {
                await UpdateOrderPaymentStatusAsync(order);
            }

            return _mapper.Map<PaymentDto>(payment);
        }

        public async Task<IEnumerable<PaymentDto>> GetPaymentsByOrderIdAsync(int orderId, CancellationToken ct = default)
        {
            ct.ThrowIfCancellationRequested();

            var payments = await _unitOfWork.Payments.FindAsync(p => p.OrderId == orderId);
            return _mapper.Map<IEnumerable<PaymentDto>>(payments);
        }

        public async Task<decimal> GetTotalPaidAmountAsync(int orderId, CancellationToken ct = default)
        {
            ct.ThrowIfCancellationRequested();

            var payments = await _unitOfWork.Payments.FindAsync(p => 
                p.OrderId == orderId && 
                p.PaymentStatus == PaymentStatus.Success);

            return payments.Sum(p => p.Amount);
        }

        private async Task UpdateOrderPaymentStatusAsync(Order order)
        {
            // Calculate total paid amount from successful payments
            var totalPaid = await GetTotalPaidAmountAsync(order.OrderId);
            var totalAmount = order.TotalAmount ?? 0;

            // Determine order payment status
            OrderPaymentStatus newStatus;
            if (totalPaid <= 0)
            {
                newStatus = OrderPaymentStatus.NotPaid;
            }
            else if (totalPaid >= totalAmount && totalAmount > 0)
            {
                newStatus = OrderPaymentStatus.FullyPaid;
            }
            else
            {
                newStatus = OrderPaymentStatus.PartiallyPaid;
            }

            // Update order if status changed
            if (order.OrderPaymentStatus != newStatus)
            {
                _logger.LogInformation("Order {OrderId} payment status changed from {OldStatus} to {NewStatus}. TotalPaid={TotalPaid}, TotalAmount={TotalAmount}",
                    order.OrderId, order.OrderPaymentStatus, newStatus, totalPaid, totalAmount);

                order.OrderPaymentStatus = newStatus;
                order.UpdatedOn = DateTime.UtcNow;
                _unitOfWork.Orders.Update(order);
                await _unitOfWork.SaveChangesAsync();
            }
        }
    }
}
