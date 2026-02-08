using MedicineDelivery.Domain.Enums;

namespace MedicineDelivery.Domain.Entities
{
    public class ServiceRegion
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string City { get; set; } = string.Empty;
        public string RegionName { get; set; } = string.Empty;
        public RegionType RegionType { get; set; }

        // Navigation property for many-to-many relationship with PinCodes
        public ICollection<ServiceRegionPinCode> RegionPinCodes { get; set; } = new List<ServiceRegionPinCode>();
    }
}
