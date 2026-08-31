using MediatR;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Domain.Interfaces;

namespace MedicineDelivery.Application.Features.Users.Commands.AdminResetPassword
{
    public class AdminResetPasswordCommandHandler : IRequestHandler<AdminResetPasswordCommand, UserAccountUpdateResultDto>
    {
        private readonly IUserManager _userManager;

        public AdminResetPasswordCommandHandler(IUserManager userManager)
        {
            _userManager = userManager;
        }

        public async Task<UserAccountUpdateResultDto> Handle(AdminResetPasswordCommand request, CancellationToken cancellationToken)
        {
            var user = await _userManager.FindByIdAsync(request.UserId);
            if (user == null)
            {
                return new UserAccountUpdateResultDto
                {
                    Success = false,
                    Message = "User not found.",
                    Errors = new List<string> { "User not found." }
                };
            }

            // Identity's own validators (length, complexity) run inside this call, so a weak
            // password is rejected here rather than being silently accepted.
            var result = await _userManager.AdminResetPasswordAsync(request.UserId, request.NewPassword);
            if (!result.Succeeded)
            {
                return new UserAccountUpdateResultDto
                {
                    Success = false,
                    Message = "Failed to reset the password.",
                    Errors = result.Errors.Select(e => e.Description).ToList()
                };
            }

            return new UserAccountUpdateResultDto
            {
                Success = true,
                Message = "Password reset successfully. The user's existing sessions have been signed out.",
                UserName = user.UserName
            };
        }
    }
}
