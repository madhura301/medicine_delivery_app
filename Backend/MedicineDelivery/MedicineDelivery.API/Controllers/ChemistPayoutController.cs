using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace MedicineDelivery.API.Controllers
{
    /// <summary>
    /// Onboards chemists (medical stores) as Razorpay Route linked accounts and exposes
    /// their payout/onboarding status. Prerequisite for splitting order payments (Phase 2).
    /// </summary>
    [ApiController]
    [Route("api/chemist-payout")]
    [Authorize]
    public class ChemistPayoutController : ControllerBase
    {
        private readonly IChemistPayoutService _chemistPayoutService;
        private readonly IChemistActivationService _chemistActivationService;
        private readonly ILogger<ChemistPayoutController> _logger;

        public ChemistPayoutController(
            IChemistPayoutService chemistPayoutService,
            IChemistActivationService chemistActivationService,
            ILogger<ChemistPayoutController> logger)
        {
            _chemistPayoutService = chemistPayoutService;
            _chemistActivationService = chemistActivationService;
            _logger = logger;
        }

        /// <summary>
        /// Creates (or resumes) the Razorpay linked account for a medical store using the
        /// supplied bank details and the store's stored KYC.
        /// </summary>
        [HttpPost("{storeId:guid}/onboard")]
        [Authorize(Policy = "RequireChemistUpdatePermission")]
        public async Task<IActionResult> Onboard(Guid storeId, [FromBody] OnboardChemistPayoutDto request, CancellationToken ct)
        {
            _logger.LogInformation("Chemist payout onboard requested for store {StoreId}", storeId);

            var result = await _chemistPayoutService.OnboardAsync(storeId, request, ct);
            if (!result.Success)
                return BadRequest(new { errors = result.Errors });

            return Ok(result.Data);
        }

        /// <summary>Returns the current payout/onboarding status for a medical store.</summary>
        [HttpGet("{storeId:guid}")]
        [Authorize(Policy = "RequireChemistReadPermission")]
        public async Task<IActionResult> GetStatus(Guid storeId, CancellationToken ct)
        {
            var result = await _chemistPayoutService.GetStatusAsync(storeId, ct);
            if (!result.Success)
                return NotFound(new { errors = result.Errors });

            return Ok(result.Data);
        }

        /// <summary>Updates the chemist's bank details and re-submits the Route product configuration.</summary>
        [HttpPut("{storeId:guid}/bank")]
        [Authorize(Policy = "RequireChemistUpdatePermission")]
        public async Task<IActionResult> UpdateBank(Guid storeId, [FromBody] UpdateChemistBankDto request, CancellationToken ct)
        {
            _logger.LogInformation("Chemist payout bank update requested for store {StoreId}", storeId);

            var result = await _chemistPayoutService.UpdateBankDetailsAsync(storeId, request, ct);
            if (!result.Success)
                return BadRequest(new { errors = result.Errors });

            return Ok(result.Data);
        }

        /// <summary>
        /// Creates (or returns the pending) Razorpay Payment Link for the store's one-time
        /// activation/onboarding fee (₹14,999 + GST).
        /// </summary>
        [HttpPost("{storeId:guid}/activation-link")]
        [Authorize(Policy = "RequireChemistUpdatePermission")]
        public async Task<IActionResult> CreateActivationLink(Guid storeId, CancellationToken ct)
        {
            _logger.LogInformation("Chemist activation link requested for store {StoreId}", storeId);

            var result = await _chemistActivationService.CreateActivationLinkAsync(storeId, ct);
            if (!result.Success)
                return BadRequest(new { errors = result.Errors });

            return Ok(result.Data);
        }

        /// <summary>Returns the current activation-fee status for a medical store.</summary>
        [HttpGet("{storeId:guid}/activation")]
        [Authorize(Policy = "RequireChemistReadPermission")]
        public async Task<IActionResult> GetActivationStatus(Guid storeId, CancellationToken ct)
        {
            var result = await _chemistActivationService.GetActivationStatusAsync(storeId, ct);
            if (!result.Success)
                return NotFound(new { errors = result.Errors });

            return Ok(result.Data);
        }
    }
}
