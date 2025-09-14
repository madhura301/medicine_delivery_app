using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MedicineDelivery.API.Authorization;

namespace MedicineDelivery.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class OrdersController : ControllerBase
    {
        private static readonly List<Order> _orders = new()
        {
            new Order { Id = 1, CustomerName = "John Doe", TotalAmount = 25.97m, Status = "Pending" },
            new Order { Id = 2, CustomerName = "Jane Smith", TotalAmount = 32.98m, Status = "Completed" },
            new Order { Id = 3, CustomerName = "Bob Johnson", TotalAmount = 19.99m, Status = "Shipped" }
        };

        [HttpGet]
        [Authorize(Policy = "RequireReadOrdersPermission")]
        public IActionResult GetOrders()
        {
            return Ok(_orders);
        }

        [HttpGet("{id}")]
        [Authorize(Policy = "RequireReadOrdersPermission")]
        public IActionResult GetOrder(int id)
        {
            var order = _orders.FirstOrDefault(o => o.Id == id);
            if (order == null)
            {
                return NotFound();
            }

            return Ok(order);
        }

        [HttpPost]
        [Authorize(Policy = "RequireCreateOrdersPermission")]
        public IActionResult CreateOrder([FromBody] CreateOrderRequest request)
        {
            var order = new Order
            {
                Id = _orders.Max(o => o.Id) + 1,
                CustomerName = request.CustomerName,
                TotalAmount = request.TotalAmount,
                Status = "Pending"
            };

            _orders.Add(order);
            return CreatedAtAction(nameof(GetOrder), new { id = order.Id }, order);
        }

        [HttpPut("{id}")]
        [Authorize(Policy = "RequireUpdateOrdersPermission")]
        public IActionResult UpdateOrder(int id, [FromBody] UpdateOrderRequest request)
        {
            var order = _orders.FirstOrDefault(o => o.Id == id);
            if (order == null)
            {
                return NotFound();
            }

            order.CustomerName = request.CustomerName;
            order.TotalAmount = request.TotalAmount;
            order.Status = request.Status;

            return Ok(order);
        }

        [HttpDelete("{id}")]
        [Authorize(Policy = "RequireDeleteOrdersPermission")]
        public IActionResult DeleteOrder(int id)
        {
            var order = _orders.FirstOrDefault(o => o.Id == id);
            if (order == null)
            {
                return NotFound();
            }

            _orders.Remove(order);
            return NoContent();
        }
    }

    public class Order
    {
        public int Id { get; set; }
        public string CustomerName { get; set; } = string.Empty;
        public decimal TotalAmount { get; set; }
        public string Status { get; set; } = string.Empty;
    }

    public class CreateOrderRequest
    {
        public string CustomerName { get; set; } = string.Empty;
        public decimal TotalAmount { get; set; }
    }

    public class UpdateOrderRequest
    {
        public string CustomerName { get; set; } = string.Empty;
        public decimal TotalAmount { get; set; }
        public string Status { get; set; } = string.Empty;
    }
}
