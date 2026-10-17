namespace MedicineDelivery.Application.DTOs
{
    /// <summary>
    /// How to reach the customer of one order — returned only to the chemist handling the order
    /// (and to staff who can read any customer), for the Call Customer action.
    /// </summary>
    public record CustomerContactDto(
        int OrderId,
        string CustomerName,
        string MobileNumber,
        string? AlternativeMobileNumber);
}
