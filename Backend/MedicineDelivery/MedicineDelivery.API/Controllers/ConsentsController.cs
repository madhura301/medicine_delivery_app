using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace MedicineDelivery.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ConsentsController : ControllerBase
    {
        private readonly IConsentService _consentService;

        public ConsentsController(IConsentService consentService)
        {
            _consentService = consentService;
        }

        /// <summary>
        /// Get all consents
        /// </summary>
        [HttpGet]
        [Authorize(Policy = "RequireReadConsentsPermission")]
        public async Task<IActionResult> GetAllConsents()
        {
            try
            {
                var consents = await _consentService.GetAllConsentsAsync();
                return Ok(consents);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "An error occurred while retrieving consents." });
            }
        }

        /// <summary>
        /// Get active consents only
        /// </summary>
        [HttpGet("active")]
        [Authorize(Policy = "RequireReadConsentsPermission")]
        public async Task<IActionResult> GetActiveConsents()
        {
            try
            {
                var consents = await _consentService.GetActiveConsentsAsync();
                return Ok(consents);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "An error occurred while retrieving active consents." });
            }
        }

        /// <summary>
        /// Get consent by ID
        /// </summary>
        [HttpGet("{id}")]
        [Authorize(Policy = "RequireReadConsentsPermission")]
        public async Task<IActionResult> GetConsentById(Guid id)
        {
            try
            {
                var consent = await _consentService.GetConsentByIdAsync(id);
                if (consent == null)
                {
                    return NotFound(new { error = "Consent not found." });
                }

                return Ok(consent);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "An error occurred while retrieving the consent." });
            }
        }

        /// <summary>
        /// Create a new consent (Admin/Manager only)
        /// </summary>
        [HttpPost]
        [Authorize(Policy = "RequireCreateConsentsPermission")]
        public async Task<IActionResult> CreateConsent([FromBody] CreateConsentDto createDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var consent = await _consentService.CreateConsentAsync(createDto);
                return CreatedAtAction(nameof(GetConsentById), new { id = consent.ConsentId }, consent);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "An error occurred while creating the consent." });
            }
        }

        /// <summary>
        /// Update an existing consent (Admin/Manager only)
        /// </summary>
        [HttpPut("{id}")]
        [Authorize(Policy = "RequireUpdateConsentsPermission")]
        public async Task<IActionResult> UpdateConsent(Guid id, [FromBody] UpdateConsentDto updateDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var consent = await _consentService.UpdateConsentAsync(id, updateDto);
                if (consent == null)
                {
                    return NotFound(new { error = "Consent not found." });
                }

                return Ok(consent);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "An error occurred while updating the consent." });
            }
        }

        /// <summary>
        /// Delete a consent (Admin/Manager only)
        /// </summary>
        [HttpDelete("{id}")]
        [Authorize(Policy = "RequireDeleteConsentsPermission")]
        public async Task<IActionResult> DeleteConsent(Guid id)
        {
            try
            {
                var result = await _consentService.DeleteConsentAsync(id);
                if (!result)
                {
                    return NotFound(new { error = "Consent not found." });
                }

                return NoContent();
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "An error occurred while deleting the consent." });
            }
        }

        /// <summary>
        /// Accept a consent
        /// </summary>
        [HttpPost("{id}/accept")]
        public async Task<IActionResult> AcceptConsent(Guid id, [FromBody] AcceptRejectConsentDto? request = null)
        {
            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized(new { error = "User not authenticated." });
                }

                request ??= new AcceptRejectConsentDto();
                var log = await _consentService.AcceptConsentAsync(id, userId, request, HttpContext);
                return Ok(log);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "An error occurred while accepting the consent." });
            }
        }

        /// <summary>
        /// Reject a consent
        /// </summary>
        [HttpPost("{id}/reject")]
        public async Task<IActionResult> RejectConsent(Guid id, [FromBody] AcceptRejectConsentDto? request = null)
        {
            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized(new { error = "User not authenticated." });
                }

                request ??= new AcceptRejectConsentDto();
                var log = await _consentService.RejectConsentAsync(id, userId, request, HttpContext);
                return Ok(log);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "An error occurred while rejecting the consent." });
            }
        }

        /// <summary>
        /// Get consent logs for a specific consent (Admin/Manager only)
        /// </summary>
        [HttpGet("{id}/logs")]
        [Authorize(Policy = "RequireReadConsentLogsPermission")]
        public async Task<IActionResult> GetConsentLogs(Guid id)
        {
            try
            {
                var logs = await _consentService.GetConsentLogsByConsentIdAsync(id);
                return Ok(logs);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "An error occurred while retrieving consent logs." });
            }
        }

        /// <summary>
        /// Get consent logs for the current user
        /// </summary>
        [HttpGet("my-logs")]
        public async Task<IActionResult> GetMyConsentLogs()
        {
            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized(new { error = "User not authenticated." });
                }

                var logs = await _consentService.GetConsentLogsByUserIdAsync(userId);
                return Ok(logs);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "An error occurred while retrieving your consent logs." });
            }
        }
    }
}