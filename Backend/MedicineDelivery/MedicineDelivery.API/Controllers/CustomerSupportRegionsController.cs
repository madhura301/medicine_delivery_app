using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;

namespace MedicineDelivery.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class CustomerSupportRegionsController : ControllerBase
    {
        private readonly ICustomerSupportRegionService _customerSupportRegionService;

        public CustomerSupportRegionsController(ICustomerSupportRegionService customerSupportRegionService)
        {
            _customerSupportRegionService = customerSupportRegionService;
        }

        /// <summary>
        /// Assign a customer support region to a single customer support
        /// </summary>
        [HttpPost("assign")]
        [Authorize(Policy = "RequireOrderUpdatePermission")]
        public async Task<ActionResult> AssignRegionToCustomerSupport([FromBody] AssignCustomerSupportRegionDto assignDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                await _customerSupportRegionService.AssignRegionToCustomerSupportAsync(assignDto);
                return Ok(new { success = true, message = "Region assigned to customer support successfully." });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { error = ex.Message });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception)
            {
                return StatusCode(500, new { error = "An error occurred while assigning the region." });
            }
        }

        /// <summary>
        /// Assign a customer support region to multiple customer supports
        /// </summary>
        [HttpPost("assign/bulk")]
        [Authorize(Policy = "RequireOrderUpdatePermission")]
        public async Task<ActionResult> AssignRegionToCustomerSupports([FromBody] AssignCustomerSupportRegionBulkDto assignDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                await _customerSupportRegionService.AssignRegionToCustomerSupportsAsync(assignDto);
                return Ok(new { success = true, message = "Region assigned to customer supports successfully." });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { error = ex.Message });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception)
            {
                return StatusCode(500, new { error = "An error occurred while assigning the region." });
            }
        }

        /// <summary>
        /// Create a new customer support region
        /// </summary>
        /// <param name="createDto">Region creation details</param>
        /// <returns>Created region details</returns>
        [HttpPost]
        [Authorize(Policy = "RequireOrderUpdatePermission")]
        public async Task<ActionResult<CustomerSupportRegionDto>> CreateCustomerSupportRegion([FromBody] CreateCustomerSupportRegionDto createDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var region = await _customerSupportRegionService.CreateCustomerSupportRegionAsync(createDto);
                return CreatedAtAction(nameof(GetCustomerSupportRegionById), new { id = region.Id }, region);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception)
            {
                return StatusCode(500, new { error = "An error occurred while creating the customer support region." });
            }
        }

        /// <summary>
        /// Get all customer support regions
        /// </summary>
        /// <returns>List of regions</returns>
        [HttpGet]
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<ActionResult<IEnumerable<CustomerSupportRegionDto>>> GetAllCustomerSupportRegions()
        {
            try
            {
                var regions = await _customerSupportRegionService.GetAllCustomerSupportRegionsAsync();
                return Ok(regions);
            }
            catch (Exception)
            {
                return StatusCode(500, new { error = "An error occurred while retrieving customer support regions." });
            }
        }

        /// <summary>
        /// Get customer support region by ID
        /// </summary>
        /// <param name="id">Region ID</param>
        /// <returns>Region details</returns>
        [HttpGet("{id:int}")]
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<ActionResult<CustomerSupportRegionDto>> GetCustomerSupportRegionById(int id)
        {
            try
            {
                var region = await _customerSupportRegionService.GetCustomerSupportRegionByIdAsync(id);
                
                if (region == null)
                {
                    return NotFound(new { error = "Customer support region not found." });
                }

                return Ok(region);
            }
            catch (Exception)
            {
                return StatusCode(500, new { error = "An error occurred while retrieving the customer support region." });
            }
        }

        /// <summary>
        /// Update customer support region information
        /// </summary>
        /// <param name="id">Region ID</param>
        /// <param name="updateDto">Region update details</param>
        /// <returns>Updated region details</returns>
        [HttpPut("{id:int}")]
        [Authorize(Policy = "RequireOrderUpdatePermission")]
        public async Task<ActionResult<CustomerSupportRegionDto>> UpdateCustomerSupportRegion(int id, [FromBody] UpdateCustomerSupportRegionDto updateDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var region = await _customerSupportRegionService.UpdateCustomerSupportRegionAsync(id, updateDto);
                return Ok(region);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { error = ex.Message });
            }
            catch (Exception)
            {
                return StatusCode(500, new { error = "An error occurred while updating the customer support region." });
            }
        }

        /// <summary>
        /// Delete customer support region
        /// </summary>
        /// <param name="id">Region ID</param>
        /// <returns>Success status</returns>
        [HttpDelete("{id:int}")]
        [Authorize(Policy = "RequireOrderUpdatePermission")]
        public async Task<ActionResult> DeleteCustomerSupportRegion(int id)
        {
            try
            {
                var result = await _customerSupportRegionService.DeleteCustomerSupportRegionAsync(id);
                
                if (!result)
                {
                    return NotFound(new { error = "Customer support region not found." });
                }

                return NoContent();
            }
            catch (Exception)
            {
                return StatusCode(500, new { error = "An error occurred while deleting the customer support region." });
            }
        }

        /// <summary>
        /// Add a pin code to a region
        /// </summary>
        /// <param name="addDto">Pin code addition details</param>
        /// <returns>Success status</returns>
        [HttpPost("add-pincode")]
        [Authorize(Policy = "RequireOrderUpdatePermission")]
        public async Task<ActionResult> AddPinCodeToRegion([FromBody] AddPinCodeToRegionDto addDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var result = await _customerSupportRegionService.AddPinCodeToRegionAsync(addDto);
                return Ok(new { success = result, message = "Pin code added successfully." });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { error = ex.Message });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception)
            {
                return StatusCode(500, new { error = "An error occurred while adding the pin code." });
            }
        }

        /// <summary>
        /// Remove a pin code from a region
        /// </summary>
        /// <param name="removeDto">Pin code removal details</param>
        /// <returns>Success status</returns>
        [HttpPost("remove-pincode")]
        [Authorize(Policy = "RequireOrderUpdatePermission")]
        public async Task<ActionResult> RemovePinCodeFromRegion([FromBody] RemovePinCodeFromRegionDto removeDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var result = await _customerSupportRegionService.RemovePinCodeFromRegionAsync(removeDto);
                
                if (!result)
                {
                    return NotFound(new { error = "Pin code not found in the specified region." });
                }

                return Ok(new { success = true, message = "Pin code removed successfully." });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception)
            {
                return StatusCode(500, new { error = "An error occurred while removing the pin code." });
            }
        }

        /// <summary>
        /// Get all pin codes for a region
        /// </summary>
        /// <param name="regionId">Region ID</param>
        /// <returns>List of pin codes</returns>
        [HttpGet("{regionId:int}/pincodes")]
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<ActionResult<IEnumerable<string>>> GetPinCodesByRegionId(int regionId)
        {
            try
            {
                var pinCodes = await _customerSupportRegionService.GetPinCodesByRegionIdAsync(regionId);
                return Ok(pinCodes);
            }
            catch (Exception)
            {
                return StatusCode(500, new { error = "An error occurred while retrieving pin codes." });
            }
        }

        /// <summary>
        /// Get region by pin code
        /// </summary>
        /// <param name="pinCode">Pin code</param>
        /// <returns>Region details</returns>
        [HttpGet("by-pincode/{pinCode}")]
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<ActionResult<CustomerSupportRegionDto>> GetRegionByPinCode(string pinCode)
        {
            try
            {
                var region = await _customerSupportRegionService.GetRegionByPinCodeAsync(pinCode);
                
                if (region == null)
                {
                    return NotFound(new { error = "No region found for the specified pin code." });
                }

                return Ok(region);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception)
            {
                return StatusCode(500, new { error = "An error occurred while retrieving the region." });
            }
        }
    }
}

