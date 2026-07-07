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
        private readonly IRazorpayRouteClient _routeClient;
        private readonly IPlatformFeeCalculator _feeCalculator;
        private readonly IConfiguration _configuration;
        private readonly ILogger<RazorpayService> _logger;

        public RazorpayService(
            IUnitOfWork unitOfWork,
            IPaymentService paymentService,
            IRazorpayRouteClient routeClient,
            IPlatformFeeCalculator feeCalculator,
            IConfiguration configuration,
            ILogger<RazorpayService> logger)
        {
            _unitOfWork = unitOfWork;
            _paymentService = paymentService;
            _routeClient = routeClient;
            _feeCalculator = feeCalculator;
            _configuration = configuration;
            _logger = logger;
        }

        public async Task<RazorpayOrderResult> CreateOrderAsync(int orderId, decimal amount, decimal? billAmount = null, decimal? convenienceFee = null)
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

                _logger.LogInformation(
                    "Razorpay request CreateOrder (SDK) OrderId={OrderId}, AmountInPaise={AmountInPaise}, Currency={Currency}",
                    orderId, amountInPaise, currency);

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

                // Persist the bill / convenience-fee breakdown on the order (used for the split).
                if (billAmount.HasValue || convenienceFee.HasValue)
                {
                    var order = await _unitOfWork.Orders.FirstOrDefaultAsync(o => o.OrderId == orderId);
                    if (order != null)
                    {
                        if (billAmount.HasValue) order.BillAmount = billAmount;
                        if (convenienceFee.HasValue) order.ConvenienceFee = convenienceFee;
                        order.UpdatedOn = DateTime.UtcNow;
                        _unitOfWork.Orders.Update(order);
                    }
                }

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

                // Split the captured funds (chemist transfer + Pharmaish retention).
                await SplitCapturedPaymentAsync(request, razorpayRecord.Amount);

                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error verifying Razorpay payment for RazorpayOrderId={RazorpayOrderId}", request.RazorpayOrderId);
                return false;
            }
        }

        /// <summary>
        /// Computes the bill/fee split and (when possible) transfers the chemist's share to
        /// their Route linked account. Always records a <see cref="PaymentSplit"/> audit row.
        /// Never throws — a split failure must not fail the already-captured payment.
        /// </summary>
        private async Task SplitCapturedPaymentAsync(RazorpayVerifyRequest request, decimal capturedTotal)
        {
            try
            {
                var order = await _unitOfWork.Orders.FirstOrDefaultAsync(o => o.OrderId == request.OrderId);

                // Resolve the slab base (bill) and the convenience fee.
                var billAmount = order?.BillAmount ?? order?.TotalAmount ?? capturedTotal;
                if (billAmount > capturedTotal) billAmount = capturedTotal;
                var convenienceFee = order?.ConvenienceFee ?? Math.Max(0m, capturedTotal - billAmount);

                // Resolve the store + payout account.
                MedicalStore? store = null;
                ChemistPayoutAccount? payout = null;
                if (order?.MedicalStoreId is Guid storeId)
                {
                    store = await _unitOfWork.MedicalStores.FirstOrDefaultAsync(s => s.MedicalStoreId == storeId);
                    payout = await _unitOfWork.ChemistPayoutAccounts.FirstOrDefaultAsync(a => a.MedicalStoreId == storeId);
                }

                var platformFee = _feeCalculator.CalculateFee(billAmount, store?.ActivatedOn);
                var chemistAmount = Math.Max(0m, billAmount - platformFee);
                var pharmaishAmount = capturedTotal - chemistAmount;

                var split = new PaymentSplit
                {
                    OrderId = request.OrderId,
                    RazorpayPaymentId = request.RazorpayPaymentId,
                    TotalCaptured = capturedTotal,
                    BillAmount = billAmount,
                    ConvenienceFee = convenienceFee,
                    PlatformFee = platformFee,
                    ChemistAmount = chemistAmount,
                    PharmaishAmount = pharmaishAmount,
                    TransferStatus = TransferStatus.Skipped,
                    CreatedAt = DateTime.UtcNow
                };

                var routeEnabled = GetBool("RazorpaySettings:RouteEnabled", false);
                var canTransfer = routeEnabled
                    && chemistAmount > 0
                    && payout != null
                    && payout.OnboardingStatus == ChemistPayoutStatus.Active
                    && !string.IsNullOrWhiteSpace(payout.RazorpayLinkedAccountId);

                if (canTransfer)
                {
                    var onHold = GetBool("RazorpaySettings:TransferOnHold", false);
                    var currency = _configuration["RazorpaySettings:Currency"] ?? "INR";

                    _logger.LogInformation(
                        "Splitting payment: attempting Route transfer for OrderId={OrderId}, ChemistAmount={ChemistAmount}, LinkedAccountId={LinkedAccountId}",
                        request.OrderId, chemistAmount, payout!.RazorpayLinkedAccountId);

                    var transfer = await _routeClient.CreateTransferOnPaymentAsync(new RazorpayTransferRequest
                    {
                        PaymentId = request.RazorpayPaymentId,
                        LinkedAccountId = payout!.RazorpayLinkedAccountId!,
                        AmountInPaise = (int)(chemistAmount * 100),
                        Currency = currency,
                        OnHold = onHold
                    });

                    split.ChemistLinkedAccountId = payout.RazorpayLinkedAccountId;
                    if (transfer.Success)
                    {
                        split.TransferStatus = TransferStatus.Completed;
                        split.RazorpayTransferId = transfer.TransferId;
                        _logger.LogInformation(
                            "Route transfer completed. OrderId={OrderId}, TransferId={TransferId}, ChemistAmount={ChemistAmount}",
                            request.OrderId, transfer.TransferId, chemistAmount);
                    }
                    else
                    {
                        split.TransferStatus = TransferStatus.Failed;
                        _logger.LogWarning(
                            "Route transfer failed. OrderId={OrderId}, Error={Error}. Recorded as Failed for later settlement.",
                            request.OrderId, transfer.Error);
                    }
                }
                else
                {
                    _logger.LogWarning(
                        "Route transfer skipped for OrderId={OrderId} (RouteEnabled={RouteEnabled}, chemist onboarded={Onboarded}). " +
                        "Recorded chemist amount {ChemistAmount} owed for later settlement.",
                        request.OrderId, routeEnabled, payout?.OnboardingStatus == ChemistPayoutStatus.Active, chemistAmount);
                }

                await _unitOfWork.PaymentSplits.AddAsync(split);
                await _unitOfWork.SaveChangesAsync();
            }
            catch (Exception ex)
            {
                // The payment is already captured & recorded; never fail it because of the split.
                _logger.LogError(ex, "Error splitting captured payment for OrderId={OrderId}", request.OrderId);
            }
        }

        private bool GetBool(string key, bool fallback)
        {
            return bool.TryParse(_configuration[key], out var value) ? value : fallback;
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
