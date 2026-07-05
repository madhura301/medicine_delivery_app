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
        /// Sends the order OTP to the customer once payment is confirmed, so they can share it
        /// with the delivery boy on handover. Maps to template variables "Order ID" and "OTP".
        /// </summary>
        Task<bool> SendOrderOtpAsync(string phoneNumber, string orderNumber, string otpCode);

        /// <summary>
        /// Sends the order-delivered confirmation SMS to the customer once the delivery boy
        /// verifies the order OTP. Maps to template variables Name (customer), Number (order number)
        /// and Retailer (store name).
        /// </summary>
        Task<bool> SendOrderDeliveredAsync(string phoneNumber, string customerName, string orderNumber, string storeName);
    }
}
