namespace MedicineDelivery.Application.DTOs
{
    public class CustomerSupportRegionDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string City { get; set; } = string.Empty;
        public string RegionName { get; set; } = string.Empty;
        public List<string> PinCodes { get; set; } = new();
    }

    public class CreateCustomerSupportRegionDto
    {
        public string Name { get; set; } = string.Empty;
        public string City { get; set; } = string.Empty;
        public string RegionName { get; set; } = string.Empty;
        public List<string> PinCodes { get; set; } = new();
    }

    public class UpdateCustomerSupportRegionDto
    {
        public string? Name { get; set; }
        public string? City { get; set; }
        public string? RegionName { get; set; }
        public List<string>? PinCodes { get; set; }
    }

    public class AddPinCodeToRegionDto
    {
        public int CustomerSupportRegionId { get; set; }
        public string PinCode { get; set; } = string.Empty;
    }

    public class RemovePinCodeFromRegionDto
    {
        public int CustomerSupportRegionId { get; set; }
        public string PinCode { get; set; } = string.Empty;
    }
}

