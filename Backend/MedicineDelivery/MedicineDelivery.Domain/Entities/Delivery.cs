namespace MedicineDelivery.Domain.Entities
{
    public class Delivery
    {
        public int Id { get; set; }
        public string? FirstName { get; set; }
        public string? MiddleName { get; set; }
        public string? LastName { get; set; }
        public string? DrivingLicenceNumber { get; set; }
        public string? MobileNumber { get; set; }
        public bool IsActive { get; set; } = true;
        public bool IsDeleted { get; set; } = false;
        public Guid? MedicalStoreId { get; set; }
        public DateTime AddedOn { get; set; } = DateTime.UtcNow;
        public DateTime? ModifiedOn { get; set; }
        public Guid? AddedBy { get; set; }
        public Guid? ModifiedBy { get; set; }

        // Navigation property
        public MedicalStore? MedicalStore { get; set; }
    }
}

