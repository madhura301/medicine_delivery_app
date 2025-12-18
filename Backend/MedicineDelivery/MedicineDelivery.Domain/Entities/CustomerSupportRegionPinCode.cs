namespace MedicineDelivery.Domain.Entities
{
    public class CustomerSupportRegionPinCode
    {
        public int Id { get; set; }
        public int CustomerSupportRegionId { get; set; }
        public string PinCode { get; set; } = string.Empty;

        // Navigation properties
        public CustomerSupportRegion CustomerSupportRegion { get; set; } = null!;
    }
}

