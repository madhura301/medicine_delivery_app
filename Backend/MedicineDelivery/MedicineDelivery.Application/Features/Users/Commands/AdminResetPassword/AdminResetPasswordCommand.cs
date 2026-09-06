using MediatR;
using MedicineDelivery.Application.DTOs;

namespace MedicineDelivery.Application.Features.Users.Commands.AdminResetPassword
{
    /// <summary>
    /// Sets a user's password without requiring their current one. Staff-operated, for users who
    /// cannot complete the self-service reset themselves.
    /// </summary>
    public class AdminResetPasswordCommand : IRequest<UserAccountUpdateResultDto>
    {
        public string UserId { get; set; } = string.Empty;
        public string NewPassword { get; set; } = string.Empty;
    }
}
