using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;
using MedicineDelivery.Domain.Enums;

namespace MedicineDelivery.API.Controllers
{
    [ApiController]
    [Route("api/ServiceRegions")]
    [Authorize]
    public class ServiceRegionsController : ControllerBase
    {
        private readonly IServiceRegionService _serviceRegionService;

        public ServiceRegionsController(IServiceRegionService serviceRegionService)
        {
            _serviceRegionService = serviceRegionService;
        }

        /// <summary>
        /// Create a new service region
        /// </summary>
        /// <param name="createDto">Region creation details</param>
        /// <returns>Created region details</returns>
        [HttpPost]
        [Authorize(Policy = "RequireOrderUpdatePermission")]
        public async Task<ActionResult<ServiceRegionDto>> CreateServiceRegion([FromBody] CreateServiceRegionDto createDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var region = await _serviceRegionService.CreateServiceRegionAsync(createDto);
                return CreatedAtAction(nameof(GetServiceRegionById), new { id = region.Id }, region);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception)
            {
                return StatusCode(500, new { error = "An error occurred while creating the service region." });
            }
        }

        /// <summary>
        /// Get all service regions, optionally filtered by region type
        /// </summary>
        /// <param name="regionType">Optional filter by region type (0 = CustomerSupport, 1 = DeliveryBoy)</param>
        /// <returns>List of regions</returns>
        [HttpGet]
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<ActionResult<IEnumerable<ServiceRegionDto>>> GetAllServiceRegions([FromQuery] RegionType? regionType = null)
        {
            try
            {
                IEnumerable<ServiceRegionDto> regions;

                if (regionType.HasValue)
                {
                    regions = await _serviceRegionService.GetAllServiceRegionsByTypeAsync(regionType.Value);
                }
                else
                {
                    regions = await _serviceRegionService.GetAllServiceRegionsAsync();
                }

                return Ok(regions);
            }
            catch (Exception)
            {
                return StatusCode(500, new { error = "An error occurred while retrieving service regions." });
            }
        }

        /// <summary>
        /// Get service region by ID
        /// </summary>
        /// <param name="id">Region ID</param>
        /// <returns>Region details</returns>
        [HttpGet("{id:int}")]
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<ActionResult<ServiceRegionDto>> GetServiceRegionById(int id)
        {
            try
            {
                var region = await _serviceRegionService.GetServiceRegionByIdAsync(id);
                
                if (region == null)
                {
                    return NotFound(new { error = "Service region not found." });
                }

                return Ok(region);
            }
            catch (Exception)
            {
                return StatusCode(500, new { error = "An error occurred while retrieving the service region." });
            }
        }

        /// <summary>
        /// Update service region information
        /// </summary>
        /// <param name="id">Region ID</param>
        /// <param name="updateDto">Region update details</param>
        /// <returns>Updated region details</returns>
        [HttpPut("{id:int}")]
        [Authorize(Policy = "RequireOrderUpdatePermission")]
        public async Task<ActionResult<ServiceRegionDto>> UpdateServiceRegion(int id, [FromBody] UpdateServiceRegionDto updateDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var region = await _serviceRegionService.UpdateServiceRegionAsync(id, updateDto);
                return Ok(region);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { error = ex.Message });
            }
            catch (Exception)
            {
                return StatusCode(500, new { error = "An error occurred while updating the service region." });
            }
        }

        /// <summary>
        /// Delete service region
        /// </summary>
        /// <param name="id">Region ID</param>
        /// <returns>Success status</returns>
        [HttpDelete("{id:int}")]
        [Authorize(Policy = "RequireOrderUpdatePermission")]
        public async Task<ActionResult> DeleteServiceRegion(int id)
        {
            try
            {
                var result = await _serviceRegionService.DeleteServiceRegionAsync(id);
                
                if (!result)
                {
                    return NotFound(new { error = "Service region not found." });
                }

                return NoContent();
            }
            catch (Exception)
            {
                return StatusCode(500, new { error = "An error occurred while deleting the service region." });
            }
        }

        /// <summary>
        /// Assign a service region to a single customer support
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
                await _serviceRegionService.AssignRegionToCustomerSupportAsync(assignDto);
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
        /// Assign a service region to multiple customer supports
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
                await _serviceRegionService.AssignRegionToCustomerSupportsAsync(assignDto);
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
        /// Assign a service region to a single delivery
        /// </summary>
        [HttpPost("assign-delivery")]
        [Authorize(Policy = "RequireOrderUpdatePermission")]
        public async Task<ActionResult> AssignRegionToDelivery([FromBody] AssignDeliveryRegionDto assignDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                await _serviceRegionService.AssignRegionToDeliveryAsync(assignDto);
                return Ok(new { success = true, message = "Region assigned to delivery successfully." });
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
                return StatusCode(500, new { error = "An error occurred while assigning the region to delivery." });
            }
        }

        /// <summary>
        /// Assign a service region to multiple deliveries
        /// </summary>
        [HttpPost("assign-delivery/bulk")]
        [Authorize(Policy = "RequireOrderUpdatePermission")]
        public async Task<ActionResult> AssignRegionToDeliveries([FromBody] AssignDeliveryRegionBulkDto assignDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                await _serviceRegionService.AssignRegionToDeliveriesAsync(assignDto);
                return Ok(new { success = true, message = "Region assigned to deliveries successfully." });
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
                return StatusCode(500, new { error = "An error occurred while assigning the region to deliveries." });
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
                var result = await _serviceRegionService.AddPinCodeToRegionAsync(addDto);
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
                var result = await _serviceRegionService.RemovePinCodeFromRegionAsync(removeDto);
                
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
                var pinCodes = await _serviceRegionService.GetPinCodesByRegionIdAsync(regionId);
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
        public async Task<ActionResult<ServiceRegionDto>> GetRegionByPinCode(string pinCode)
        {
            try
            {
                var region = await _serviceRegionService.GetRegionByPinCodeAsync(pinCode);
                
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
