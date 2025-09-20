using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;
using System.Security.Claims;

namespace MedicineDelivery.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class CustomersController : ControllerBase
    {
        private readonly ICustomerService _customerService;

        public CustomersController(ICustomerService customerService)
        {
            _customerService = customerService;
        }

        [HttpGet]
        [Authorize(Policy = "RequireCustomerReadPermission")]
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

                // Check if user is trying to access their own data or has admin/manager/customer support role
                var currentUserId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                var userRoles = User.FindAll(ClaimTypes.Role).Select(c => c.Value).ToList();

                if (customer.UserId != currentUserId && 
                    !userRoles.Contains("Admin") && 
                    !userRoles.Contains("Manager") && 
                    !userRoles.Contains("CustomerSupport"))
                {
                    return Forbid("You can only access your own customer information.");
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

                // Check if user is trying to access their own data or has admin/manager/customer support role
                var currentUserId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                var userRoles = User.FindAll(ClaimTypes.Role).Select(c => c.Value).ToList();

                if (customer.UserId != currentUserId && 
                    !userRoles.Contains("Admin") && 
                    !userRoles.Contains("Manager") && 
                    !userRoles.Contains("CustomerSupport"))
                {
                    return Forbid("You can only access your own customer information.");
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
                    return CreatedAtAction(nameof(GetCustomer), new { id = result.Customer?.CustomerId }, result.Customer);
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
                    Address = request.Address,
                    City = request.City,
                    State = request.State,
                    PostalCode = request.PostalCode,
                    DateOfBirth = request.DateOfBirth,
                    Gender = request.Gender,
                    Password = "TempPassword123!" // You might want to generate this or make it required
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

                // Check if user is trying to update their own data or has admin/manager/customer support role
                var currentUserId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                var userRoles = User.FindAll(ClaimTypes.Role).Select(c => c.Value).ToList();

                if (existingCustomer.UserId != currentUserId && 
                    !userRoles.Contains("Admin") && 
                    !userRoles.Contains("Manager") && 
                    !userRoles.Contains("CustomerSupport"))
                {
                    return Forbid("You can only update your own customer information.");
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

                // Check if user is trying to delete their own data or has admin/manager/customer support role
                var currentUserId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                var userRoles = User.FindAll(ClaimTypes.Role).Select(c => c.Value).ToList();

                if (existingCustomer.UserId != currentUserId && 
                    !userRoles.Contains("Admin") && 
                    !userRoles.Contains("Manager") && 
                    !userRoles.Contains("CustomerSupport"))
                {
                    return Forbid("You can only delete your own customer information.");
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
