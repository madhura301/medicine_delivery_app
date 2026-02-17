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
    public class CustomerSupportsController : ControllerBase
    {
        private readonly ICustomerSupportService _customerSupportService;
        private readonly IPhotoUploadService _photoUploadService;
        private readonly ILogger<CustomerSupportsController> _logger;

        public CustomerSupportsController(ICustomerSupportService customerSupportService, IPhotoUploadService photoUploadService, ILogger<CustomerSupportsController> logger)
        {
            _customerSupportService = customerSupportService;
            _photoUploadService = photoUploadService;
            _logger = logger;
        }

        /// <summary>
        /// Register a new customer support and create associated user account
        /// </summary>
        /// <param name="registrationDto">Customer support registration details</param>
        /// <returns>Customer support details with generated password</returns>
        [HttpPost("register")]
        [Authorize(Policy = "RequireCustomerSupportCreatePermission")]
        public async Task<ActionResult<CustomerSupportResponseDto>> RegisterCustomerSupport([FromBody] CustomerSupportRegistrationDto registrationDto)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                var result = await _customerSupportService.RegisterCustomerSupportAsync(registrationDto);
            
                if (!result.Success)
                {
                    return BadRequest(new { errors = result.Errors });
                }

                return Ok(result.CustomerSupport);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in RegisterCustomerSupport");
                return StatusCode(500, new { error = "An error occurred while registering the customer support." });
            }
        }

        /// <summary>
        /// Get all customer supports
        /// </summary>
        /// <returns>List of customer supports</returns>
        [HttpGet]
        [Authorize(Policy = "RequireCustomerSupportReadPermission")]
        public async Task<ActionResult<List<CustomerSupportDto>>> GetAllCustomerSupports()
        {
            try
            {
                var customerSupports = await _customerSupportService.GetAllCustomerSupportsAsync();
                return Ok(customerSupports);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetAllCustomerSupports");
                return StatusCode(500, new { error = "An error occurred while retrieving customer supports." });
            }
        }

        /// <summary>
        /// Get customer support by ID
        /// </summary>
        /// <param name="id">Customer support ID</param>
        /// <returns>Customer support details</returns>
        [HttpGet("{id}")]
        [Authorize(Policy = "RequireCustomerSupportReadPermission")]
        public async Task<ActionResult<CustomerSupportDto>> GetCustomerSupportById(Guid id)
        {
            try
            {
                var customerSupport = await _customerSupportService.GetCustomerSupportByIdAsync(id);
            
                if (customerSupport == null)
                {
                    return NotFound();
                }

                return Ok(customerSupport);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetCustomerSupportById for {Id}", id);
                return StatusCode(500, new { error = "An error occurred while retrieving the customer support." });
            }
        }

        /// <summary>
        /// Get customer support by email
        /// </summary>
        /// <param name="email">Customer support email</param>
        /// <returns>Customer support details</returns>
        [HttpGet("by-email/{email}")]
        [Authorize(Policy = "RequireCustomerSupportReadPermission")]
        public async Task<ActionResult<CustomerSupportDto>> GetCustomerSupportByEmail(string email)
        {
            try
            {
                var customerSupport = await _customerSupportService.GetCustomerSupportByEmailAsync(email);
            
                if (customerSupport == null)
                {
                    return NotFound();
                }

                return Ok(customerSupport);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetCustomerSupportByEmail for {Email}", email);
                return StatusCode(500, new { error = "An error occurred while retrieving the customer support." });
            }
        }

        /// <summary>
        /// Update customer support information
        /// </summary>
        /// <param name="id">Customer support ID</param>
        /// <param name="updateDto">Updated customer support details</param>
        /// <returns>Updated customer support details</returns>
        [HttpPut("{id}")]
        [Authorize(Policy = "RequireCustomerSupportUpdatePermission")]
        public async Task<ActionResult<CustomerSupportDto>> UpdateCustomerSupport(Guid id, [FromBody] CustomerSupportRegistrationDto updateDto)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                var customerSupport = await _customerSupportService.UpdateCustomerSupportAsync(id, updateDto);
            
                if (customerSupport == null)
                {
                    return NotFound();
                }

                return Ok(customerSupport);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in UpdateCustomerSupport for {Id}", id);
                return StatusCode(500, new { error = "An error occurred while updating the customer support." });
            }
        }

        /// <summary>
        /// Delete customer support (soft delete)
        /// </summary>
        /// <param name="id">Customer support ID</param>
        /// <returns>Success status</returns>
        [HttpDelete("{id}")]
        [Authorize(Policy = "RequireCustomerSupportDeletePermission")]
        public async Task<ActionResult> DeleteCustomerSupport(Guid id)
        {
            try
            {
                var result = await _customerSupportService.DeleteCustomerSupportAsync(id);
            
                if (!result)
                {
                    return NotFound();
                }

                return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in DeleteCustomerSupport for {Id}", id);
                return StatusCode(500, new { error = "An error occurred while deleting the customer support." });
            }
        }

        /// <summary>
        /// Upload photo for customer support
        /// </summary>
        /// <param name="id">Customer support ID</param>
        /// <param name="photo">Photo file</param>
        /// <returns>Photo URL</returns>
        [HttpPost("{id}/photo")]
        [Authorize(Policy = "RequireCustomerSupportUpdatePermission")]
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
                var fileName = await _photoUploadService.UploadPhotoAsync(photo, "CustomerSupport", id);
                var photoUrl = _photoUploadService.GetPhotoUrl(fileName, "CustomerSupport");
                
                // Update the customer support record with the photo filename
                var customerSupport = await _customerSupportService.GetCustomerSupportByIdAsync(id);
                if (customerSupport == null)
                {
                    return NotFound("Customer support not found");
                }

                // You would need to add an update method to set the photo filename
                // For now, we'll just return the photo URL
                
                return Ok(new { PhotoUrl = photoUrl, FileName = fileName });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in UploadPhoto for customer support {Id}", id);
                return StatusCode(500, $"Error uploading photo: {ex.Message}");
            }
        }
    }
}
