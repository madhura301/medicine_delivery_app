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
        private readonly IOrderAccessGuard _accessGuard;
        private readonly ILogger<CustomerAddressesController> _logger;

        public CustomerAddressesController(
            ICustomerAddressService customerAddressService,
            IPermissionCheckerService permissionCheckerService,
            IOrderAccessGuard accessGuard,
            ILogger<CustomerAddressesController> logger)
        {
            _customerAddressService = customerAddressService;
            _permissionCheckerService = permissionCheckerService;
            _accessGuard = accessGuard;
            _logger = logger;
        }

        /// <summary>Current caller's Identity user id.</summary>
        private string CurrentUserId => User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? string.Empty;

        /// <summary>
        /// H-01: object-level ownership check. Holding <c>CustomerRead</c> only proves the caller may
        /// read *their own* customer data — it says nothing about whose record is being requested.
        /// Every endpoint that accepts a customer or address id must call this before touching data.
        /// </summary>
        private async Task<bool> CanAccessCustomerAsync(Guid customerId, CancellationToken ct = default)
        {
            var hasFullAccess = await _permissionCheckerService.HasPermissionAsync(User, "AllCustomerRead");
            return await _accessGuard.CanAccessCustomerRecordAsync(CurrentUserId, hasFullAccess, customerId, ct);
        }

        /// <summary>
        /// Resolves the owning customer of an address and verifies the caller may act on it.
        /// Returns null when the address does not exist so the action can answer 404.
        /// </summary>
        private async Task<(bool Found, bool Allowed, CustomerAddressDto? Address)> ResolveAddressAccessAsync(Guid addressId, CancellationToken ct = default)
        {
            var address = await _customerAddressService.GetCustomerAddressByIdAsync(addressId);
            if (address == null) return (false, false, null);

            var allowed = await CanAccessCustomerAsync(address.CustomerId, ct);
            return (true, allowed, address);
        }

        [HttpGet("{id}")]
        [Authorize(Policy = "RequireCustomerReadPermission")]
        public async Task<IActionResult> GetCustomerAddress(Guid id)
        {
            try
            {
                var (found, allowed, customerAddress) = await ResolveAddressAccessAsync(id);
                if (!found)
                {
                    return NotFound(new { error = "Customer address not found." });
                }

                if (!allowed)
                {
                    return Forbid();
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
                if (!await CanAccessCustomerAsync(customerId))
                {
                    return Forbid();
                }

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
                if (!await CanAccessCustomerAsync(customerId))
                {
                    return Forbid();
                }

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
                // H-01: prevent creating an address on someone else's account.
                if (!await CanAccessCustomerAsync(request.CustomerId))
                {
                    return Forbid();
                }

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
                // H-01: verify ownership before mutating.
                var (found, allowed, _) = await ResolveAddressAccessAsync(id);
                if (!found)
                {
                    return NotFound(new { error = "Customer address not found." });
                }

                if (!allowed)
                {
                    return Forbid();
                }

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
                // H-01: verify ownership before deleting.
                var (found, allowed, _) = await ResolveAddressAccessAsync(id);
                if (!found)
                {
                    return NotFound(new { error = "Customer address not found." });
                }

                if (!allowed)
                {
                    return Forbid();
                }

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
                if (!await CanAccessCustomerAsync(customerId))
                {
                    return Forbid();
                }

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
