namespace MedicineDelivery.Domain.Entities
{
    public class ServiceRegionPinCode
    {
        public int Id { get; set; }
        public int ServiceRegionId { get; set; }
        public string PinCode { get; set; } = string.Empty;

        // Navigation properties
        public ServiceRegion ServiceRegion { get; set; } = null!;
    }
}
