using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Domain.Interfaces;

namespace MedicineDelivery.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class RazorpayController : ControllerBase
    {
        private readonly IRazorpayService _razorpayService;
        private readonly ILogger<RazorpayController> _logger;

        public RazorpayController(IRazorpayService razorpayService, ILogger<RazorpayController> logger)
        {
            _razorpayService = razorpayService;
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

            var result = await _razorpayService.CreateOrderAsync(request.OrderId, request.Amount);

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
    }
}
