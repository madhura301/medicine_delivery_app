using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MedicineDelivery.API.Authorization;

namespace MedicineDelivery.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ProductsController : ControllerBase
    {
        private static readonly List<Product> _products = new()
        {
            new Product { Id = 1, Name = "Aspirin", Price = 5.99m, Category = "Pain Relief" },
            new Product { Id = 2, Name = "Ibuprofen", Price = 7.99m, Category = "Pain Relief" },
            new Product { Id = 3, Name = "Vitamin C", Price = 12.99m, Category = "Vitamins" },
            new Product { Id = 4, Name = "Multivitamin", Price = 19.99m, Category = "Vitamins" }
        };

        [HttpGet]
        [Authorize(Policy = "RequireReadProductsPermission")]
        public IActionResult GetProducts()
        {
            return Ok(_products);
        }

        [HttpGet("{id}")]
        [Authorize(Policy = "RequireReadProductsPermission")]
        public IActionResult GetProduct(int id)
        {
            var product = _products.FirstOrDefault(p => p.Id == id);
            if (product == null)
            {
                return NotFound();
            }

            return Ok(product);
        }

        [HttpPost]
        [Authorize(Policy = "RequireCreateProductsPermission")]
        public IActionResult CreateProduct([FromBody] CreateProductRequest request)
        {
            var product = new Product
            {
                Id = _products.Max(p => p.Id) + 1,
                Name = request.Name,
                Price = request.Price,
                Category = request.Category
            };

            _products.Add(product);
            return CreatedAtAction(nameof(GetProduct), new { id = product.Id }, product);
        }

        [HttpPut("{id}")]
        [Authorize(Policy = "RequireUpdateProductsPermission")]
        public IActionResult UpdateProduct(int id, [FromBody] UpdateProductRequest request)
        {
            var product = _products.FirstOrDefault(p => p.Id == id);
            if (product == null)
            {
                return NotFound();
            }

            product.Name = request.Name;
            product.Price = request.Price;
            product.Category = request.Category;

            return Ok(product);
        }

        [HttpDelete("{id}")]
        [Authorize(Policy = "RequireDeleteProductsPermission")]
        public IActionResult DeleteProduct(int id)
        {
            var product = _products.FirstOrDefault(p => p.Id == id);
            if (product == null)
            {
                return NotFound();
            }

            _products.Remove(product);
            return NoContent();
        }
    }

    public class Product
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public decimal Price { get; set; }
        public string Category { get; set; } = string.Empty;
    }

    public class CreateProductRequest
    {
        public string Name { get; set; } = string.Empty;
        public decimal Price { get; set; }
        public string Category { get; set; } = string.Empty;
    }

    public class UpdateProductRequest
    {
        public string Name { get; set; } = string.Empty;
        public decimal Price { get; set; }
        public string Category { get; set; } = string.Empty;
    }
}
