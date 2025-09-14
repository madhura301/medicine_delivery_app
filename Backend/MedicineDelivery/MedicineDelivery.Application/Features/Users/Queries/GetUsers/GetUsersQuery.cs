using MediatR;
using MedicineDelivery.Application.DTOs;

namespace MedicineDelivery.Application.Features.Users.Queries.GetUsers
{
    public class GetUsersQuery : IRequest<List<UserDto>>
    {
    }
}
