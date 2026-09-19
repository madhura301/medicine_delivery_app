using System.Net.Http.Json;
using System.Text.Json;
using MedicineDelivery.Domain.Interfaces;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace MedicineDelivery.Infrastructure.Services
{
    /// <summary>
    /// MSG91 Flow API implementation of <see cref="ISmsService"/>.
    /// Sends the forgot-password OTP using a DLT-approved template where
    /// var1 = recipient name and var2 = the OTP code.
    /// Configured via the SmsSettings section (AuthKey, OtpTemplateId, OrderOtpTemplateId, PaymentTemplateId).
    /// </summary>
    public class Msg91SmsService : ISmsService
    {
        private const string FlowUrl = "https://control.msg91.com/api/v5/flow";

        private readonly HttpClient _httpClient;
        private readonly ILogger<Msg91SmsService> _logger;
        private readonly string _authKey;
        private readonly string _otpTemplateId;
        private readonly string _orderOtpTemplateId;
        private readonly string _paymentTemplateId;
        private readonly string _billReadyTemplateId;

        /// <summary>DLT caps each template variable at 30 characters; longer values are rejected.</summary>
        private const int MaxVariableLength = 30;

        public Msg91SmsService(HttpClient httpClient, IConfiguration configuration, ILogger<Msg91SmsService> logger)
        {
            _httpClient = httpClient;
            _logger = logger;
            _authKey = configuration["SmsSettings:AuthKey"] ?? string.Empty;
            _otpTemplateId = configuration["SmsSettings:OtpTemplateId"] ?? string.Empty;
            _orderOtpTemplateId = configuration["SmsSettings:OrderOtpTemplateId"] ?? string.Empty;
            _paymentTemplateId = configuration["SmsSettings:PaymentTemplateId"] ?? string.Empty;
            _billReadyTemplateId = configuration["SmsSettings:BillReadyTemplateId"] ?? string.Empty;
        }

        public Task<bool> SendOtpAsync(string phoneNumber, string otpCode, string? recipientName = null)
        {
            var recipient = new Dictionary<string, string>
            {
                ["mobiles"] = NormalizeMobile(phoneNumber),
                ["var1"] = string.IsNullOrWhiteSpace(recipientName) ? "User" : recipientName,
                ["var2"] = otpCode
            };

            return SendFlowAsync(_otpTemplateId, recipient, phoneNumber, "OTP");
        }

        public Task<bool> SendOrderOtpAsync(string phoneNumber, string orderNumber, string otpCode)
        {
            // DLT template 6a82c0b8...: "...for Order bearing ID ##var1## is ##var2##."
            // var1 = order number, var2 = the delivery OTP. The names must match the template
            // exactly - MSG91 silently substitutes an empty string for any key it does not know.
            var recipient = new Dictionary<string, string>
            {
                ["mobiles"] = NormalizeMobile(phoneNumber),
                ["var1"] = orderNumber ?? string.Empty,
                ["var2"] = otpCode ?? string.Empty
            };

            // Log the request shape (not the OTP value itself) so a future "OTP came through blank"
            // report can be checked against what we actually sent without re-deriving it from
            // the DB/App Insights traces by hand.
            _logger.LogInformation(
                "MSG91 request OrderOtp template={TemplateId} mobile={Mobile} orderId={OrderId} otpLength={OtpLength}",
                _orderOtpTemplateId, NormalizeMobile(phoneNumber), orderNumber, (otpCode ?? string.Empty).Length);

            return SendFlowAsync(_orderOtpTemplateId, recipient, phoneNumber, "OrderOtp");
        }

        public Task<bool> SendOrderDeliveredAsync(string phoneNumber, string customerName, string orderNumber, string storeName)
        {
            var recipient = new Dictionary<string, string>
            {
                ["mobiles"] = NormalizeMobile(phoneNumber),
                ["Name"] = string.IsNullOrWhiteSpace(customerName) ? "Customer" : customerName,
                ["Number"] = orderNumber ?? string.Empty,
                ["Retailer"] = storeName ?? string.Empty
            };

            return SendFlowAsync(_paymentTemplateId, recipient, phoneNumber, "OrderDelivered");
        }

        public Task<bool> SendBillReadyAsync(string phoneNumber, string customerName, decimal billAmount)
        {
            // Template PHARMAISH_BILL_PAYMENT_NOTIFICATION — MSG91 id 6aa6dcc62be02e22be0e6fa3,
            // DLT id 1777178923567134191:
            //   "Dear ##alp##, Your Pharmaish request bill of Rs. ##num## is ready to view. ..."
            // The keys must be exactly "alp" and "num" — MSG91 silently substitutes an empty string for
            // any key it does not know, so a misspelt key sends a blank without raising an error.
            var name = string.IsNullOrWhiteSpace(customerName) ? "Customer" : customerName.Trim();
            var recipient = new Dictionary<string, string>
            {
                ["mobiles"] = NormalizeMobile(phoneNumber),
                ["alp"] = name.Length > MaxVariableLength ? name[..MaxVariableLength] : name,
                // Plain digits and a decimal point: no currency symbol (the template already says "Rs.")
                // and no thousands separator, which a numeric DLT variable may reject.
                ["num"] = billAmount.ToString("0.00", System.Globalization.CultureInfo.InvariantCulture)
            };

            _logger.LogInformation(
                "MSG91 request BillReady template={TemplateId} mobile={Mobile} amount={Amount}",
                _billReadyTemplateId, NormalizeMobile(phoneNumber), recipient["num"]);

            return SendFlowAsync(_billReadyTemplateId, recipient, phoneNumber, "BillReady");
        }

        /// <summary>
        /// Posts a single-recipient MSG91 Flow request and interprets the response.
        /// </summary>
        private async Task<bool> SendFlowAsync(string templateId, Dictionary<string, string> recipient, string phoneNumber, string smsType)
        {
            if (string.IsNullOrWhiteSpace(_authKey) || string.IsNullOrWhiteSpace(templateId))
            {
                _logger.LogError("MSG91 {SmsType} SMS not configured: SmsSettings:AuthKey or the template id is missing.", smsType);
                return false;
            }

            var payload = new
            {
                template_id = templateId,
                recipients = new[] { recipient }
            };

            try
            {
                using var request = new HttpRequestMessage(HttpMethod.Post, FlowUrl)
                {
                    Content = JsonContent.Create(payload)
                };
                request.Headers.TryAddWithoutValidation("authkey", _authKey);
                request.Headers.TryAddWithoutValidation("accept", "application/json");

                using var response = await _httpClient.SendAsync(request);
                var body = await response.Content.ReadAsStringAsync();

                if (!response.IsSuccessStatusCode)
                {
                    _logger.LogError("MSG91 {SmsType} send failed for {PhoneNumber}. Status={Status}, Body={Body}",
                        smsType, phoneNumber, (int)response.StatusCode, body);
                    return false;
                }

                // MSG91 returns {"type":"success",...} on success, {"type":"error",...} otherwise — with HTTP 200 either way.
                var type = TryReadType(body);
                if (!string.Equals(type, "success", StringComparison.OrdinalIgnoreCase))
                {
                    _logger.LogError("MSG91 {SmsType} send returned non-success for {PhoneNumber}. Body={Body}", smsType, phoneNumber, body);
                    return false;
                }

                _logger.LogInformation("MSG91 {SmsType} SMS sent to {PhoneNumber}.", smsType, phoneNumber);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error sending MSG91 {SmsType} SMS to {PhoneNumber}.", smsType, phoneNumber);
                return false;
            }
        }

        private static string NormalizeMobile(string phoneNumber)
        {
            var digits = new string((phoneNumber ?? string.Empty).Where(char.IsDigit).ToArray());
            // Add the India country code if a bare 10-digit number was supplied.
            if (digits.Length == 10)
                digits = "91" + digits;
            return digits;
        }

        private static string? TryReadType(string body)
        {
            try
            {
                using var doc = JsonDocument.Parse(body);
                return doc.RootElement.TryGetProperty("type", out var t) ? t.GetString() : null;
            }
            catch
            {
                return null;
            }
        }
    }
}
