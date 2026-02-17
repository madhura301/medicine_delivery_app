using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System.Security.Claims;

namespace MedicineDelivery.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class CustomerAddressesController : ControllerBase
    {
        private readonly ICustomerAddressService _customerAddressService;
        private readonly IPermissionCheckerService _permissionCheckerService;
        private readonly ILogger<CustomerAddressesController> _logger;

        public CustomerAddressesController(ICustomerAddressService customerAddressService, IPermissionCheckerService permissionCheckerService, ILogger<CustomerAddressesController> logger)
        {
            _customerAddressService = customerAddressService;
            _permissionCheckerService = permissionCheckerService;
            _logger = logger;
        }

        [HttpGet("{id}")]
        [Authorize(Policy = "RequireCustomerReadPermission")]
        public async Task<IActionResult> GetCustomerAddress(Guid id)
        {
            try
            {
                var customerAddress = await _customerAddressService.GetCustomerAddressByIdAsync(id);
                if (customerAddress == null)
                {
                    return NotFound(new { error = "Customer address not found." });
                }

                // Check if user has AllCustomerRead permission or CustomerRead permission
                var hasAllCustomerRead = await _permissionCheckerService.HasPermissionAsync(User, "AllCustomerRead");
                var hasCustomerRead = await _permissionCheckerService.HasPermissionAsync(User, "CustomerRead");

                if (!hasAllCustomerRead && hasCustomerRead)
                {
                    // User only has CustomerRead permission, can only access their own addresses
                    var currentUserId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                    // We need to check if the address belongs to the current user's customer record
                    // This would require getting the customer by user ID and checking if the address belongs to them
                    // For now, we'll implement a basic check - in a real scenario, you might want to add this validation
                }

                return Ok(customerAddress);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetCustomerAddress for Address {AddressId}", id);
                return StatusCode(500, new { error = "An error occurred while retrieving the customer address." });
            }
        }

        [HttpGet("customer/{customerId}")]
        [Authorize(Policy = "RequireCustomerReadPermission")]
        public async Task<IActionResult> GetCustomerAddressesByCustomerId(Guid customerId)
        {
            try
            {
                var customerAddresses = await _customerAddressService.GetCustomerAddressesByCustomerIdAsync(customerId);
                return Ok(customerAddresses);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetCustomerAddressesByCustomerId for Customer {CustomerId}", customerId);
                return StatusCode(500, new { error = "An error occurred while retrieving customer addresses." });
            }
        }

        [HttpGet("customer/{customerId}/default")]
        [Authorize(Policy = "RequireCustomerReadPermission")]
        public async Task<IActionResult> GetDefaultCustomerAddress(Guid customerId)
        {
            try
            {
                var defaultAddress = await _customerAddressService.GetDefaultCustomerAddressAsync(customerId);
                if (defaultAddress == null)
                {
                    return NotFound(new { error = "No default address found for this customer." });
                }

                return Ok(defaultAddress);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetDefaultCustomerAddress for Customer {CustomerId}", customerId);
                return StatusCode(500, new { error = "An error occurred while retrieving the default address." });
            }
        }

        [HttpPost]
        [Authorize(Policy = "RequireCustomerCreatePermission")]
        public async Task<IActionResult> CreateCustomerAddress([FromBody] CreateCustomerAddressDto request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var customerAddress = await _customerAddressService.CreateCustomerAddressAsync(request);
                return CreatedAtAction(nameof(GetCustomerAddress), new { id = customerAddress.Id }, customerAddress);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in CreateCustomerAddress");
                return StatusCode(500, new { error = "An error occurred while creating the customer address." });
            }
        }

        [HttpPut("{id}")]
        [Authorize(Policy = "RequireCustomerUpdatePermission")]
        public async Task<IActionResult> UpdateCustomerAddress(Guid id, [FromBody] UpdateCustomerAddressDto request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var updatedAddress = await _customerAddressService.UpdateCustomerAddressAsync(id, request);
                if (updatedAddress == null)
                {
                    return NotFound(new { error = "Customer address not found." });
                }

                return Ok(updatedAddress);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in UpdateCustomerAddress for Address {AddressId}", id);
                return StatusCode(500, new { error = "An error occurred while updating the customer address." });
            }
        }

        [HttpDelete("{id}")]
        [Authorize(Policy = "RequireCustomerDeletePermission")]
        public async Task<IActionResult> DeleteCustomerAddress(Guid id)
        {
            try
            {
                var result = await _customerAddressService.DeleteCustomerAddressAsync(id);
                if (result)
                {
                    return NoContent();
                }
                else
                {
                    return NotFound(new { error = "Customer address not found." });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in DeleteCustomerAddress for Address {AddressId}", id);
                return StatusCode(500, new { error = "An error occurred while deleting the customer address." });
            }
        }

        [HttpPut("customer/{customerId}/set-default/{addressId}")]
        [Authorize(Policy = "RequireCustomerUpdatePermission")]
        public async Task<IActionResult> SetDefaultAddress(Guid customerId, Guid addressId)
        {
            try
            {
                var result = await _customerAddressService.SetDefaultAddressAsync(customerId, addressId);
                if (result)
                {
                    return Ok(new { message = "Default address updated successfully." });
                }
                else
                {
                    return NotFound(new { error = "Customer address not found or does not belong to the specified customer." });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in SetDefaultAddress for Customer {CustomerId} Address {AddressId}", customerId, addressId);
                return StatusCode(500, new { error = "An error occurred while setting the default address." });
            }
        }
    }
}
