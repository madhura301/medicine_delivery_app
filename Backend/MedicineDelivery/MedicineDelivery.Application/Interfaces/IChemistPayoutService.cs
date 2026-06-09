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
    }
}
