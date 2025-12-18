namespace MedicineDelivery.Domain.Entities
{
    public class CustomerSupportRegion
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string City { get; set; } = string.Empty;
        public string RegionName { get; set; } = string.Empty;

        // Navigation property for many-to-many relationship with PinCodes
        public ICollection<CustomerSupportRegionPinCode> RegionPinCodes { get; set; } = new List<CustomerSupportRegionPinCode>();
    }
}

