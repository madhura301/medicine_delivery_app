namespace MedicineDelivery.Domain.Interfaces
{
    public interface ISmsService
    {
        /// <summary>
        /// Sends a one-time password to the given phone number.
        /// <paramref name="recipientName"/> populates the name placeholder in the SMS template.
        /// </summary>
        Task<bool> SendOtpAsync(string phoneNumber, string otpCode, string? recipientName = null);

        /// <summary>
        /// Sends the order payment-confirmation SMS to the customer.
        /// Maps to template variables Name (customer), Number (order number) and Retailer (store name).
        /// </summary>
        Task<bool> SendPaymentConfirmationAsync(string phoneNumber, string customerName, string orderNumber, string storeName);
    }
}
