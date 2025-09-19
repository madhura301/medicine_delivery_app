namespace MedicineDelivery.Application.DTOs
{
    public class MedicalStoreRegistrationDto
    {
        public string MedicalName { get; set; } = string.Empty;
        public string OwnerFirstName { get; set; } = string.Empty;
        public string OwnerLastName { get; set; } = string.Empty;
        public string OwnerMiddleName { get; set; } = string.Empty;
        
        // Address fields
        public string AddressLine1 { get; set; } = string.Empty;
        public string AddressLine2 { get; set; } = string.Empty;
        public string City { get; set; } = string.Empty;
        public string State { get; set; } = string.Empty;
        public string PostalCode { get; set; } = string.Empty;
        
        public decimal? Latitude { get; set; }
        public decimal? Longitude { get; set; }
        public string MobileNumber { get; set; } = string.Empty;
        public string EmailId { get; set; } = string.Empty;
        public string AlternativeMobileNumber { get; set; } = string.Empty;
        
        // Registration and tax information
        public bool RegistrationStatus { get; set; } = false;
        public string? GSTIN { get; set; } // Nullable as requested
        public string PAN { get; set; } = string.Empty;
        public string FSSAINo { get; set; } = string.Empty;
        public string DLNo { get; set; } = string.Empty;
        
        // Pharmacist information
        public string PharmacistFirstName { get; set; } = string.Empty;
        public string PharmacistLastName { get; set; } = string.Empty;
        public string PharmacistRegistrationNumber { get; set; } = string.Empty;
        public string PharmacistMobileNumber { get; set; } = string.Empty;
    }

    public class MedicalStoreResponseDto
    {
        public Guid MedicalStoreId { get; set; }
        public string MedicalName { get; set; } = string.Empty;
        public string OwnerFirstName { get; set; } = string.Empty;
        public string OwnerLastName { get; set; } = string.Empty;
        public string OwnerMiddleName { get; set; } = string.Empty;
        
        // Address fields
        public string AddressLine1 { get; set; } = string.Empty;
        public string AddressLine2 { get; set; } = string.Empty;
        public string City { get; set; } = string.Empty;
        public string State { get; set; } = string.Empty;
        public string PostalCode { get; set; } = string.Empty;
        
        public decimal? Latitude { get; set; }
        public decimal? Longitude { get; set; }
        public string MobileNumber { get; set; } = string.Empty;
        public string EmailId { get; set; } = string.Empty;
        public string AlternativeMobileNumber { get; set; } = string.Empty;
        
        // Registration and tax information
        public bool RegistrationStatus { get; set; }
        public string? GSTIN { get; set; }
        public string PAN { get; set; } = string.Empty;
        public string FSSAINo { get; set; } = string.Empty;
        public string DLNo { get; set; } = string.Empty;
        
        // Pharmacist information
        public string PharmacistFirstName { get; set; } = string.Empty;
        public string PharmacistLastName { get; set; } = string.Empty;
        public string PharmacistRegistrationNumber { get; set; } = string.Empty;
        public string PharmacistMobileNumber { get; set; } = string.Empty;
        
        public bool IsActive { get; set; }
        public bool IsDeleted { get; set; }
        public DateTime CreatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public string? UserId { get; set; }
        public string GeneratedPassword { get; set; } = string.Empty;
    }

    public class MedicalStoreDto
    {
        public Guid MedicalStoreId { get; set; }
        public string MedicalName { get; set; } = string.Empty;
        public string OwnerFirstName { get; set; } = string.Empty;
        public string OwnerLastName { get; set; } = string.Empty;
        public string OwnerMiddleName { get; set; } = string.Empty;
        
        // Address fields
        public string AddressLine1 { get; set; } = string.Empty;
        public string AddressLine2 { get; set; } = string.Empty;
        public string City { get; set; } = string.Empty;
        public string State { get; set; } = string.Empty;
        public string PostalCode { get; set; } = string.Empty;
        
        public decimal? Latitude { get; set; }
        public decimal? Longitude { get; set; }
        public string MobileNumber { get; set; } = string.Empty;
        public string EmailId { get; set; } = string.Empty;
        public string AlternativeMobileNumber { get; set; } = string.Empty;
        
        // Registration and tax information
        public bool RegistrationStatus { get; set; }
        public string? GSTIN { get; set; }
        public string PAN { get; set; } = string.Empty;
        public string FSSAINo { get; set; } = string.Empty;
        public string DLNo { get; set; } = string.Empty;
        
        // Pharmacist information
        public string PharmacistFirstName { get; set; } = string.Empty;
        public string PharmacistLastName { get; set; } = string.Empty;
        public string PharmacistRegistrationNumber { get; set; } = string.Empty;
        public string PharmacistMobileNumber { get; set; } = string.Empty;
        
        public bool IsActive { get; set; }
        public bool IsDeleted { get; set; }
        public DateTime CreatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public string? UserId { get; set; }
    }
}
