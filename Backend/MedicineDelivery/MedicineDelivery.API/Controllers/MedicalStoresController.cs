using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;
using MedicineDelivery.API.Authorization;

namespace MedicineDelivery.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class MedicalStoresController : ControllerBase
    {
        private readonly IMedicalStoreService _medicalStoreService;

        public MedicalStoresController(IMedicalStoreService medicalStoreService)
        {
            _medicalStoreService = medicalStoreService;
        }

        /// <summary>
        /// Register a new medical store and create associated user account
        /// </summary>
        /// <param name="registrationDto">Medical store registration details</param>
        /// <returns>Medical store details with generated password</returns>
        [HttpPost("register")]
        [Authorize(Policy = "RequireChemistCreatePermission")]
        public async Task<ActionResult<MedicalStoreResponseDto>> RegisterMedicalStore([FromBody] MedicalStoreRegistrationDto registrationDto)
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

            return Ok(result.MedicalStore);
        }

        /// <summary>
        /// Get all medical stores
        /// </summary>
        /// <returns>List of medical stores</returns>
        [HttpGet]
        [Authorize(Policy = "RequireChemistReadPermission")]
        public async Task<ActionResult<List<MedicalStoreDto>>> GetAllMedicalStores()
        {
            var medicalStores = await _medicalStoreService.GetAllMedicalStoresAsync();
            return Ok(medicalStores);
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
            var medicalStore = await _medicalStoreService.GetMedicalStoreByIdAsync(id);
            
            if (medicalStore == null)
            {
                return NotFound();
            }

            return Ok(medicalStore);
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
            var medicalStore = await _medicalStoreService.GetMedicalStoreByEmailAsync(email);
            
            if (medicalStore == null)
            {
                return NotFound();
            }

            return Ok(medicalStore);
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
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var medicalStore = await _medicalStoreService.UpdateMedicalStoreAsync(id, updateDto);
            
            if (medicalStore == null)
            {
                return NotFound();
            }

            return Ok(medicalStore);
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
            var result = await _medicalStoreService.DeleteMedicalStoreAsync(id);
            
            if (!result)
            {
                return NotFound();
            }

            return NoContent();
        }
    }
}
