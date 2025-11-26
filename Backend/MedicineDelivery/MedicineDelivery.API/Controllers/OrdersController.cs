using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace MedicineDelivery.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class OrdersController : ControllerBase
    {
        private readonly IOrderService _orderService;

        public OrdersController(IOrderService orderService)
        {
            _orderService = orderService;
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
            catch (Exception)
            {
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
                return BadRequest(new { error = ex.Message });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception)
            {
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
                return BadRequest(new { error = ex.Message });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception)
            {
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
                return NotFound(new { error = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception)
            {
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
                return Ok(order);
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
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception)
            {
                return StatusCode(500, new { error = "An error occurred while rejecting the order." });
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
                return BadRequest(new { error = ex.Message });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { error = ex.Message });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception)
            {
                return StatusCode(500, new { error = "An error occurred while creating the order." });
            }
        }
    }
}


