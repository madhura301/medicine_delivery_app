using MedicineDelivery.Application.DTOs;

namespace MedicineDelivery.Application.Interfaces
{
    /// <summary>
    /// Collects the chemist's one-time activation/onboarding fee (₹14,999 + GST) via a
    /// Razorpay Payment Link, and activates the store when the link is paid.
    /// </summary>
    public interface IChemistActivationService
    {
        /// <summary>
        /// Creates (or returns the pending) Razorpay Payment Link for the store's activation fee.
        /// </summary>
        Task<ChemistActivationResult> CreateActivationLinkAsync(Guid medicalStoreId, CancellationToken ct = default);

        /// <summary>
        /// Current activation status for the store (latest activation payment), together with a live
        /// reading from Razorpay. Any drift is corrected as a side effect, so a payment the webhook
        /// missed is picked up simply by opening the chemist's page.
        /// </summary>
        Task<ChemistActivationResult> GetActivationStatusAsync(Guid medicalStoreId, CancellationToken ct = default);

        /// <summary>
        /// Pulls the payment link's state from Razorpay and writes it to our record — the
        /// "Sync with database" action behind the console's activation box.
        /// </summary>
        Task<ChemistActivationResult> RefreshFromRazorpayAsync(Guid medicalStoreId, CancellationToken ct = default);

        /// <summary>
        /// Marks the activation paid (from the Razorpay <c>payment_link.paid</c> webhook) and
        /// stamps <c>MedicalStore.ActivatedOn</c>. Returns true if a matching record was updated.
        /// </summary>
        Task<bool> MarkPaidFromWebhookAsync(string paymentLinkId, string? paymentId, CancellationToken ct = default);
    }
}
