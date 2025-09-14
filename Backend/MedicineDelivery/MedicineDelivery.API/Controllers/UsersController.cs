using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MediatR;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Features.Users.Commands.CreateUser;
using MedicineDelivery.Application.Features.Users.Queries.GetUsers;

namespace MedicineDelivery.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class UsersController : ControllerBase
    {
        private readonly IMediator _mediator;

        public UsersController(IMediator mediator)
        {
            _mediator = mediator;
        }

        [HttpGet]
        [Authorize(Policy = "RequireReadUsersPermission")]
        public async Task<IActionResult> GetUsers()
        {
            var query = new GetUsersQuery();
            var users = await _mediator.Send(query);
            return Ok(users);
        }

        [HttpPost]
        [Authorize(Policy = "RequireCreateUsersPermission")]
        public async Task<IActionResult> CreateUser([FromBody] CreateUserDto request)
        {
            var command = new CreateUserCommand { User = request };
            var user = await _mediator.Send(command);
            return CreatedAtAction(nameof(GetUsers), new { id = user.Id }, user);
        }
    }
}