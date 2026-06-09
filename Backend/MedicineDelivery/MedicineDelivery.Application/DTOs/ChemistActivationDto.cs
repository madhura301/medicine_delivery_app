using MedicineDelivery.Domain.Enums;

namespace MedicineDelivery.Application.DTOs
{
    /// <summary>Read model for a chemist's activation-fee payment.</summary>
    public class ChemistActivationDto
    {
        public Guid MedicalStoreId { get; set; }
        public decimal Amount { get; set; }
        public decimal Gst { get; set; }
        public decimal? GatewayCharges { get; set; }
        public decimal Total { get; set; }
        public ChemistActivationStatus Status { get; set; }
        public string StatusName => Status.ToString();
        public string? PaymentLinkUrl { get; set; }
        public string? PaymentLinkId { get; set; }
        public bool IsActivated { get; set; }
        public DateTime CreatedOn { get; set; }
        public DateTime? PaidOn { get; set; }
    }

    /// <summary>Result wrapper for chemist-activation operations (service → controller).</summary>
    public class ChemistActivationResult
    {
        public bool Success { get; set; }
        public ChemistActivationDto? Data { get; set; }
        public List<string> Errors { get; set; } = new();

        public static ChemistActivationResult Ok(ChemistActivationDto data) =>
            new() { Success = true, Data = data };

        public static ChemistActivationResult Fail(params string[] errors) =>
            new() { Success = false, Errors = errors.ToList() };
    }
}
