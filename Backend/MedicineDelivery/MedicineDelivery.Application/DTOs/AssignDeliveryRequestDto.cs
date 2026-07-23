using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace MedicineDelivery.Application.DTOs
{
    /// <summary>
    /// Request body for <c>PUT /api/Orders/{orderId}/assign-delivery</c>. The order id
    /// comes from the route, so only the delivery boy id is supplied in the body.
    /// </summary>
    public class AssignDeliveryRequestDto
    {
        // The WebApp may send the id as a JSON number (4) or a numeric string ("4"),
        // so accept both when deserializing.
        [Required]
        [JsonNumberHandling(JsonNumberHandling.AllowReadingFromString)]
        public int DeliveryId { get; set; }
    }
}
