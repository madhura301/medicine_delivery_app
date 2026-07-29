using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Security.Claims;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;
using MedicineDelivery.Domain.Exceptions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace MedicineDelivery.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class OrdersController : ControllerBase
    {
        private readonly IOrderService _orderService;
        private readonly IFileStorageService _fileStorage;
        private readonly IOrderAccessGuard _accessGuard;
        private readonly IPermissionCheckerService _permissionChecker;
        private readonly ILogger<OrdersController> _logger;

        public OrdersController(
            IOrderService orderService,
            IFileStorageService fileStorage,
            IOrderAccessGuard accessGuard,
            IPermissionCheckerService permissionChecker,
            ILogger<OrdersController> logger)
        {
            _orderService = orderService;
            _fileStorage = fileStorage;
            _accessGuard = accessGuard;
            _permissionChecker = permissionChecker;
            _logger = logger;
        }

        /// <summary>Current caller's Identity user id.</summary>
        private string CurrentUserId => User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? string.Empty;

        /// <summary>Admin/Manager hold ListAllOrders and bypass ownership checks.</summary>
        private Task<bool> HasFullOrderAccessAsync() =>
            _permissionChecker.HasPermissionAsync(User, "ListAllOrders");

        /// <summary>
        /// H-02: reveals the delivery OTP on a single order only when it is fully paid AND the
        /// caller is that order's own customer. The mapping never populates OTP, so anything not
        /// explicitly revealed here stays null.
        /// </summary>
        private async Task<OrderDto> RevealOtpIfPermittedAsync(OrderDto order, CancellationToken ct)
        {
            order.OTP = await _accessGuard.GetVisibleOtpAsync(CurrentUserId, order.OrderId, ct);
            return order;
        }

        /// <summary>Bulk form of <see cref="RevealOtpIfPermittedAsync"/> for list responses.</summary>
        private async Task<IEnumerable<OrderDto>> RevealOtpIfPermittedAsync(IEnumerable<OrderDto> orders, CancellationToken ct)
        {
            var list = orders?.ToList() ?? new List<OrderDto>();
            if (list.Count == 0) return list;

            var visible = await _accessGuard.GetVisibleOtpsAsync(CurrentUserId, list.Select(o => o.OrderId), ct);
            foreach (var o in list)
            {
                o.OTP = visible.TryGetValue(o.OrderId, out var otp) ? otp : null;
            }
            return list;
        }

        /// <summary>C-02: verifies the caller is actually a party to this order.</summary>
        private async Task<bool> CanAccessOrderAsync(int orderId, CancellationToken ct) =>
            await _accessGuard.CanAccessOrderAsync(CurrentUserId, await HasFullOrderAccessAsync(), orderId, ct);

        [HttpGet("{orderId:int}")]
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<IActionResult> GetOrderById(int orderId, CancellationToken cancellationToken)
        {
            try
            {
                if (!await CanAccessOrderAsync(orderId, cancellationToken))
                {
                    return Forbid();
                }

                var order = await _orderService.GetOrderByIdAsync(orderId, cancellationToken);
                if (order == null)
                {
                    return NotFound(new { error = "Order not found." });
                }

                return Ok(await RevealOtpIfPermittedAsync(order, cancellationToken));
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
                if (!await _accessGuard.CanAccessCustomerAsync(CurrentUserId, await HasFullOrderAccessAsync(), customerId, cancellationToken))
                {
                    return Forbid();
                }

                var orders = await _orderService.GetOrdersByCustomerIdAsync(customerId, cancellationToken);
                return Ok(await RevealOtpIfPermittedAsync(orders, cancellationToken));
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
                if (!await _accessGuard.CanAccessCustomerAsync(CurrentUserId, await HasFullOrderAccessAsync(), customerId, cancellationToken))
                {
                    return Forbid();
                }

                var orders = await _orderService.GetActiveOrdersByCustomerIdAsync(customerId, cancellationToken);
                return Ok(await RevealOtpIfPermittedAsync(orders, cancellationToken));
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
                if (!await _accessGuard.CanAccessMedicalStoreAsync(CurrentUserId, await HasFullOrderAccessAsync(), medicalStoreId, cancellationToken))
                {
                    return Forbid();
                }

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
                if (!await _accessGuard.CanAccessMedicalStoreAsync(CurrentUserId, await HasFullOrderAccessAsync(), medicalStoreId, cancellationToken))
                {
                    return Forbid();
                }

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
                if (!await _accessGuard.CanAccessMedicalStoreAsync(CurrentUserId, await HasFullOrderAccessAsync(), medicalStoreId, cancellationToken))
                {
                    return Forbid();
                }

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
                if (!await _accessGuard.CanAccessMedicalStoreAsync(CurrentUserId, await HasFullOrderAccessAsync(), medicalStoreId, cancellationToken))
                {
                    return Forbid();
                }

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
                if (!await CanAccessOrderAsync(orderId, cancellationToken))
                {
                    return Forbid();
                }

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
                if (!await CanAccessOrderAsync(orderId, cancellationToken))
                {
                    return Forbid();
                }

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
                if (!await CanAccessOrderAsync(orderId, cancellationToken))
                {
                    return Forbid();
                }

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
            catch (PaymentIncompleteException ex)
            {
                _logger.LogWarning("CompleteOrder: {Message}", ex.Message);
                return BadRequest(new
                {
                    error = ex.Message,
                    orderId = ex.OrderId,
                    totalAmount = ex.TotalAmount,
                    paidAmount = ex.PaidAmount,
                    remainingAmount = ex.RemainingAmount,
                });
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

        /// <summary>
        /// Cancels an order, recording a mandatory cancellation reason. Restricted to customer support,
        /// manager and admin via the CancelOrders permission.
        /// </summary>
        [HttpPut("{orderId:int}/cancel")]
        [Authorize(Policy = "RequireOrderCancelPermission")]
        public async Task<IActionResult> CancelOrder(int orderId, [FromBody] CancelOrderDto cancelDto, CancellationToken cancellationToken)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                if (!await CanAccessOrderAsync(orderId, cancellationToken))
                {
                    return Forbid();
                }

                var order = await _orderService.CancelOrderAsync(orderId, cancelDto, cancellationToken);
                return Ok(order);
            }
            catch (KeyNotFoundException ex)
            {
                _logger.LogWarning("CancelOrder: {Message}", ex.Message);
                return NotFound(new { error = ex.Message });
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning("CancelOrder: {Message}", ex.Message);
                return BadRequest(new { error = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogWarning("CancelOrder: {Message}", ex.Message);
                return BadRequest(new { error = ex.Message });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in CancelOrder for Order {OrderId}", orderId);
                return StatusCode(500, new { error = "An error occurred while cancelling the order." });
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
                if (!await CanAccessOrderAsync(assignDto.OrderId, cancellationToken))
                {
                    return Forbid();
                }

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
        [HttpPost("CreateOrder")] // Alias: some clients POST to /api/Orders/CreateOrder
        [Consumes("multipart/form-data")]
        [Authorize(Policy = "RequireOrderCreatePermission")]
        public async Task<IActionResult> CreateOrder([FromForm] CreateOrderDto request, CancellationToken cancellationToken)
        {
            // A short correlation id is opened as a logging scope so that EVERY log line emitted for this
            // request — in this controller AND inside OrderService and its private helpers — carries the same
            // {CorrelationId} property. Grep the logs for one CorrelationId to replay a single order end-to-end.
            var correlationId = Guid.NewGuid().ToString("N").Substring(0, 8);
            using var logScope = _logger.BeginScope(new Dictionary<string, object?>
            {
                ["CorrelationId"] = correlationId,
                ["CustomerId"] = request?.CustomerId,
                ["CustomerAddressId"] = request?.CustomerAddressId,
                ["OrderType"] = request?.OrderType,
                ["OrderInputType"] = request?.OrderInputType
            });

            var inputFileName = request?.OrderInputFile?.FileName;
            var inputFileLength = request?.OrderInputFile?.Length ?? 0;
            _logger.LogInformation(
                "CreateOrder [{CorrelationId}] START: Customer={CustomerId}, Address={CustomerAddressId}, OrderType={OrderType}, InputType={OrderInputType}, HasInputText={HasInputText}, InputFile={InputFileName} ({InputFileLength} bytes)",
                correlationId, request?.CustomerId, request?.CustomerAddressId, request?.OrderType, request?.OrderInputType,
                !string.IsNullOrWhiteSpace(request?.OrderInputText), inputFileName ?? "(none)", inputFileLength);

            if (!ModelState.IsValid)
            {
                var validationErrors = string.Join("; ", ModelState
                    .Where(kvp => kvp.Value != null && kvp.Value.Errors.Count > 0)
                    .Select(kvp => $"{kvp.Key}: {string.Join(", ", kvp.Value!.Errors.Select(e => e.ErrorMessage))}"));
                _logger.LogWarning("CreateOrder [{CorrelationId}] REJECTED: ModelState invalid. Errors: {ValidationErrors}", correlationId, validationErrors);
                return BadRequest(ModelState);
            }

            try
            {
                _logger.LogInformation("CreateOrder [{CorrelationId}] STEP: ModelState valid, delegating to OrderService.CreateOrderAsync", correlationId);
                var order = await _orderService.CreateOrderAsync(request!, cancellationToken);
                _logger.LogInformation(
                    "CreateOrder [{CorrelationId}] SUCCESS: OrderId={OrderId}, OrderNumber={OrderNumber}, Status={OrderStatus}, MedicalStoreId={MedicalStoreId}, CustomerSupportId={CustomerSupportId}, ManagerId={ManagerId}",
                    correlationId, order.OrderId, order.OrderNumber, order.OrderStatus, order.MedicalStoreId, order.CustomerSupportId, order.ManagerId);
                return CreatedAtAction(nameof(GetOrderById), new { orderId = order.OrderId }, order);
            }
            catch (ServiceAreaUnavailableException ex)
            {
                _logger.LogWarning("CreateOrder [{CorrelationId}] BLOCKED (area not serviceable): {Message}. PostalCode={PostalCode}, MissingRoles={MissingRoles}",
                    correlationId, ex.Message, ex.PostalCode, string.Join(", ", ex.MissingRoles));
                return BadRequest(new { error = ex.Message, postalCode = ex.PostalCode, missingRoles = ex.MissingRoles });
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning("CreateOrder [{CorrelationId}] REJECTED (invalid argument): {Message} (param: {ParamName})", correlationId, ex.Message, ex.ParamName ?? "(none)");
                return BadRequest(new { error = ex.Message });
            }
            catch (KeyNotFoundException ex)
            {
                _logger.LogWarning("CreateOrder [{CorrelationId}] NOT FOUND: {Message}", correlationId, ex.Message);
                return NotFound(new { error = ex.Message });
            }
            catch (OperationCanceledException)
            {
                _logger.LogInformation("CreateOrder [{CorrelationId}] CANCELLED by caller/client", correlationId);
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "CreateOrder [{CorrelationId}] FAILED with unhandled exception", correlationId);
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
                if (!await CanAccessOrderAsync(orderId, cancellationToken))
                {
                    return Forbid();
                }

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
                if (!await CanAccessOrderAsync(assignDto.OrderId, cancellationToken))
                {
                    return Forbid();
                }

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

        /// <summary>
        /// Assigns a delivery boy to an order. Route-based variant used by the WebApp:
        /// the order id comes from the route and only the delivery boy id is in the body.
        /// Delegates to the same logic as <see cref="AssignOrderToDelivery"/>.
        /// </summary>
        [HttpPut("{orderId:int}/assign-delivery")]
        [Authorize(Policy = "RequireOrderUpdatePermission")]
        public async Task<IActionResult> AssignDelivery(int orderId, [FromBody] AssignDeliveryRequestDto request, CancellationToken cancellationToken)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var assignDto = new AssignOrderToDeliveryDto { OrderId = orderId, DeliveryId = request.DeliveryId };

            try
            {
                var order = await _orderService.AssignOrderToDeliveryAsync(assignDto, cancellationToken);
                return Ok(order);
            }
            catch (KeyNotFoundException ex)
            {
                _logger.LogWarning("AssignDelivery: {Message}", ex.Message);
                return NotFound(new { error = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogWarning("AssignDelivery: {Message}", ex.Message);
                return BadRequest(new { error = ex.Message });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in AssignDelivery for Order {OrderId}", orderId);
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
                if (!await CanAccessOrderAsync(orderId, cancellationToken))
                {
                    return Forbid();
                }

                var order = await _orderService.GetOrderByIdAsync(orderId, cancellationToken);
                if (order == null)
                {
                    return NotFound(new { error = "Order not found." });
                }

                if (string.IsNullOrWhiteSpace(order.OrderInputFileLocation))
                {
                    return NotFound(new { error = "Order input file not found for this order." });
                }

                var stream = await _fileStorage.OpenReadAsync(order.OrderInputFileLocation, cancellationToken);
                if (stream == null)
                {
                    return NotFound(new { error = "Order input file does not exist on the server." });
                }

                var fileName = Path.GetFileName(order.OrderInputFileLocation);
                var fileExtension = Path.GetExtension(order.OrderInputFileLocation).ToLowerInvariant();
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

                return File(stream, contentType, fileName);
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
                if (!await CanAccessOrderAsync(orderId, cancellationToken))
                {
                    return Forbid();
                }

                var order = await _orderService.GetOrderByIdAsync(orderId, cancellationToken);
                if (order == null)
                {
                    return NotFound(new { error = "Order not found." });
                }

                if (string.IsNullOrWhiteSpace(order.OrderBillFileLocation))
                {
                    return NotFound(new { error = "Order bill file not found for this order." });
                }

                var stream = await _fileStorage.OpenReadAsync(order.OrderBillFileLocation, cancellationToken);
                if (stream == null)
                {
                    return NotFound(new { error = "Order bill file does not exist on the server." });
                }

                var fileName = Path.GetFileName(order.OrderBillFileLocation);
                var fileExtension = Path.GetExtension(order.OrderBillFileLocation).ToLowerInvariant();
                var contentType = fileExtension switch
                {
                    ".pdf" => "application/pdf",
                    ".jpg" or ".jpeg" => "image/jpeg",
                    ".png" => "image/png",
                    ".gif" => "image/gif",
                    ".bmp" => "image/bmp",
                    _ => "application/octet-stream"
                };

                return File(stream, contentType, fileName);
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
                if (!await CanAccessOrderAsync(orderId, cancellationToken))
                {
                    return Forbid();
                }

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
        /// Get orders currently escalated to a manager (awaiting the manager to re-assign to a chemist)
        /// </summary>
        /// <param name="managerId">Manager ID</param>
        /// <returns>List of orders in AssignedToManager status for this manager</returns>
        [HttpGet("manager/{managerId:guid}/assignedtomanager")]
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<IActionResult> AssignedToManagerByManagerId(Guid managerId, CancellationToken cancellationToken)
        {
            try
            {
                var orders = await _orderService.AssignedToManagerByManagerIdAsync(managerId, cancellationToken);
                return Ok(orders);
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning("AssignedToManagerByManagerId: {Message}", ex.Message);
                return BadRequest(new { error = ex.Message });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in AssignedToManagerByManagerId for Manager {ManagerId}", managerId);
                return StatusCode(500, new { error = "An error occurred while retrieving the orders." });
            }
        }

        /// <summary>
        /// Get all orders by Manager ID
        /// </summary>
        /// <param name="managerId">Manager ID</param>
        /// <returns>List of all orders handled by this manager</returns>
        [HttpGet("manager/{managerId:guid}")]
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<IActionResult> GetAllOrdersByManagerId(Guid managerId, CancellationToken cancellationToken)
        {
            try
            {
                var orders = await _orderService.GetAllOrdersByManagerIdAsync(managerId, cancellationToken);
                return Ok(orders);
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning("GetAllOrdersByManagerId: {Message}", ex.Message);
                return BadRequest(new { error = ex.Message });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetAllOrdersByManagerId for Manager {ManagerId}", managerId);
                return StatusCode(500, new { error = "An error occurred while retrieving the orders." });
            }
        }

        /// <summary>
        /// Get eligible delivery boys for an order based on shipping address pincode
        /// </summary>
        /// <param name="orderId">Order ID</param>
        /// <returns>List of delivery boys whose region pincode matches the order's shipping address</returns>
        [HttpGet("{orderId:int}/eligible-delivery-boys")]
        [HttpGet("{orderId:int}/eligible-deliveries")] // Alias: the WebApp calls this route.
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<IActionResult> GetEligibleDeliveryBoys(int orderId, CancellationToken cancellationToken)
        {
            try
            {
                if (!await CanAccessOrderAsync(orderId, cancellationToken))
                {
                    return Forbid();
                }

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
        /// <summary>
        /// Find nearby chemists for an order — first by 5KM radius, then by postal code if fewer than 3 found
        /// </summary>
        /// <param name="orderNumber">Order Number</param>
        /// <returns>List of nearby chemists with match type and distance</returns>
        [HttpGet("nearby-chemists/{orderNumber}")]
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<IActionResult> GetNearbyChemists(string orderNumber, CancellationToken cancellationToken)
        {
            try
            {
                var result = await _orderService.GetNearbyChemistsByOrderNumberAsync(orderNumber, cancellationToken);
                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                _logger.LogWarning("GetNearbyChemists: {Message}", ex.Message);
                return NotFound(new { error = ex.Message });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetNearbyChemists for Order {OrderNumber}", orderNumber);
                return StatusCode(500, new { error = "An error occurred while retrieving nearby chemists." });
            }
        }

        [HttpGet("{orderId:int}/medical-stores-by-pincode")]
        [Authorize(Policy = "RequireOrderReadPermission")]
        public async Task<IActionResult> GetMedicalStoresByPinCode(int orderId, CancellationToken cancellationToken)
        {
            try
            {
                if (!await CanAccessOrderAsync(orderId, cancellationToken))
                {
                    return Forbid();
                }

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
