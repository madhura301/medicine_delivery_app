using System;
using System.Collections.Generic;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace MedicineDelivery.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class OrdersController : ControllerBase
    {
        private readonly IOrderService _orderService;
        private readonly IHostEnvironment _hostEnvironment;
        private readonly ILogger<OrdersController> _logger;

        public OrdersController(IOrderService orderService, IHostEnvironment hostEnvironment, ILogger<OrdersController> logger)
        {
            _orderService = orderService;
            _hostEnvironment = hostEnvironment;
            _logger = logger;
        }

        [HttpGet("{orderId:int}")]
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<IActionResult> GetOrderById(int orderId, CancellationToken cancellationToken)
        {
            try
            {
                var order = await _orderService.GetOrderByIdAsync(orderId, cancellationToken);
                if (order == null)
                {
                    return NotFound(new { error = "Order not found." });
                }

                return Ok(order);
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetOrderById for Order {OrderId}", orderId);
                return StatusCode(500, new { error = "An error occurred while retrieving the order." });
            }
        }

        [HttpGet("customer/{customerId:guid}")]
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<IActionResult> GetOrdersByCustomerId(Guid customerId, CancellationToken cancellationToken)
        {
            try
            {
                var orders = await _orderService.GetOrdersByCustomerIdAsync(customerId, cancellationToken);
                return Ok(orders);
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning("GetOrdersByCustomerId: {Message}", ex.Message);
                return BadRequest(new { error = ex.Message });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetOrdersByCustomerId for Customer {CustomerId}", customerId);
                return StatusCode(500, new { error = "An error occurred while retrieving the orders." });
            }
        }

        [HttpGet("customer/{customerId:guid}/active")]
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<IActionResult> GetActiveOrdersByCustomerId(Guid customerId, CancellationToken cancellationToken)
        {
            try
            {
                var orders = await _orderService.GetActiveOrdersByCustomerIdAsync(customerId, cancellationToken);
                return Ok(orders);
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning("GetActiveOrdersByCustomerId: {Message}", ex.Message);
                return BadRequest(new { error = ex.Message });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetActiveOrdersByCustomerId for Customer {CustomerId}", customerId);
                return StatusCode(500, new { error = "An error occurred while retrieving the orders." });
            }
        }

        [HttpGet("medicalstore/{medicalStoreId:guid}/active")]
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<IActionResult> GetActiveOrdersByMedicalStoreId(Guid medicalStoreId, CancellationToken cancellationToken)
        {
            try
            {
                var orders = await _orderService.GetActiveOrdersByMedicalStoreIdAsync(medicalStoreId, cancellationToken);
                return Ok(orders);
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning("GetActiveOrdersByMedicalStoreId: {Message}", ex.Message);
                return BadRequest(new { error = ex.Message });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetActiveOrdersByMedicalStoreId for MedicalStore {MedicalStoreId}", medicalStoreId);
                return StatusCode(500, new { error = "An error occurred while retrieving the orders." });
            }
        }

        [HttpGet("medicalstore/{medicalStoreId:guid}/accepted")]
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<IActionResult> GetAcceptedOrdersByMedicalStoreId(Guid medicalStoreId, CancellationToken cancellationToken)
        {
            try
            {
                var orders = await _orderService.GetAcceptedOrdersByMedicalStoreIdAsync(medicalStoreId, cancellationToken);
                return Ok(orders);
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning("GetAcceptedOrdersByMedicalStoreId: {Message}", ex.Message);
                return BadRequest(new { error = ex.Message });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetAcceptedOrdersByMedicalStoreId for MedicalStore {MedicalStoreId}", medicalStoreId);
                return StatusCode(500, new { error = "An error occurred while retrieving the orders." });
            }
        }

        [HttpGet("medicalstore/{medicalStoreId:guid}/rejected")]
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<IActionResult> GetRejectedOrdersByMedicalStoreId(Guid medicalStoreId, CancellationToken cancellationToken)
        {
            try
            {
                var orders = await _orderService.GetRejectedOrdersByMedicalStoreIdAsync(medicalStoreId, cancellationToken);
                return Ok(orders);
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning("GetRejectedOrdersByMedicalStoreId: {Message}", ex.Message);
                return BadRequest(new { error = ex.Message });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetRejectedOrdersByMedicalStoreId for MedicalStore {MedicalStoreId}", medicalStoreId);
                return StatusCode(500, new { error = "An error occurred while retrieving the orders." });
            }
        }

        [HttpGet("medicalstore/{medicalStoreId:guid}")]
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<IActionResult> GetAllOrdersByMedicalStoreId(Guid medicalStoreId, CancellationToken cancellationToken)
        {
            try
            {
                var orders = await _orderService.GetAllOrdersByMedicalStoreIdAsync(medicalStoreId, cancellationToken);
                return Ok(orders);
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning("GetAllOrdersByMedicalStoreId: {Message}", ex.Message);
                return BadRequest(new { error = ex.Message });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetAllOrdersByMedicalStoreId for MedicalStore {MedicalStoreId}", medicalStoreId);
                return StatusCode(500, new { error = "An error occurred while retrieving the orders." });
            }
        }

        [HttpPut("{orderId:int}/accept")]
        [Authorize(Policy = "RequireOrderUpdatePermission")]
        public async Task<IActionResult> AcceptOrderByChemist(int orderId, CancellationToken cancellationToken)
        {
            try
            {
                var order = await _orderService.AcceptOrderByChemistAsync(orderId, cancellationToken);
                return Ok(order);
            }
            catch (KeyNotFoundException ex)
            {
                _logger.LogWarning("AcceptOrderByChemist: {Message}", ex.Message);
                return NotFound(new { error = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogWarning("AcceptOrderByChemist: {Message}", ex.Message);
                return BadRequest(new { error = ex.Message });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in AcceptOrderByChemist for Order {OrderId}", orderId);
                return StatusCode(500, new { error = "An error occurred while accepting the order." });
            }
        }

        [HttpPut("{orderId:int}/reject")]
        [Authorize(Policy = "RequireOrderUpdatePermission")]
        public async Task<IActionResult> RejectOrderByChemist(int orderId, [FromBody] RejectOrderDto rejectDto, CancellationToken cancellationToken)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var order = await _orderService.RejectOrderByChemistAsync(orderId, rejectDto, cancellationToken);
                
                // Assign the rejected order to CustomerSupport
                try
                {
                    await _orderService.AssignRejectOrderToCustomerSupport(orderId, cancellationToken);
                    // Refresh the order to get updated data
                    order = await _orderService.GetOrderByIdAsync(orderId, cancellationToken);
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "RejectOrderByChemist: Failed to assign rejected Order {OrderId} to CustomerSupport", orderId);
                }
                
                return Ok(order);
            }
            catch (KeyNotFoundException ex)
            {
                _logger.LogWarning("RejectOrderByChemist: {Message}", ex.Message);
                return NotFound(new { error = ex.Message });
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning("RejectOrderByChemist: {Message}", ex.Message);
                return BadRequest(new { error = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogWarning("RejectOrderByChemist: {Message}", ex.Message);
                return BadRequest(new { error = ex.Message });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in RejectOrderByChemist for Order {OrderId}", orderId);
                return StatusCode(500, new { error = "An error occurred while rejecting the order." });
            }
        }

        [HttpPut("{orderId:int}/complete")]
        [Authorize(Policy = "RequireOrderUpdatePermission")]
        public async Task<IActionResult> CompleteOrder(int orderId, [FromBody] CompleteOrderDto completeDto, CancellationToken cancellationToken)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var order = await _orderService.CompleteOrderAsync(orderId, completeDto, cancellationToken);
                return Ok(order);
            }
            catch (KeyNotFoundException ex)
            {
                _logger.LogWarning("CompleteOrder: {Message}", ex.Message);
                return NotFound(new { error = ex.Message });
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning("CompleteOrder: {Message}", ex.Message);
                return BadRequest(new { error = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogWarning("CompleteOrder: {Message}", ex.Message);
                return BadRequest(new { error = ex.Message });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in CompleteOrder for Order {OrderId}", orderId);
                return StatusCode(500, new { error = "An error occurred while completing the order." });
            }
        }

        [HttpPut("assign")]
        [Authorize(Policy = "RequireOrderUpdatePermission")]
        public async Task<IActionResult> AssignOrderToMedicalStore([FromBody] AssignOrderDto assignDto, CancellationToken cancellationToken)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var order = await _orderService.AssignOrderToMedicalStoreAsync(assignDto, cancellationToken);
                return Ok(order);
            }
            catch (KeyNotFoundException ex)
            {
                _logger.LogWarning("AssignOrderToMedicalStore: {Message}", ex.Message);
                return NotFound(new { error = ex.Message });
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning("AssignOrderToMedicalStore: {Message}", ex.Message);
                return BadRequest(new { error = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogWarning("AssignOrderToMedicalStore: {Message}", ex.Message);
                return BadRequest(new { error = ex.Message });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in AssignOrderToMedicalStore");
                return StatusCode(500, new { error = "An error occurred while assigning the order." });
            }
        }

        [HttpPost]
        [Consumes("multipart/form-data")]
        [Authorize(Policy = "RequireOrderCreatePermission")]
        public async Task<IActionResult> CreateOrder([FromForm] CreateOrderDto request, CancellationToken cancellationToken)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var order = await _orderService.CreateOrderAsync(request, cancellationToken);
                return CreatedAtAction(nameof(GetOrderById), new { orderId = order.OrderId }, order);
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning("CreateOrder: {Message}", ex.Message);
                return BadRequest(new { error = ex.Message });
            }
            catch (KeyNotFoundException ex)
            {
                _logger.LogWarning("CreateOrder: {Message}", ex.Message);
                return NotFound(new { error = ex.Message });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in CreateOrder");
                return StatusCode(500, new { error = "An error occurred while creating the order." });
            }
        }

        [HttpPost("{orderId:int}/upload-bill")]
        [Consumes("multipart/form-data")]
        [Authorize(Policy = "RequireOrderUpdatePermission")]
        public async Task<IActionResult> UploadOrderBill(int orderId, [FromForm] UploadOrderBillDto uploadDto, CancellationToken cancellationToken)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            // Ensure the orderId in the route matches the DTO
            if (uploadDto.OrderId != orderId)
            {
                return BadRequest(new { error = "OrderId in the route must match the OrderId in the request body." });
            }

            try
            {
                var order = await _orderService.UploadOrderBillAsync(uploadDto, cancellationToken);
                return Ok(order);
            }
            catch (KeyNotFoundException ex)
            {
                _logger.LogWarning("UploadOrderBill: {Message}", ex.Message);
                return NotFound(new { error = ex.Message });
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning("UploadOrderBill: {Message}", ex.Message);
                return BadRequest(new { error = ex.Message });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in UploadOrderBill for Order {OrderId}", orderId);
                return StatusCode(500, new { error = "An error occurred while uploading the order bill." });
            }
        }

        [HttpPost("assign-to-delivery")]
        [Authorize(Policy = "RequireOrderUpdatePermission")]
        public async Task<IActionResult> AssignOrderToDelivery([FromBody] AssignOrderToDeliveryDto assignDto, CancellationToken cancellationToken)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var order = await _orderService.AssignOrderToDeliveryAsync(assignDto, cancellationToken);
                return Ok(order);
            }
            catch (KeyNotFoundException ex)
            {
                _logger.LogWarning("AssignOrderToDelivery: {Message}", ex.Message);
                return NotFound(new { error = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogWarning("AssignOrderToDelivery: {Message}", ex.Message);
                return BadRequest(new { error = ex.Message });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in AssignOrderToDelivery");
                return StatusCode(500, new { error = "An error occurred while assigning the order to delivery." });
            }
        }

        [HttpGet]
        [Authorize(Policy = "RequireListAllOrdersPermission")]
        public async Task<IActionResult> GetAllOrders(CancellationToken cancellationToken)
        {
            try
            {
                var orders = await _orderService.GetAllOrdersAsync(cancellationToken);
                return Ok(orders);
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetAllOrders");
                return StatusCode(500, new { error = "An error occurred while retrieving all orders." });
            }
        }

        /// <summary>
        /// Download order input file by OrderId
        /// </summary>
        /// <param name="orderId">Order ID</param>
        /// <returns>File download</returns>
        [HttpGet("{orderId:int}/download-input-file")]
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<IActionResult> DownloadOrderInputFile(int orderId, CancellationToken cancellationToken)
        {
            try
            {
                var order = await _orderService.GetOrderByIdAsync(orderId, cancellationToken);
                if (order == null)
                {
                    return NotFound(new { error = "Order not found." });
                }

                if (string.IsNullOrWhiteSpace(order.OrderInputFileLocation))
                {
                    return NotFound(new { error = "Order input file not found for this order." });
                }

                // Construct the full file path
                // Normalize the path by replacing forward slashes with the platform-specific directory separator
                var normalizedPath = order.OrderInputFileLocation.Replace('/', Path.DirectorySeparatorChar);
                var filePath = Path.Combine(_hostEnvironment.ContentRootPath, normalizedPath);

                if (!System.IO.File.Exists(filePath))
                {
                    return NotFound(new { error = "Order input file does not exist on the server." });
                }

                // Get file name from path
                var fileName = Path.GetFileName(filePath);
                
                // Determine content type based on file extension
                var fileExtension = Path.GetExtension(filePath).ToLowerInvariant();
                var contentType = fileExtension switch
                {
                    ".jpg" or ".jpeg" => "image/jpeg",
                    ".png" => "image/png",
                    ".gif" => "image/gif",
                    ".bmp" => "image/bmp",
                    ".mp3" => "audio/mpeg",
                    ".wav" => "audio/wav",
                    ".m4a" => "audio/mp4",
                    ".aac" => "audio/aac",
                    ".ogg" => "audio/ogg",
                    _ => "application/octet-stream"
                };

                var fileBytes = await System.IO.File.ReadAllBytesAsync(filePath, cancellationToken);
                return File(fileBytes, contentType, fileName);
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in DownloadOrderInputFile for Order {OrderId}", orderId);
                return StatusCode(500, new { error = $"An error occurred while downloading the order input file: {ex.Message}" });
            }
        }

        /// <summary>
        /// Download order bill file by OrderId
        /// </summary>
        /// <param name="orderId">Order ID</param>
        /// <returns>File download</returns>
        [HttpGet("{orderId:int}/download-bill")]
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<IActionResult> DownloadOrderBill(int orderId, CancellationToken cancellationToken)
        {
            try
            {
                var order = await _orderService.GetOrderByIdAsync(orderId, cancellationToken);
                if (order == null)
                {
                    return NotFound(new { error = "Order not found." });
                }

                if (string.IsNullOrWhiteSpace(order.OrderBillFileLocation))
                {
                    return NotFound(new { error = "Order bill file not found for this order." });
                }

                // Construct the full file path
                // Normalize the path by replacing forward slashes with the platform-specific directory separator
                var normalizedPath = order.OrderBillFileLocation.Replace('/', Path.DirectorySeparatorChar);
                var filePath = Path.Combine(_hostEnvironment.ContentRootPath, normalizedPath);

                if (!System.IO.File.Exists(filePath))
                {
                    return NotFound(new { error = "Order bill file does not exist on the server." });
                }

                // Get file name from path
                var fileName = Path.GetFileName(filePath);
                
                // Bill files are PDFs
                var contentType = "application/pdf";

                var fileBytes = await System.IO.File.ReadAllBytesAsync(filePath, cancellationToken);
                return File(fileBytes, contentType, fileName);
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in DownloadOrderBill for Order {OrderId}", orderId);
                return StatusCode(500, new { error = $"An error occurred while downloading the order bill file: {ex.Message}" });
            }
        }

        /// <summary>
        /// Get medical stores by order's delivery address city
        /// </summary>
        /// <param name="orderId">Order ID</param>
        /// <returns>List of medical stores in the same city</returns>
        [HttpGet("{orderId:int}/medical-stores-by-city")]
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<IActionResult> GetMedicalStoresByOrderCity(int orderId, CancellationToken cancellationToken)
        {
            try
            {
                var medicalStores = await _orderService.GetMedicalStoresByOrderCityAsync(orderId, cancellationToken);
                return Ok(medicalStores);
            }
            catch (KeyNotFoundException ex)
            {
                _logger.LogWarning("GetMedicalStoresByOrderCity: {Message}", ex.Message);
                return NotFound(new { error = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogWarning("GetMedicalStoresByOrderCity: {Message}", ex.Message);
                return BadRequest(new { error = ex.Message });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetMedicalStoresByOrderCity for Order {OrderId}", orderId);
                return StatusCode(500, new { error = $"An error occurred while retrieving medical stores: {ex.Message}" });
            }
        }

        /// <summary>
        /// Get rejected orders by CustomerSupport ID
        /// </summary>
        /// <param name="customerSupportId">Customer Support ID</param>
        /// <returns>List of rejected orders</returns>
        [HttpGet("customersupport/{customerSupportId:guid}/assignedtocustomersupport")]
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<IActionResult> AssignedToCustomerSupportByCustomerSupportIdAsyncByCustomerSupportIdAsync(Guid customerSupportId, CancellationToken cancellationToken)
        {
            try
            {
                var orders = await _orderService.AssignedToCustomerSupportByCustomerSupportIdAsync(customerSupportId, cancellationToken);
                return Ok(orders);
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning("AssignedToCustomerSupportByCustomerSupportIdAsync: {Message}", ex.Message);
                return BadRequest(new { error = ex.Message });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in AssignedToCustomerSupportByCustomerSupportIdAsync for CustomerSupport {CustomerSupportId}", customerSupportId);
                return StatusCode(500, new { error = "An error occurred while retrieving the orders." });
            }
        }

        /// <summary>
        /// Get all orders by CustomerSupport ID
        /// </summary>
        /// <param name="customerSupportId">Customer Support ID</param>
        /// <returns>List of all orders</returns>
        [HttpGet("customersupport/{customerSupportId:guid}")]
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<IActionResult> GetAllOrdersByCustomerSupportId(Guid customerSupportId, CancellationToken cancellationToken)
        {
            try
            {
                var orders = await _orderService.GetAllOrdersByCustomerSupportIdAsync(customerSupportId, cancellationToken);
                return Ok(orders);
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning("GetAllOrdersByCustomerSupportId: {Message}", ex.Message);
                return BadRequest(new { error = ex.Message });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetAllOrdersByCustomerSupportId for CustomerSupport {CustomerSupportId}", customerSupportId);
                return StatusCode(500, new { error = "An error occurred while retrieving the orders." });
            }
        }

        /// <summary>
        /// Get eligible delivery boys for an order based on shipping address pincode
        /// </summary>
        /// <param name="orderId">Order ID</param>
        /// <returns>List of delivery boys whose region pincode matches the order's shipping address</returns>
        [HttpGet("{orderId:int}/eligible-delivery-boys")]
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<IActionResult> GetEligibleDeliveryBoys(int orderId, CancellationToken cancellationToken)
        {
            try
            {
                var deliveryBoys = await _orderService.GetEligibleDeliveryBoysByOrderIdAsync(orderId, cancellationToken);
                return Ok(deliveryBoys);
            }
            catch (KeyNotFoundException ex)
            {
                _logger.LogWarning("GetEligibleDeliveryBoys: {Message}", ex.Message);
                return NotFound(new { error = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogWarning("GetEligibleDeliveryBoys: {Message}", ex.Message);
                return BadRequest(new { error = ex.Message });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetEligibleDeliveryBoys for Order {OrderId}", orderId);
                return StatusCode(500, new { error = "An error occurred while retrieving eligible delivery boys." });
            }
        }

        /// <summary>
        /// Get orders assigned to the logged-in delivery boy
        /// </summary>
        /// <returns>List of orders assigned to the delivery boy</returns>
        [HttpGet("delivery/my-orders")]
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<IActionResult> GetMyDeliveryOrders(CancellationToken cancellationToken)
        {
            try
            {
                var userIdClaim = User.FindFirst("UserId")?.Value;
                if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var deliveryId))
                {
                    return Unauthorized(new { error = "Delivery boy ID not found in token." });
                }

                var orders = await _orderService.GetOrdersByDeliveryIdAsync(deliveryId, cancellationToken);
                return Ok(orders);
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetMyDeliveryOrders");
                return StatusCode(500, new { error = "An error occurred while retrieving delivery orders." });
            }
        }

        /// <summary>
        /// Get medical stores (chemists) that match the order's shipping address pincode
        /// </summary>
        /// <param name="orderId">Order ID</param>
        /// <returns>List of medical stores in the same pincode</returns>
        [HttpGet("{orderId:int}/medical-stores-by-pincode")]
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<IActionResult> GetMedicalStoresByPinCode(int orderId, CancellationToken cancellationToken)
        {
            try
            {
                var medicalStores = await _orderService.GetMedicalStoresByOrderPinCodeAsync(orderId, cancellationToken);
                return Ok(medicalStores);
            }
            catch (KeyNotFoundException ex)
            {
                _logger.LogWarning("GetMedicalStoresByPinCode: {Message}", ex.Message);
                return NotFound(new { error = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogWarning("GetMedicalStoresByPinCode: {Message}", ex.Message);
                return BadRequest(new { error = ex.Message });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetMedicalStoresByPinCode for Order {OrderId}", orderId);
                return StatusCode(500, new { error = "An error occurred while retrieving medical stores." });
            }
        }
    }
}
