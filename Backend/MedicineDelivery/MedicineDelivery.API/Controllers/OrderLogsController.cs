using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;
using MedicineDelivery.Domain.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace MedicineDelivery.API.Controllers
{
    /// <summary>
    /// Read-only view of refused order attempts. Gated behind ListAllOrders (Admin and Manager),
    /// the same permission that guards the all-orders view — the log exposes customer names,
    /// addresses and GPS coordinates, so it is deliberately not open to every order reader.
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class OrderLogsController : ControllerBase
    {
        private readonly IOrderLogService _orderLogService;
        private readonly ILogger<OrderLogsController> _logger;

        public OrderLogsController(IOrderLogService orderLogService, ILogger<OrderLogsController> logger)
        {
            _orderLogService = orderLogService;
            _logger = logger;
        }

        /// <summary>Lists refused order attempts, newest first.</summary>
        [HttpGet]
        [Authorize(Policy = "RequireListAllOrdersPermission")]
        [ProducesResponseType(typeof(PagedResultDto<OrderLogListItemDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetOrderLogs(
            [FromQuery] string? search,
            [FromQuery] string? postalCode,
            [FromQuery] OrderLogReason? reason,
            [FromQuery] DateTime? fromDate,
            [FromQuery] DateTime? toDate,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 50,
            CancellationToken cancellationToken = default)
        {
            try
            {
                var result = await _orderLogService.GetOrderLogsAsync(new OrderLogQueryDto
                {
                    Search = search,
                    PostalCode = postalCode,
                    Reason = reason,
                    FromDate = fromDate,
                    ToDate = toDate,
                    Page = page,
                    PageSize = pageSize
                }, cancellationToken);

                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetOrderLogs");
                return StatusCode(StatusCodes.Status500InternalServerError, new { message = "An error occurred while retrieving order logs." });
            }
        }

        /// <summary>Returns one refused attempt including its full free-text diagnostic block.</summary>
        [HttpGet("{orderLogId:long}")]
        [Authorize(Policy = "RequireListAllOrdersPermission")]
        [ProducesResponseType(typeof(OrderLogDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> GetOrderLog(long orderLogId, CancellationToken cancellationToken = default)
        {
            try
            {
                var log = await _orderLogService.GetOrderLogByIdAsync(orderLogId, cancellationToken);
                if (log == null)
                    return NotFound(new { message = $"Order log '{orderLogId}' was not found." });

                return Ok(log);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetOrderLog for {OrderLogId}", orderLogId);
                return StatusCode(StatusCodes.Status500InternalServerError, new { message = "An error occurred while retrieving the order log." });
            }
        }
    }
}
