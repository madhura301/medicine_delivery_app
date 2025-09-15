using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MediatR;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Features.Users.Commands.CreateUser;
using MedicineDelivery.Application.Features.Users.Commands.CreateUserWithRole;
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

        [HttpPost("create-with-role")]
        [Authorize(Policy = "RequireAdminCreateUsersPermission")]
        public async Task<IActionResult> CreateUserWithRole([FromBody] CreateUserWithRoleDto request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var command = new CreateUserWithRoleCommand
                {
                    Email = request.Email,
                    Password = request.Password,
                    FirstName = request.FirstName,
                    LastName = request.LastName,
                    RoleId = request.RoleId,
                    PhoneNumber = request.PhoneNumber,
                    EmailConfirmed = request.EmailConfirmed,
                    IsActive = request.IsActive
                };

                var user = await _mediator.Send(command);
                return CreatedAtAction(nameof(GetUsers), new { id = user.Id }, user);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "An error occurred while creating the user." });
            }
        }
    }
}