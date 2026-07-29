using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;
using MedicineDelivery.Domain.Interfaces;
using System.Security.Claims;

namespace MedicineDelivery.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class RazorpayController : ControllerBase
    {
        private readonly IRazorpayService _razorpayService;
        private readonly IPaymentService _paymentService;
        private readonly IOrderAccessGuard _accessGuard;
        private readonly IPermissionCheckerService _permissionChecker;
        private readonly ILogger<RazorpayController> _logger;

        public RazorpayController(
            IRazorpayService razorpayService,
            IPaymentService paymentService,
            IOrderAccessGuard accessGuard,
            IPermissionCheckerService permissionChecker,
            ILogger<RazorpayController> logger)
        {
            _razorpayService = razorpayService;
            _paymentService = paymentService;
            _accessGuard = accessGuard;
            _permissionChecker = permissionChecker;
            _logger = logger;
        }

        /// <summary>
        /// Creates a Razorpay order for the given internal order.
        /// Returns the Razorpay order ID, amount, currency and public key so the
        /// client can open the Razorpay checkout widget.
        /// </summary>
        [HttpPost("create-order")]
        [Authorize]
        public async Task<IActionResult> CreateOrder([FromBody] RazorpayCreateOrderDto request)
        {
            if (request.OrderId <= 0)
                return BadRequest(new { message = "A valid OrderId is required." });

            if (request.Amount <= 0)
                return BadRequest(new { message = "Amount must be greater than zero." });

            _logger.LogInformation("Create Razorpay order request. OrderId={OrderId}, Amount={Amount}",
                request.OrderId, request.Amount);

            var result = await _razorpayService.CreateOrderAsync(
                request.OrderId, request.Amount, request.BillAmount, request.ConvenienceFee);

            if (!result.Success)
            {
                _logger.LogWarning("Failed to create Razorpay order for OrderId={OrderId}. Errors: {Errors}",
                    request.OrderId, string.Join(", ", result.Errors));
                return BadRequest(new { message = result.Errors.FirstOrDefault() ?? "Failed to create payment order." });
            }

            return Ok(new RazorpayOrderResponseDto
            {
                RazorpayOrderId = result.RazorpayOrderId!,
                Amount = result.Amount,
                Currency = result.Currency,
                KeyId = result.KeyId!
            });
        }

        /// <summary>
        /// Verifies the Razorpay payment signature and records the payment.
        /// The client must call this after a successful checkout to confirm payment on the server.
        /// </summary>
        [HttpPost("verify-payment")]
        [Authorize]
        public async Task<IActionResult> VerifyPayment([FromBody] RazorpayVerifyPaymentDto request)
        {
            if (string.IsNullOrWhiteSpace(request.RazorpayOrderId) ||
                string.IsNullOrWhiteSpace(request.RazorpayPaymentId) ||
                string.IsNullOrWhiteSpace(request.RazorpaySignature))
            {
                return BadRequest(new { message = "RazorpayOrderId, RazorpayPaymentId and RazorpaySignature are required." });
            }

            _logger.LogInformation(
                "Verify Razorpay payment. OrderId={OrderId}, RazorpayOrderId={RazorpayOrderId}, RazorpayPaymentId={RazorpayPaymentId}",
                request.OrderId, request.RazorpayOrderId, request.RazorpayPaymentId);

            var verifyRequest = new RazorpayVerifyRequest
            {
                OrderId = request.OrderId,
                RazorpayOrderId = request.RazorpayOrderId,
                RazorpayPaymentId = request.RazorpayPaymentId,
                RazorpaySignature = request.RazorpaySignature
            };

            var success = await _razorpayService.VerifyAndCapturePaymentAsync(verifyRequest);

            if (!success)
            {
                _logger.LogWarning("Razorpay payment verification failed for RazorpayOrderId={RazorpayOrderId}",
                    request.RazorpayOrderId);
                return BadRequest(new { message = "Payment verification failed. Signature mismatch or order not found." });
            }

            _logger.LogInformation("Razorpay payment verified and captured for RazorpayPaymentId={RazorpayPaymentId}",
                request.RazorpayPaymentId);

            return Ok(new { message = "Payment verified and recorded successfully." });
        }

        /// <summary>
        /// Returns how the captured payment for an order was split between the chemist and Pharmaish.
        /// </summary>
        [HttpGet("payment-split/{orderId:int}")]
        // H-01: order ids are sequential, so a bare [Authorize] let any logged-in user enumerate
        // per-order commercial data. Require an order-read permission AND party-to-the-order status.
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<IActionResult> GetPaymentSplit(int orderId, CancellationToken ct)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? string.Empty;
            var hasFullAccess = await _permissionChecker.HasPermissionAsync(User, "ListAllOrders");

            if (!await _accessGuard.CanAccessOrderAsync(userId, hasFullAccess, orderId, ct))
            {
                _logger.LogWarning("Payment-split access denied: UserId {UserId} for Order {OrderId}", userId, orderId);
                return Forbid();
            }

            var split = await _paymentService.GetPaymentSplitAsync(orderId, ct);
            if (split == null)
                return NotFound(new { message = "No payment split found for this order." });

            return Ok(split);
        }
    }
}
