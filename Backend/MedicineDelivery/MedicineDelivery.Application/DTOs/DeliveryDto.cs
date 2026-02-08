namespace MedicineDelivery.Application.DTOs
{
    public class DeliveryDto
    {
        public int Id { get; set; }
        public string? FirstName { get; set; }
        public string? MiddleName { get; set; }
        public string? LastName { get; set; }
        public string? DrivingLicenceNumber { get; set; }
        public string? MobileNumber { get; set; }
        public bool IsActive { get; set; }
        public bool IsDeleted { get; set; }
        public Guid? MedicalStoreId { get; set; }
        public int? ServiceRegionId { get; set; }
        public DateTime AddedOn { get; set; }
        public DateTime? ModifiedOn { get; set; }
        public Guid? AddedBy { get; set; }
        public Guid? ModifiedBy { get; set; }
    }

    public class CreateDeliveryDto
    {
        public string? FirstName { get; set; }
        public string? MiddleName { get; set; }
        public string? LastName { get; set; }
        public string? DrivingLicenceNumber { get; set; }
        public string? MobileNumber { get; set; }
        public Guid? MedicalStoreId { get; set; }
        public int? ServiceRegionId { get; set; }
    }

    public class UpdateDeliveryDto
    {
        public string? FirstName { get; set; }
        public string? MiddleName { get; set; }
        public string? LastName { get; set; }
        public string? DrivingLicenceNumber { get; set; }
        public string? MobileNumber { get; set; }
        public bool? IsActive { get; set; }
        public Guid? MedicalStoreId { get; set; }
        public int? ServiceRegionId { get; set; }
    }
}

