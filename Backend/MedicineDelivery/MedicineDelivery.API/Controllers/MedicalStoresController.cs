using MedicineDelivery.API.Authorization;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;
using MedicineDelivery.Domain.Entities;
using MedicineDelivery.Infrastructure.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace MedicineDelivery.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class MedicalStoresController : ControllerBase
    {
        private readonly IMedicalStoreService _medicalStoreService;
        private readonly IPermissionCheckerService _permissionCheckerService;
        private readonly ILogger<MedicalStoresController> _logger;

        public MedicalStoresController(IMedicalStoreService medicalStoreService, IPermissionCheckerService permissionCheckerService, ILogger<MedicalStoresController> logger)
        {
            _medicalStoreService = medicalStoreService;
            _permissionCheckerService = permissionCheckerService;
            _logger = logger;
        }

        /// <summary>
        /// Register a new medical store and create associated user account
        /// </summary>
        /// <param name="registrationDto">Medical store registration details</param>
        /// <returns>Medical store details with generated password</returns>
        [HttpPost("register")]
        //[Authorize(Policy = "RequireChemistCreatePermission")]
        [AllowAnonymous]
        public async Task<ActionResult<MedicalStoreResponseDto>> RegisterMedicalStore([FromBody] MedicalStoreRegistrationDto registrationDto)
        {
            _logger.LogInformation("RegisterMedicalStore requested for Email={Email}", registrationDto.EmailId);
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                var result = await _medicalStoreService.RegisterMedicalStoreAsync(registrationDto);
            
                if (!result.Success)
                {
                    return BadRequest(new { errors = result.Errors });
                }

                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in RegisterMedicalStore");
                return StatusCode(500, new { error = "An error occurred while registering the medical store." });
            }
        }

        /// <summary>
        /// Get all medical stores
        /// </summary>
        /// <returns>List of medical stores</returns>
        [HttpGet]
        [Authorize(Policy = "RequireChemistReadPermission")]
        public async Task<ActionResult<List<MedicalStoreDto>>> GetAllMedicalStores()
        {
            try
            {
                var medicalStores = await _medicalStoreService.GetAllMedicalStoresAsync();
                return Ok(medicalStores);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetAllMedicalStores");
                return StatusCode(500, new { error = "An error occurred while retrieving medical stores." });
            }
        }

        /// <summary>
        /// Get medical store by ID
        /// </summary>
        /// <param name="id">Medical store ID</param>
        /// <returns>Medical store details</returns>
        [HttpGet("{id}")]
        [Authorize(Policy = "RequireChemistReadPermission")]
        public async Task<ActionResult<MedicalStoreDto>> GetMedicalStoreById(Guid id)
        {
            try
            {
                var medicalStore = await _medicalStoreService.GetMedicalStoreByIdAsync(id);
            
                if (medicalStore == null)
                {
                    return NotFound();
                }

                // Check if user has AllCustomerRead permission or CustomerRead permission
                var hasAllChemistRead = await _permissionCheckerService.HasPermissionAsync(User, "AllChemistRead");
                var hasChemistRead = await _permissionCheckerService.HasPermissionAsync(User, "ChemistRead");

                if (!hasAllChemistRead && hasChemistRead)
                {
                    // User only has CustomerRead permission, can only access their own record
                    var currentUserId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                    if (medicalStore.UserId != currentUserId)
                    {
                        return Forbid("You can only access your own chemist information.");
                    }
                }

                return Ok(medicalStore);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetMedicalStoreById for {Id}", id);
                return StatusCode(500, new { error = "An error occurred while retrieving the medical store." });
            }
        }

        /// <summary>
        /// Get medical store by email
        /// </summary>
        /// <param name="email">Medical store email</param>
        /// <returns>Medical store details</returns>
        [HttpGet("by-email/{email}")]
        [Authorize(Policy = "RequireChemistReadPermission")]
        public async Task<ActionResult<MedicalStoreDto>> GetMedicalStoreByEmail(string email)
        {
            try
            {
                var medicalStore = await _medicalStoreService.GetMedicalStoreByEmailAsync(email);
            
                if (medicalStore == null)
                {
                    return NotFound();
                }

                return Ok(medicalStore);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetMedicalStoreByEmail for {Email}", email);
                return StatusCode(500, new { error = "An error occurred while retrieving the medical store." });
            }
        }

        /// <summary>
        /// Update medical store information
        /// </summary>
        /// <param name="id">Medical store ID</param>
        /// <param name="updateDto">Updated medical store details</param>
        /// <returns>Updated medical store details</returns>
        [HttpPut("{id}")]
        [Authorize(Policy = "RequireChemistUpdatePermission")]
        public async Task<ActionResult<MedicalStoreDto>> UpdateMedicalStore(Guid id, [FromBody] MedicalStoreRegistrationDto updateDto)
        {
            _logger.LogInformation("UpdateMedicalStore requested for {Id}", id);

            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                // Check if chemist exists
                var existingChemist = await _medicalStoreService.GetMedicalStoreByIdAsync(id);
                if (existingChemist == null)
                {
                    return NotFound(new { error = "Chemist not found." });
                }

                // Check if user has AllChemistUpdate permission or CustomerUpdate permission
                var hasAllChemistUpdate = await _permissionCheckerService.HasPermissionAsync(User, "AllChemistUpdate");
                var hasChemistUpdate = await _permissionCheckerService.HasPermissionAsync(User, "ChemistUpdate");

                if (!hasAllChemistUpdate && hasChemistUpdate)
                {
                    // User only has CustomerUpdate permission, can only update their own record
                    var currentUserId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                    if (existingChemist.UserId != currentUserId)
                    {
                        return Forbid("You can only update your own chemist information.");
                    }
                }

                var medicalStore = await _medicalStoreService.UpdateMedicalStoreAsync(id, updateDto);
            
                if (medicalStore == null)
                {
                    return NotFound();
                }

                return Ok(medicalStore);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in UpdateMedicalStore for {Id}", id);
                return StatusCode(500, new { error = "An error occurred while updating the chemist." });
            }
        }

        /// <summary>
        /// Check if any chemist is available within 5KM of a customer's default address
        /// </summary>
        /// <param name="customerId">Customer ID</param>
        /// <returns>True if at least one chemist is within 5KM, false otherwise</returns>
        [HttpGet("check-availability/{customerId:guid}")]
        public async Task<IActionResult> CheckChemistAvailability(Guid customerId, CancellationToken cancellationToken)
        {
            try
            {
                var isAvailable = await _medicalStoreService.CheckChemistAvailabilityAsync(customerId, cancellationToken);
                return Ok(new { customerId, isChemistAvailable = isAvailable });
            }
            catch (KeyNotFoundException ex)
            {
                _logger.LogWarning("CheckChemistAvailability: {Message}", ex.Message);
                return NotFound(new { error = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogWarning("CheckChemistAvailability: {Message}", ex.Message);
                return BadRequest(new { error = ex.Message });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in CheckChemistAvailability for Customer {CustomerId}", customerId);
                return StatusCode(500, new { error = "An error occurred while checking chemist availability." });
            }
        }

        /// <summary>
        /// Activate a medical store (chemist). Allowed for Admin / Manager / CustomerSupport.
        /// New chemists are inactive until activated here.
        /// </summary>
        [HttpPost("{id:guid}/activate")]
        [Authorize(Policy = "RequireChemistUpdatePermission")]
        public async Task<IActionResult> ActivateMedicalStore(Guid id)
        {
            try
            {
                // Only Admin / Manager / CustomerSupport (AllChemistUpdate) may activate a chemist —
                // a chemist must not activate their own (or anyone's) store.
                if (!await _permissionCheckerService.HasPermissionAsync(User, "AllChemistUpdate"))
                    return Forbid();

                var ok = await _medicalStoreService.SetActiveStatusAsync(id, true);
                if (!ok)
                    return NotFound(new { error = "Chemist not found or has been deleted." });

                _logger.LogInformation("Medical store {Id} activated", id);
                return Ok(new { id, isActive = true, message = "Chemist activated successfully." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error activating medical store {Id}", id);
                return StatusCode(500, new { error = "An error occurred while activating the chemist." });
            }
        }

        /// <summary>
        /// Deactivate a medical store (chemist). Allowed for Admin / Manager / CustomerSupport.
        /// </summary>
        [HttpPost("{id:guid}/deactivate")]
        [Authorize(Policy = "RequireChemistUpdatePermission")]
        public async Task<IActionResult> DeactivateMedicalStore(Guid id)
        {
            try
            {
                // Only Admin / Manager / CustomerSupport (AllChemistUpdate) may deactivate a chemist.
                if (!await _permissionCheckerService.HasPermissionAsync(User, "AllChemistUpdate"))
                    return Forbid();

                var ok = await _medicalStoreService.SetActiveStatusAsync(id, false);
                if (!ok)
                    return NotFound(new { error = "Chemist not found or has been deleted." });

                _logger.LogInformation("Medical store {Id} deactivated", id);
                return Ok(new { id, isActive = false, message = "Chemist deactivated successfully." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deactivating medical store {Id}", id);
                return StatusCode(500, new { error = "An error occurred while deactivating the chemist." });
            }
        }

        /// <summary>
        /// Delete medical store (soft delete)
        /// </summary>
        /// <param name="id">Medical store ID</param>
        /// <returns>Success status</returns>
        [HttpDelete("{id}")]
        [Authorize(Policy = "RequireChemistDeletePermission")]
        public async Task<ActionResult> DeleteMedicalStore(Guid id)
        {
            _logger.LogInformation("DeleteMedicalStore requested for {Id}", id);
            try
            {
                // Check if chemist exists
                var existingChemist = await _medicalStoreService.GetMedicalStoreByIdAsync(id);
                if (existingChemist == null)
                {
                    return NotFound(new { error = "Chemist not found." });
                }

                // Check if user has AllChemistDelete permission or ChemistDelete permission
                var hasAllChemistDelete = await _permissionCheckerService.HasPermissionAsync(User, "AllChemistDelete");
                var hasChemistDelete = await _permissionCheckerService.HasPermissionAsync(User, "ChemistDelete");

                if (!hasAllChemistDelete && hasChemistDelete)
                {
                    // User only has CustomerUpdate permission, can only update their own record
                    var currentUserId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                    if (existingChemist.UserId != currentUserId)
                    {
                        return Forbid("You can only update your own chemist information.");
                    }
                }

                var result = await _medicalStoreService.DeleteMedicalStoreAsync(id);

                if (!result)
                {
                    return NotFound();
                }

                return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in DeleteMedicalStore for {Id}", id);
                return StatusCode(500, new { error = "An error occurred while deleting the chemist." });
            }
        }

        /// <summary>
        /// Permanently deletes a medical store — its payout/activation records cascade,
        /// and the associated login account is removed. Refuses if the chemist has any
        /// order history. Admin-only (AllChemistDelete); intended for cleaning up
        /// test/junk chemist registrations, not for real chemists with order history.
        /// </summary>
        /// <param name="id">Medical store ID</param>
        [HttpDelete("{id:guid}/hard")]
        [Authorize(Policy = "RequireChemistDeletePermission")]
        public async Task<IActionResult> HardDeleteMedicalStore(Guid id)
        {
            _logger.LogInformation("HardDeleteMedicalStore requested for {Id}", id);
            try
            {
                if (!await _permissionCheckerService.HasPermissionAsync(User, "AllChemistDelete"))
                {
                    return Forbid();
                }

                var result = await _medicalStoreService.HardDeleteMedicalStoreAsync(id);

                if (result.NotFound)
                {
                    return NotFound(new { error = "Chemist not found." });
                }

                if (!result.Success)
                {
                    return Conflict(new { error = result.Error });
                }

                _logger.LogInformation("Medical store {Id} hard-deleted", id);
                return Ok(new { id, message = "Chemist permanently deleted." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in HardDeleteMedicalStore for {Id}", id);
                return StatusCode(500, new { error = "An error occurred while hard-deleting the chemist." });
            }
        }
    }
}
