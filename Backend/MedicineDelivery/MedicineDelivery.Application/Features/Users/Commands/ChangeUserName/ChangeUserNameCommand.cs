using MediatR;
using MedicineDelivery.Application.DTOs;

namespace MedicineDelivery.Application.Features.Users.Commands.ChangeUserName
{
    /// <summary>
    /// Administrative rename of a user's login. Because a username IS a mobile number here, this
    /// also keeps the owning profile record's MobileNumber in step.
    /// </summary>
    public class ChangeUserNameCommand : IRequest<UserAccountUpdateResultDto>
    {
        public string UserId { get; set; } = string.Empty;
        public string NewUserName { get; set; } = string.Empty;
    }
}
