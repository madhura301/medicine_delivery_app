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
    public class DeliveriesController : ControllerBase
    {
        private readonly IDeliveryService _deliveryService;
        private readonly ILogger<DeliveriesController> _logger;

        public DeliveriesController(IDeliveryService deliveryService, ILogger<DeliveriesController> logger)
        {
            _deliveryService = deliveryService;
            _logger = logger;
        }

        /// <summary>
        /// Create a new delivery
        /// </summary>
        /// <param name="createDto">Delivery creation details</param>
        /// <returns>Created delivery details</returns>
        [HttpPost]
        [Authorize(Policy = "RequireOrderUpdatePermission")]
        public async Task<ActionResult<DeliveryDto>> CreateDelivery([FromBody] CreateDeliveryDto createDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var addedBy = GetCurrentUserId();
                var delivery = await _deliveryService.CreateDeliveryAsync(createDto, addedBy);
                return CreatedAtAction(nameof(GetDeliveryById), new { id = delivery.Id }, delivery);
            }
            catch (KeyNotFoundException ex)
            {
                _logger.LogWarning("CreateDelivery: {Message}", ex.Message);
                return NotFound(new { error = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogWarning("CreateDelivery: {Message}", ex.Message);
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating delivery for order");
                return StatusCode(500, new { error = "An error occurred while creating the delivery." });
            }
        }

        /// <summary>
        /// Get all deliveries
        /// </summary>
        /// <returns>List of deliveries</returns>
        [HttpGet]
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<ActionResult<IEnumerable<DeliveryDto>>> GetAllDeliveries()
        {
            try
            {
                var deliveries = await _deliveryService.GetAllDeliveriesAsync();
                return Ok(deliveries);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving all deliveries");
                return StatusCode(500, new { error = "An error occurred while retrieving deliveries." });
            }
        }

        /// <summary>
        /// Get delivery by ID
        /// </summary>
        /// <param name="id">Delivery ID</param>
        /// <returns>Delivery details</returns>
        [HttpGet("{id:int}")]
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<ActionResult<DeliveryDto>> GetDeliveryById(int id)
        {
            try
            {
                var delivery = await _deliveryService.GetDeliveryByIdAsync(id);
                
                if (delivery == null)
                {
                    return NotFound(new { error = "Delivery not found." });
                }

                return Ok(delivery);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving delivery {DeliveryId}", id);
                return StatusCode(500, new { error = "An error occurred while retrieving the delivery." });
            }
        }

        /// <summary>
        /// Get deliveries by medical store ID
        /// </summary>
        /// <param name="medicalStoreId">Medical store ID</param>
        /// <returns>List of deliveries for the medical store</returns>
        [HttpGet("medicalstore/{medicalStoreId:guid}")]
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<ActionResult<IEnumerable<DeliveryDto>>> GetDeliveriesByMedicalStoreId(Guid medicalStoreId)
        {
            try
            {
                var deliveries = await _deliveryService.GetDeliveriesByMedicalStoreIdAsync(medicalStoreId);
                return Ok(deliveries);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving deliveries for medical store {MedicalStoreId}", medicalStoreId);
                return StatusCode(500, new { error = "An error occurred while retrieving deliveries." });
            }
        }

        /// <summary>
        /// Get active deliveries by medical store ID
        /// </summary>
        /// <param name="medicalStoreId">Medical store ID</param>
        /// <returns>List of active deliveries for the medical store</returns>
        [HttpGet("medicalstore/{medicalStoreId:guid}/active")]
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<ActionResult<IEnumerable<DeliveryDto>>> GetActiveDeliveriesByMedicalStoreId(Guid medicalStoreId)
        {
            try
            {
                var deliveries = await _deliveryService.GetActiveDeliveriesByMedicalStoreIdAsync(medicalStoreId);
                return Ok(deliveries);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving active deliveries for medical store {MedicalStoreId}", medicalStoreId);
                return StatusCode(500, new { error = "An error occurred while retrieving active deliveries." });
            }
        }

        /// <summary>
        /// Update delivery information
        /// </summary>
        /// <param name="id">Delivery ID</param>
        /// <param name="updateDto">Delivery update details</param>
        /// <returns>Updated delivery details</returns>
        [HttpPut("{id:int}")]
        [Authorize(Policy = "RequireOrderUpdatePermission")]
        public async Task<ActionResult<DeliveryDto>> UpdateDelivery(int id, [FromBody] UpdateDeliveryDto updateDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var modifiedBy = GetCurrentUserId();
                var delivery = await _deliveryService.UpdateDeliveryAsync(id, updateDto, modifiedBy);
                return Ok(delivery);
            }
            catch (KeyNotFoundException ex)
            {
                _logger.LogWarning("UpdateDelivery: {Message}", ex.Message);
                return NotFound(new { error = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogWarning("UpdateDelivery: {Message}", ex.Message);
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating delivery {DeliveryId}", id);
                return StatusCode(500, new { error = "An error occurred while updating the delivery." });
            }
        }

        /// <summary>
        /// Delete delivery (soft delete)
        /// </summary>
        /// <param name="id">Delivery ID</param>
        /// <returns>Success status</returns>
        [HttpDelete("{id:int}")]
        [Authorize(Policy = "RequireOrderUpdatePermission")]
        public async Task<ActionResult> DeleteDelivery(int id)
        {
            try
            {
                var result = await _deliveryService.DeleteDeliveryAsync(id);
                
                if (!result)
                {
                    return NotFound(new { error = "Delivery not found." });
                }

                return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting delivery {DeliveryId}", id);
                return StatusCode(500, new { error = "An error occurred while deleting the delivery." });
            }
        }

        private Guid? GetCurrentUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (Guid.TryParse(userIdClaim, out var userId))
            {
                return userId;
            }
            return null;
        }
    }
}

