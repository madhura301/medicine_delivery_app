using MedicineDelivery.Application.DTOs;

namespace MedicineDelivery.Application.Interfaces
{
    /// <summary>
    /// Onboards chemists (medical stores) as Razorpay Route linked accounts and
    /// tracks their payout/onboarding status. Prerequisite for splitting order
    /// payments to the chemist (Phase 2).
    /// </summary>
    public interface IChemistPayoutService
    {
        /// <summary>
        /// Creates (or resumes) the Razorpay linked account for the given store using
        /// the supplied bank details + the store's stored KYC, and persists the result.
        /// </summary>
        Task<ChemistPayoutResult> OnboardAsync(Guid medicalStoreId, OnboardChemistPayoutDto request, CancellationToken ct = default);

        /// <summary>Returns the current payout/onboarding status for a store (bank number masked).</summary>
        Task<ChemistPayoutResult> GetStatusAsync(Guid medicalStoreId, CancellationToken ct = default);

        /// <summary>Updates the chemist's bank details and re-submits the Route product configuration.</summary>
        Task<ChemistPayoutResult> UpdateBankDetailsAsync(Guid medicalStoreId, UpdateChemistBankDto request, CancellationToken ct = default);

        /// <summary>
        /// Pulls every payout account still awaiting activation (Pending / NeedsClarification),
        /// fetches its live status from Razorpay, and writes any changes back to the database.
        /// </summary>
        Task<ChemistPayoutRefreshResultDto> RefreshPendingStatusesAsync(CancellationToken ct = default);

        /// <summary>
        /// Refreshes a single chemist's payout status from Razorpay and returns the updated status.
        /// <paramref name="chemistId"/> may be the MedicalStoreId or the chemist's UserId.
        /// </summary>
        Task<ChemistPayoutResult> RefreshStatusAsync(Guid chemistId, CancellationToken ct = default);

        /// <summary>
        /// Applies a Razorpay Route account webhook event to the payout account identified by its
        /// linked account id (acc_XXXX). Maps the event to the onboarding status and persists it.
        /// Returns false if no matching payout account exists.
        /// </summary>
        Task<bool> ApplyAccountWebhookAsync(string razorpayLinkedAccountId, string eventType, CancellationToken ct = default);
    }
}
