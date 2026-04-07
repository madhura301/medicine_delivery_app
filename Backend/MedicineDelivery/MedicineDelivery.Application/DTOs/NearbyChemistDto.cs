using MedicineDelivery.Domain.Enums;

namespace MedicineDelivery.Application.DTOs
{
    public class NearbyChemistDto
    {
        public Guid MedicalStoreId { get; set; }
        public string MedicalName { get; set; } = string.Empty;
        public string AddressLine1 { get; set; } = string.Empty;
        public string AddressLine2 { get; set; } = string.Empty;
        public string City { get; set; } = string.Empty;
        public string State { get; set; } = string.Empty;
        public string PostalCode { get; set; } = string.Empty;
        public decimal? Latitude { get; set; }
        public decimal? Longitude { get; set; }
        public string MobileNumber { get; set; } = string.Empty;
        public ChemistMatchType MatchType { get; set; }
        public double? DistanceInKm { get; set; }
    }

    public class NearbyChemistResponseDto
    {
        public string OrderNumber { get; set; } = string.Empty;
        public int TotalChemists { get; set; }
        public List<NearbyChemistDto> Chemists { get; set; } = new();
    }
}
