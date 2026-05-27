namespace MedicineDelivery.Domain.Interfaces
{
    public interface ISmsService
    {
        Task<bool> SendOtpAsync(string phoneNumber, string otpCode);
    }
}
