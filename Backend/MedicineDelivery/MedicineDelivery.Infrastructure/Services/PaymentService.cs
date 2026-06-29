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
        private readonly ISmsService _smsService;

        public PaymentService(IUnitOfWork unitOfWork, IMapper mapper, ILogger<PaymentService> logger, ISmsService smsService)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _logger = logger;
            _smsService = smsService;
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

        public async Task<PaymentSplitDto?> GetPaymentSplitAsync(int orderId, CancellationToken ct = default)
        {
            ct.ThrowIfCancellationRequested();

            var splits = await _unitOfWork.PaymentSplits.FindAsync(p => p.OrderId == orderId);
            var split = splits.OrderByDescending(p => p.CreatedAt).FirstOrDefault();
            if (split == null) return null;

            return new PaymentSplitDto
            {
                Id = split.Id,
                OrderId = split.OrderId,
                RazorpayPaymentId = split.RazorpayPaymentId,
                TotalCaptured = split.TotalCaptured,
                BillAmount = split.BillAmount,
                ConvenienceFee = split.ConvenienceFee,
                PlatformFee = split.PlatformFee,
                ChemistAmount = split.ChemistAmount,
                PharmaishAmount = split.PharmaishAmount,
                RazorpayTransferId = split.RazorpayTransferId,
                ChemistLinkedAccountId = split.ChemistLinkedAccountId,
                TransferStatus = split.TransferStatus,
                CreatedAt = split.CreatedAt
            };
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
                var previousStatus = order.OrderPaymentStatus;

                _logger.LogInformation("Order {OrderId} payment status changed from {OldStatus} to {NewStatus}. TotalPaid={TotalPaid}, TotalAmount={TotalAmount}",
                    order.OrderId, previousStatus, newStatus, totalPaid, totalAmount);

                order.OrderPaymentStatus = newStatus;
                order.UpdatedOn = DateTime.UtcNow;
                _unitOfWork.Orders.Update(order);
                await _unitOfWork.SaveChangesAsync();

                // Notify the customer once, on the transition into FullyPaid.
                if (newStatus == OrderPaymentStatus.FullyPaid && previousStatus != OrderPaymentStatus.FullyPaid)
                {
                    await SendPaymentConfirmationSmsAsync(order);
                }
            }
        }

        /// <summary>
        /// Sends the payment-confirmation SMS to the customer. Best-effort: failures are logged
        /// but never block the payment flow.
        /// </summary>
        private async Task SendPaymentConfirmationSmsAsync(Order order)
        {
            try
            {
                var customer = await _unitOfWork.Customers.FirstOrDefaultAsync(c => c.CustomerId == order.CustomerId);
                if (customer == null || string.IsNullOrWhiteSpace(customer.MobileNumber))
                {
                    _logger.LogWarning("Skipping payment-confirmation SMS for Order {OrderId}: customer or mobile number missing.", order.OrderId);
                    return;
                }

                var storeName = string.Empty;
                if (order.MedicalStoreId.HasValue)
                {
                    var store = await _unitOfWork.MedicalStores.FirstOrDefaultAsync(s => s.MedicalStoreId == order.MedicalStoreId.Value);
                    storeName = store?.MedicalName ?? string.Empty;
                }

                await _smsService.SendPaymentConfirmationAsync(
                    customer.MobileNumber,
                    customer.CustomerFirstName,
                    order.OrderNumber ?? order.OrderId.ToString(),
                    storeName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to send payment-confirmation SMS for Order {OrderId}.", order.OrderId);
            }
        }
    }
}
