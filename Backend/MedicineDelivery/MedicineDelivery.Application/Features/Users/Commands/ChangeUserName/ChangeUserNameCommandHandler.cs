using MediatR;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Domain.Interfaces;

namespace MedicineDelivery.Application.Features.Users.Commands.ChangeUserName
{
    /// <summary>
    /// Renames a login and keeps the owning profile's mobile number in step.
    ///
    /// A username in this system IS a mobile number, and each role's profile table carries its own
    /// MobileNumber column. Updating only the Identity record would leave a user logging in with one
    /// number while every screen, SMS and invoice showed another - so both move together here.
    /// </summary>
    public class ChangeUserNameCommandHandler : IRequestHandler<ChangeUserNameCommand, UserAccountUpdateResultDto>
    {
        private readonly IUserManager _userManager;
        private readonly IUnitOfWork _unitOfWork;

        public ChangeUserNameCommandHandler(IUserManager userManager, IUnitOfWork unitOfWork)
        {
            _userManager = userManager;
            _unitOfWork = unitOfWork;
        }

        public async Task<UserAccountUpdateResultDto> Handle(ChangeUserNameCommand request, CancellationToken cancellationToken)
        {
            var newUserName = (request.NewUserName ?? string.Empty).Trim();

            var user = await _userManager.FindByIdAsync(request.UserId);
            if (user == null)
            {
                return Fail("User not found.");
            }

            if (string.Equals(user.UserName, newUserName, StringComparison.Ordinal))
            {
                return Fail("The new username is the same as the current one.");
            }

            // Uniqueness must be checked the same way registration checks it, or a rename could
            // create a number that blocks a later sign-up (or collides with an existing login).
            var byName = await _userManager.FindByUserNameAsync(newUserName);
            var byPhone = await _userManager.FindByPhoneNumberAsync(newUserName);
            if (byName != null || byPhone != null)
            {
                return Fail("A user with this mobile number already exists.");
            }

            var result = await _userManager.ChangeUserNameAsync(request.UserId, newUserName);
            if (!result.Succeeded)
            {
                return new UserAccountUpdateResultDto
                {
                    Success = false,
                    Message = "Failed to change the username.",
                    Errors = result.Errors.Select(e => e.Description).ToList()
                };
            }

            var profileUpdated = await SyncProfileMobileNumberAsync(request.UserId, newUserName);

            return new UserAccountUpdateResultDto
            {
                Success = true,
                Message = "Username updated successfully.",
                UserName = newUserName,
                ProfileUpdated = profileUpdated
            };
        }

        /// <summary>
        /// Finds whichever role profile owns this user and updates its MobileNumber.
        /// Returns the profile type that was updated, or null when the user has no profile row
        /// (for example a bare Admin account).
        /// </summary>
        private async Task<string?> SyncProfileMobileNumberAsync(string userId, string newNumber)
        {
            var customer = await _unitOfWork.Customers.FirstOrDefaultAsync(c => c.UserId == userId);
            if (customer != null)
            {
                customer.MobileNumber = newNumber;
                _unitOfWork.Customers.Update(customer);
                await _unitOfWork.SaveChangesAsync();
                return "Customer";
            }

            var store = await _unitOfWork.MedicalStores.FirstOrDefaultAsync(s => s.UserId == userId);
            if (store != null)
            {
                store.MobileNumber = newNumber;
                _unitOfWork.MedicalStores.Update(store);
                await _unitOfWork.SaveChangesAsync();
                return "MedicalStore";
            }

            var delivery = await _unitOfWork.Deliveries.FirstOrDefaultAsync(d => d.UserId == userId);
            if (delivery != null)
            {
                delivery.MobileNumber = newNumber;
                _unitOfWork.Deliveries.Update(delivery);
                await _unitOfWork.SaveChangesAsync();
                return "Delivery";
            }

            var manager = await _unitOfWork.Managers.FirstOrDefaultAsync(m => m.UserId == userId);
            if (manager != null)
            {
                manager.MobileNumber = newNumber;
                _unitOfWork.Managers.Update(manager);
                await _unitOfWork.SaveChangesAsync();
                return "Manager";
            }

            var support = await _unitOfWork.CustomerSupports.FirstOrDefaultAsync(cs => cs.UserId == userId);
            if (support != null)
            {
                support.MobileNumber = newNumber;
                _unitOfWork.CustomerSupports.Update(support);
                await _unitOfWork.SaveChangesAsync();
                return "CustomerSupport";
            }

            return null;
        }

        private static UserAccountUpdateResultDto Fail(string message) => new()
        {
            Success = false,
            Message = message,
            Errors = new List<string> { message }
        };
    }
}
