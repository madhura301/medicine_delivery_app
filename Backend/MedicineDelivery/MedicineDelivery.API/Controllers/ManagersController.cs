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

        public ManagersController(IManagerService managerService)
        {
            _managerService = managerService;
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
    }
}
