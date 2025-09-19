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
    public class ManagersController : ControllerBase
    {
        private readonly IManagerService _managerService;
        private readonly IPhotoUploadService _photoUploadService;

        public ManagersController(IManagerService managerService, IPhotoUploadService photoUploadService)
        {
            _managerService = managerService;
            _photoUploadService = photoUploadService;
        }

        /// <summary>
        /// Register a new manager and create associated user account
        /// </summary>
        /// <param name="registrationDto">Manager registration details</param>
        /// <returns>Manager details with generated password</returns>
        [HttpPost("register")]
        [Authorize(Policy = "RequireManagerSupportCreatePermission")]
        public async Task<ActionResult<ManagerResponseDto>> RegisterManager([FromBody] ManagerRegistrationDto registrationDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var result = await _managerService.RegisterManagerAsync(registrationDto);
            
            if (!result.Success)
            {
                return BadRequest(new { errors = result.Errors });
            }

            return Ok(result.Manager);
        }

        /// <summary>
        /// Get all managers
        /// </summary>
        /// <returns>List of managers</returns>
        [HttpGet]
        [Authorize(Policy = "RequireManagerSupportReadPermission")]
        public async Task<ActionResult<List<ManagerDto>>> GetAllManagers()
        {
            var managers = await _managerService.GetAllManagersAsync();
            return Ok(managers);
        }

        /// <summary>
        /// Get manager by ID
        /// </summary>
        /// <param name="id">Manager ID</param>
        /// <returns>Manager details</returns>
        [HttpGet("{id}")]
        [Authorize(Policy = "RequireManagerSupportReadPermission")]
        public async Task<ActionResult<ManagerDto>> GetManagerById(Guid id)
        {
            var manager = await _managerService.GetManagerByIdAsync(id);
            
            if (manager == null)
            {
                return NotFound();
            }

            return Ok(manager);
        }

        /// <summary>
        /// Get manager by email
        /// </summary>
        /// <param name="email">Manager email</param>
        /// <returns>Manager details</returns>
        [HttpGet("by-email/{email}")]
        [Authorize(Policy = "RequireManagerSupportReadPermission")]
        public async Task<ActionResult<ManagerDto>> GetManagerByEmail(string email)
        {
            var manager = await _managerService.GetManagerByEmailAsync(email);
            
            if (manager == null)
            {
                return NotFound();
            }

            return Ok(manager);
        }

        /// <summary>
        /// Update manager information
        /// </summary>
        /// <param name="id">Manager ID</param>
        /// <param name="updateDto">Updated manager details</param>
        /// <returns>Updated manager details</returns>
        [HttpPut("{id}")]
        [Authorize(Policy = "RequireManagerSupportUpdatePermission")]
        public async Task<ActionResult<ManagerDto>> UpdateManager(Guid id, [FromBody] ManagerRegistrationDto updateDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var manager = await _managerService.UpdateManagerAsync(id, updateDto);
            
            if (manager == null)
            {
                return NotFound();
            }

            return Ok(manager);
        }

        /// <summary>
        /// Delete manager (soft delete)
        /// </summary>
        /// <param name="id">Manager ID</param>
        /// <returns>Success status</returns>
        [HttpDelete("{id}")]
        [Authorize(Policy = "RequireManagerSupportDeletePermission")]
        public async Task<ActionResult> DeleteManager(Guid id)
        {
            var result = await _managerService.DeleteManagerAsync(id);
            
            if (!result)
            {
                return NotFound();
            }

            return NoContent();
        }

        /// <summary>
        /// Upload photo for manager
        /// </summary>
        /// <param name="id">Manager ID</param>
        /// <param name="photo">Photo file</param>
        /// <returns>Photo URL</returns>
        [HttpPost("{id}/photo")]
        [Authorize(Policy = "RequireManagerSupportUpdatePermission")]
        public async Task<ActionResult<string>> UploadPhoto(Guid id, IFormFile photo)
        {
            if (photo == null || photo.Length == 0)
            {
                return BadRequest("No photo file provided");
            }

            if (!_photoUploadService.IsValidPhotoFile(photo))
            {
                return BadRequest($"Invalid photo file. Allowed extensions: {string.Join(", ", _photoUploadService.GetAllowedExtensions())}. Max size: {_photoUploadService.GetMaxFileSizeInBytes() / (1024 * 1024)}MB");
            }

            try
            {
                var fileName = await _photoUploadService.UploadPhotoAsync(photo, "Manager", id);
                var photoUrl = _photoUploadService.GetPhotoUrl(fileName, "Manager");
                
                // Update the manager record with the photo filename
                var manager = await _managerService.GetManagerByIdAsync(id);
                if (manager == null)
                {
                    return NotFound("Manager not found");
                }

                // You would need to add an update method to set the photo filename
                // For now, we'll just return the photo URL
                
                return Ok(new { PhotoUrl = photoUrl, FileName = fileName });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error uploading photo: {ex.Message}");
            }
        }
    }
}
