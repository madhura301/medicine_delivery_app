using System.Security.Cryptography;
using System.Text;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using MedicineDelivery.Application.Interfaces;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Domain.Entities;
using MedicineDelivery.Domain.Enums;
using MedicineDelivery.Domain.Interfaces;
using Razorpay.Api;

namespace MedicineDelivery.Infrastructure.Services
{
    public class RazorpayService : IRazorpayService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IPaymentService _paymentService;
        private readonly IConfiguration _configuration;
        private readonly ILogger<RazorpayService> _logger;

        public RazorpayService(
            IUnitOfWork unitOfWork,
            IPaymentService paymentService,
            IConfiguration configuration,
            ILogger<RazorpayService> logger)
        {
            _unitOfWork = unitOfWork;
            _paymentService = paymentService;
            _configuration = configuration;
            _logger = logger;
        }

        public async Task<RazorpayOrderResult> CreateOrderAsync(int orderId, decimal amount)
        {
            try
            {
                var keyId = _configuration["RazorpaySettings:KeyId"] ?? string.Empty;
                var keySecret = _configuration["RazorpaySettings:KeySecret"] ?? string.Empty;
                var currency = _configuration["RazorpaySettings:Currency"] ?? "INR";

                // Razorpay amounts are in the smallest currency unit (paise for INR)
                var amountInPaise = (int)(amount * 100);

                var client = new RazorpayClient(keyId, keySecret);

                var options = new Dictionary<string, object>
                {
                    { "amount", amountInPaise },
                    { "currency", currency },
                    { "receipt", orderId.ToString() },
                    { "payment_capture", 1 }
                };

                var razorpayOrder = client.Order.Create(options);
                var razorpayOrderId = (string)razorpayOrder["id"].ToString();

                var record = new RazorpayOrder
                {
                    OrderId = orderId,
                    RazorpayOrderId = razorpayOrderId,
                    Amount = amount,
                    Currency = currency,
                    Status = RazorpayOrderStatus.Created,
                    CreatedAt = DateTime.UtcNow
                };

                await _unitOfWork.RazorpayOrders.AddAsync(record);
                await _unitOfWork.SaveChangesAsync();

                _logger.LogInformation(
                    "Razorpay order created. RazorpayOrderId={RazorpayOrderId}, InternalOrderId={OrderId}, Amount={Amount}",
                    razorpayOrderId, orderId, amount);

                return new RazorpayOrderResult
                {
                    Success = true,
                    RazorpayOrderId = razorpayOrderId,
                    Amount = amount,
                    Currency = currency,
                    KeyId = keyId
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating Razorpay order for OrderId={OrderId}", orderId);
                return new RazorpayOrderResult
                {
                    Success = false,
                    Errors = new List<string> { "Failed to create payment order. Please try again." }
                };
            }
        }

        public async Task<bool> VerifyAndCapturePaymentAsync(RazorpayVerifyRequest request)
        {
            try
            {
                var keySecret = _configuration["RazorpaySettings:KeySecret"] ?? string.Empty;

                // Verify HMAC-SHA256 signature: HMAC(razorpayOrderId + "|" + razorpayPaymentId, keySecret)
                var payload = $"{request.RazorpayOrderId}|{request.RazorpayPaymentId}";
                var expectedSignature = ComputeHmacSha256(payload, keySecret);

                if (!string.Equals(expectedSignature, request.RazorpaySignature, StringComparison.OrdinalIgnoreCase))
                {
                    _logger.LogWarning(
                        "Razorpay signature verification failed for RazorpayOrderId={RazorpayOrderId}",
                        request.RazorpayOrderId);
                    return false;
                }

                var razorpayRecord = await _unitOfWork.RazorpayOrders
                    .FirstOrDefaultAsync(r => r.RazorpayOrderId == request.RazorpayOrderId);

                if (razorpayRecord == null)
                {
                    _logger.LogWarning(
                        "RazorpayOrder record not found for RazorpayOrderId={RazorpayOrderId}",
                        request.RazorpayOrderId);
                    return false;
                }

                razorpayRecord.Status = RazorpayOrderStatus.Paid;
                razorpayRecord.RazorpayPaymentId = request.RazorpayPaymentId;
                razorpayRecord.RazorpaySignature = request.RazorpaySignature;

                _unitOfWork.RazorpayOrders.Update(razorpayRecord);

                // Record payment through the existing payment service
                var paymentDto = new RecordPaymentDto
                {
                    OrderId = request.OrderId,
                    PaymentMode = "Razorpay",
                    TransactionId = request.RazorpayPaymentId,
                    Amount = razorpayRecord.Amount,
                    PaymentStatus = Domain.Enums.PaymentStatus.Success
                };

                await _paymentService.RecordPaymentAsync(paymentDto, CancellationToken.None);
                await _unitOfWork.SaveChangesAsync();

                _logger.LogInformation(
                    "Razorpay payment captured. RazorpayPaymentId={RazorpayPaymentId}, OrderId={OrderId}",
                    request.RazorpayPaymentId, request.OrderId);

                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error verifying Razorpay payment for RazorpayOrderId={RazorpayOrderId}", request.RazorpayOrderId);
                return false;
            }
        }

        private static string ComputeHmacSha256(string payload, string secret)
        {
            var keyBytes = Encoding.UTF8.GetBytes(secret);
            var payloadBytes = Encoding.UTF8.GetBytes(payload);
            using var hmac = new HMACSHA256(keyBytes);
            var hashBytes = hmac.ComputeHash(payloadBytes);
            return Convert.ToHexString(hashBytes).ToLowerInvariant();
        }
    }
}
