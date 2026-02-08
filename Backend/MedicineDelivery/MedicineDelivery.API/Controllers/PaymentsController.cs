using System.Threading;
using System.Threading.Tasks;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace MedicineDelivery.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class PaymentsController : ControllerBase
    {
        private readonly IPaymentService _paymentService;

        public PaymentsController(IPaymentService paymentService)
        {
            _paymentService = paymentService;
        }

        /// <summary>
        /// Record a payment for an order (for webhook from payment provider)
        /// </summary>
        /// <param name="paymentDto">Payment details</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Recorded payment</returns>
        [HttpPost]
        [Authorize(Policy = "RequireOrderUpdatePermission")]
        public async Task<IActionResult> RecordPayment([FromBody] RecordPaymentDto paymentDto, CancellationToken cancellationToken)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var payment = await _paymentService.RecordPaymentAsync(paymentDto, cancellationToken);
                return CreatedAtAction(nameof(GetPaymentsByOrderId), new { orderId = payment.OrderId }, payment);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { error = ex.Message });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception)
            {
                return StatusCode(500, new { error = "An error occurred while recording the payment." });
            }
        }

        /// <summary>
        /// Get all payments for an order
        /// </summary>
        /// <param name="orderId">Order ID</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>List of payments</returns>
        [HttpGet("order/{orderId:int}")]
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<IActionResult> GetPaymentsByOrderId(int orderId, CancellationToken cancellationToken)
        {
            try
            {
                var payments = await _paymentService.GetPaymentsByOrderIdAsync(orderId, cancellationToken);
                return Ok(payments);
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception)
            {
                return StatusCode(500, new { error = "An error occurred while retrieving payments." });
            }
        }

        /// <summary>
        /// Get total paid amount for an order
        /// </summary>
        /// <param name="orderId">Order ID</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Total paid amount</returns>
        [HttpGet("order/{orderId:int}/total")]
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<IActionResult> GetTotalPaidAmount(int orderId, CancellationToken cancellationToken)
        {
            try
            {
                var totalPaid = await _paymentService.GetTotalPaidAmountAsync(orderId, cancellationToken);
                return Ok(new { orderId, totalPaidAmount = totalPaid });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception)
            {
                return StatusCode(500, new { error = "An error occurred while retrieving total paid amount." });
            }
        }
    }
}
