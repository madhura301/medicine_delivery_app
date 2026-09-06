namespace MedicineDelivery.Application.DTOs
{
    /// <summary>
    /// The delivery destination carried inline on <see cref="OrderDto"/>.
    /// Deliberately narrower than <see cref="CustomerAddressDto"/>: it exposes only what is
    /// needed to reach the door (and the coordinates to navigate there), omitting the owning
    /// customer id and the address book's own bookkeeping (IsDefault/IsActive/audit stamps),
    /// none of which a chemist or delivery partner has any business reading.
    /// </summary>
    public class OrderDeliveryAddressDto
    {
        public Guid Id { get; set; }
        public string? Address { get; set; }
        public string? AddressLine1 { get; set; }
        public string? AddressLine2 { get; set; }
        public string? AddressLine3 { get; set; }
        public string? City { get; set; }
        public string? State { get; set; }
        public string? PostalCode { get; set; }
        public decimal? Latitude { get; set; }
        public decimal? Longitude { get; set; }
    }
}
