using MedicineDelivery.Domain.Enums;

namespace MedicineDelivery.Application.DTOs
{
    public class ServiceRegionDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string City { get; set; } = string.Empty;
        public string RegionName { get; set; } = string.Empty;
        public RegionType RegionType { get; set; }
        public List<string> PinCodes { get; set; } = new();
    }

    public class CreateServiceRegionDto
    {
        public string Name { get; set; } = string.Empty;
        public string City { get; set; } = string.Empty;
        public string RegionName { get; set; } = string.Empty;
        public RegionType RegionType { get; set; }
        public List<string> PinCodes { get; set; } = new();
    }

    public class UpdateServiceRegionDto
    {
        public string? Name { get; set; }
        public string? City { get; set; }
        public string? RegionName { get; set; }
        public RegionType? RegionType { get; set; }
        public List<string>? PinCodes { get; set; }
    }

    public class AddPinCodeToRegionDto
    {
        public int ServiceRegionId { get; set; }
        public string PinCode { get; set; } = string.Empty;
    }

    public class RemovePinCodeFromRegionDto
    {
        public int ServiceRegionId { get; set; }
        public string PinCode { get; set; } = string.Empty;
    }

    public class AssignCustomerSupportRegionDto
    {
        public int ServiceRegionId { get; set; }
        public Guid CustomerSupportId { get; set; }
    }

    public class AssignCustomerSupportRegionBulkDto
    {
        public int ServiceRegionId { get; set; }
        public List<Guid> CustomerSupportIds { get; set; } = new();
    }

    public class AssignDeliveryRegionDto
    {
        public int ServiceRegionId { get; set; }
        public int DeliveryId { get; set; }
    }

    public class AssignDeliveryRegionBulkDto
    {
        public int ServiceRegionId { get; set; }
        public List<int> DeliveryIds { get; set; } = new();
    }
}
