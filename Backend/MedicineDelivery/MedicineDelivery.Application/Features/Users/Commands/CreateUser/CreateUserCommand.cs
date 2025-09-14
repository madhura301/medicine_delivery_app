using MediatR;
using MedicineDelivery.Application.DTOs;

namespace MedicineDelivery.Application.Features.Users.Commands.CreateUser
{
    public class CreateUserCommand : IRequest<UserDto>
    {
        public CreateUserDto User { get; set; } = new();
    }
}
