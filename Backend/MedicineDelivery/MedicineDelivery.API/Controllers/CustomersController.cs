using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;
using MedicineDelivery.Domain.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace MedicineDelivery.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class CustomersController : ControllerBase
    {
        private readonly ICustomerService _customerService;
        private readonly IPermissionCheckerService _permissionCheckerService;

        public CustomersController(ICustomerService customerService, IPermissionCheckerService permissionCheckerService)
        {
            _customerService = customerService;
            _permissionCheckerService = permissionCheckerService;
        }

        [HttpGet]
        [Authorize(Policy = "RequireAllCustomerReadPermission")]
        public async Task<IActionResult> GetCustomers()
        {
            try
            {
                var customers = await _customerService.GetAllCustomersAsync();
                return Ok(customers);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "An error occurred while retrieving customers." });
            }
        }

        [HttpGet("{id}")]
        [Authorize(Policy = "RequireCustomerReadPermission")]
        public async Task<IActionResult> GetCustomer(Guid id)
        {
            try
            {
                var customer = await _customerService.GetCustomerByIdAsync(id);
                if (customer == null)
                {
                    return NotFound(new { error = "Customer not found." });
                }

                // Check if user has AllCustomerRead permission or CustomerRead permission
                var hasAllCustomerRead = await _permissionCheckerService.HasPermissionAsync(User, "AllCustomerRead");
                var hasCustomerRead = await _permissionCheckerService.HasPermissionAsync(User, "CustomerRead");

                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                var result = await _permissionCheckerService.GetPermissionsByUserIdAsync(userId);


                if (!hasAllCustomerRead && hasCustomerRead)
                {
                    // User only has CustomerRead permission, can only access their own record
                    var currentUserId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                    if (customer.UserId != currentUserId)
                    {
                        return Forbid("You can only access your own customer information.");
                    }
                }

                return Ok(customer);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "An error occurred while retrieving the customer." });
            }
        }

        [HttpGet("by-mobile/{mobileNumber}")]
        [Authorize(Policy = "RequireCustomerReadPermission")]
        public async Task<IActionResult> GetCustomerByMobile(string mobileNumber)
        {
            try
            {
                var customer = await _customerService.GetCustomerByMobileNumberAsync(mobileNumber);
                if (customer == null)
                {
                    return NotFound(new { error = "Customer not found." });
                }

                // Check if user has AllCustomerRead permission or CustomerRead permission
                var hasAllCustomerRead = await _permissionCheckerService.HasPermissionAsync(User, "AllCustomerRead");
                var hasCustomerRead = await _permissionCheckerService.HasPermissionAsync(User, "CustomerRead");

                if (!hasAllCustomerRead && hasCustomerRead)
                {
                    // User only has CustomerRead permission, can only access their own record
                    var currentUserId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                    if (customer.UserId != currentUserId)
                    {
                        return Forbid("You can only access your own customer information.");
                    }
                }

                return Ok(customer);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "An error occurred while retrieving the customer." });
            }
        }

        [HttpGet("my-profile")]
        [Authorize(Policy = "RequireCustomerReadPermission")]
        public async Task<IActionResult> GetMyProfile()
        {
            try
            {
                var currentUserId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(currentUserId))
                {
                    return Unauthorized(new { error = "User not authenticated." });
                }

                var customer = await _customerService.GetCustomerByUserIdAsync(currentUserId);
                if (customer == null)
                {
                    return NotFound(new { error = "Customer profile not found." });
                }

                return Ok(customer);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "An error occurred while retrieving your profile." });
            }
        }

        [HttpPost("register")]
        [AllowAnonymous]
        public async Task<IActionResult> RegisterCustomer([FromBody] CustomerRegistrationDto request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var result = await _customerService.RegisterCustomerAsync(request);
                if (result.Success)
                {
                    return CreatedAtAction(nameof(GetCustomer), new { id = result.Customer?.CustomerId }, result);
                }
                else
                {
                    return BadRequest(new { errors = result.Errors });
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "An error occurred while registering the customer." });
            }
        }

        [HttpPost]
        [Authorize(Policy = "RequireCustomerCreatePermission")]
        public async Task<IActionResult> CreateCustomer([FromBody] CreateCustomerDto request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                // For now, we'll use the registration method for creating customers
                // In a real scenario, you might want a separate method for admin-created customers
                var registrationDto = new CustomerRegistrationDto
                {
                    CustomerFirstName = request.CustomerFirstName,
                    CustomerLastName = request.CustomerLastName,
                    CustomerMiddleName = request.CustomerMiddleName,
                    MobileNumber = request.MobileNumber,
                    AlternativeMobileNumber = request.AlternativeMobileNumber,
                    EmailId = request.EmailId,
                    DateOfBirth = request.DateOfBirth,
                    Gender = request.Gender,
                    Password = "TempPassword123!", // You might want to generate this or make it required
                    Addresses = request.Addresses
                };

                var result = await _customerService.RegisterCustomerAsync(registrationDto);
                if (result.Success)
                {
                    return CreatedAtAction(nameof(GetCustomer), new { id = result.Customer?.CustomerId }, result.Customer);
                }
                else
                {
                    return BadRequest(new { errors = result.Errors });
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "An error occurred while creating the customer." });
            }
        }

        [HttpPut("{id}")]
        [Authorize(Policy = "RequireCustomerUpdatePermission")]
        public async Task<IActionResult> UpdateCustomer(Guid id, [FromBody] UpdateCustomerDto request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                // Check if customer exists
                var existingCustomer = await _customerService.GetCustomerByIdAsync(id);
                if (existingCustomer == null)
                {
                    return NotFound(new { error = "Customer not found." });
                }

                // Check if user has AllCustomerUpdate permission or CustomerUpdate permission
                var hasAllCustomerUpdate = await _permissionCheckerService.HasPermissionAsync(User, "AllCustomerUpdate");
                var hasCustomerUpdate = await _permissionCheckerService.HasPermissionAsync(User, "CustomerUpdate");

                if (!hasAllCustomerUpdate && hasCustomerUpdate)
                {
                    // User only has CustomerUpdate permission, can only update their own record
                    var currentUserId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                    if (existingCustomer.UserId != currentUserId)
                    {
                        return Forbid("You can only update your own customer information.");
                    }
                }

                var updatedCustomer = await _customerService.UpdateCustomerAsync(id, request);
                if (updatedCustomer == null)
                {
                    return NotFound(new { error = "Customer not found." });
                }

                return Ok(updatedCustomer);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "An error occurred while updating the customer." });
            }
        }

        [HttpDelete("{id}")]
        [Authorize(Policy = "RequireCustomerDeletePermission")]
        public async Task<IActionResult> DeleteCustomer(Guid id)
        {
            try
            {
                // Check if customer exists
                var existingCustomer = await _customerService.GetCustomerByIdAsync(id);
                if (existingCustomer == null)
                {
                    return NotFound(new { error = "Customer not found." });
                }

                // Check if user has AllCustomerDelete permission or CustomerDelete permission
                var hasAllCustomerDelete = await _permissionCheckerService.HasPermissionAsync(User, "AllCustomerDelete");
                var hasCustomerDelete = await _permissionCheckerService.HasPermissionAsync(User, "CustomerDelete");

                if (!hasAllCustomerDelete && hasCustomerDelete)
                {
                    // User only has CustomerDelete permission, can only delete their own record
                    var currentUserId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                    if (existingCustomer.UserId != currentUserId)
                    {
                        return Forbid("You can only delete your own customer information.");
                    }
                }

                var result = await _customerService.DeleteCustomerAsync(id);
                if (result)
                {
                    return NoContent();
                }
                else
                {
                    return NotFound(new { error = "Customer not found." });
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "An error occurred while deleting the customer." });
            }
        }
    }
}
