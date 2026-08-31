using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MediatR;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Features.Users.Commands.CreateUser;
using MedicineDelivery.Application.Features.Users.Commands.CreateUserWithRole;
using MedicineDelivery.Application.Features.Users.Commands.ChangeUserName;
using MedicineDelivery.Application.Features.Users.Commands.AdminResetPassword;
using MedicineDelivery.Application.Features.Users.Commands.RegisterUser;
using MedicineDelivery.Application.Features.Users.Queries.GetUsers;

namespace MedicineDelivery.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class UsersController : ControllerBase
    {
        private readonly IMediator _mediator;
        private readonly ILogger<UsersController> _logger;

        public UsersController(IMediator mediator, ILogger<UsersController> logger)
        {
            _mediator = mediator;
            _logger = logger;
        }

        [HttpGet]
        [Authorize(Policy = "RequireReadUsersPermission")]
        public async Task<IActionResult> GetUsers()
        {
            try
            {
                var query = new GetUsersQuery();
                var users = await _mediator.Send(query);
                return Ok(users);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetUsers");
                return StatusCode(500, new { error = "An error occurred while retrieving users." });
            }
        }

        [HttpPost]
        [Authorize(Policy = "RequireCreateUsersPermission")]
        public async Task<IActionResult> CreateUser([FromBody] CreateUserDto request)
        {
            try
            {
                var command = new CreateUserCommand { User = request };
                var user = await _mediator.Send(command);
                return CreatedAtAction(nameof(GetUsers), new { id = user.Id }, user);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in CreateUser");
                return StatusCode(500, new { error = "An error occurred while creating the user." });
            }
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
                _logger.LogWarning(ex, "Invalid operation in CreateUserWithRole for {Email}", request.Email);
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in CreateUserWithRole for {Email}", request.Email);
                return StatusCode(500, new { error = "An error occurred while creating the user." });
            }
        }

        /// <summary>
        /// Administrative rename of a user's login. A username is the user's mobile number, so this
        /// also updates the owning profile record's MobileNumber and signs the user out everywhere.
        /// </summary>
        [HttpPut("{userId}/username")]
        [Authorize(Policy = "RequireManagerUpdateUsersPermission")]
        public async Task<IActionResult> ChangeUserName(string userId, [FromBody] ChangeUserNameDto request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var result = await _mediator.Send(new ChangeUserNameCommand
                {
                    UserId = userId,
                    NewUserName = request.NewUserName
                });

                if (result.Success)
                {
                    _logger.LogInformation("Username changed for {UserId} (profile synced: {Profile})",
                        userId, result.ProfileUpdated ?? "none");
                    return Ok(result);
                }

                // A taken number is a conflict, not a malformed request - let the UI tell them apart.
                if (result.Message.Contains("already exists", StringComparison.OrdinalIgnoreCase))
                    return Conflict(result);

                if (result.Message.Contains("not found", StringComparison.OrdinalIgnoreCase))
                    return NotFound(result);

                return BadRequest(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in ChangeUserName for {UserId}", userId);
                return StatusCode(500, new { error = "An error occurred while changing the username." });
            }
        }

        /// <summary>
        /// Administrative password reset. Does not require the user's current password, and signs
        /// the user out of existing sessions.
        /// </summary>
        [HttpPost("{userId}/reset-password")]
        [Authorize(Policy = "RequireManagerUpdateUsersPermission")]
        public async Task<IActionResult> AdminResetPassword(string userId, [FromBody] AdminResetPasswordDto request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var result = await _mediator.Send(new AdminResetPasswordCommand
                {
                    UserId = userId,
                    NewPassword = request.NewPassword
                });

                if (result.Success)
                {
                    // Never log the password value itself.
                    _logger.LogInformation("Password reset by administrator for {UserId}", userId);
                    return Ok(result);
                }

                if (result.Message.Contains("not found", StringComparison.OrdinalIgnoreCase))
                    return NotFound(result);

                return BadRequest(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in AdminResetPassword for {UserId}", userId);
                return StatusCode(500, new { error = "An error occurred while resetting the password." });
            }
        }

        [HttpPost("register")]
        [AllowAnonymous]
        public async Task<IActionResult> RegisterUser([FromBody] UserRegistrationDto request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var command = new RegisterUserCommand
                {
                    Email = request.Email,
                    Password = request.Password,
                    FirstName = request.FirstName,
                    LastName = request.LastName,
                    PhoneNumber = request.PhoneNumber
                };

                var user = await _mediator.Send(command);
                return CreatedAtAction(nameof(GetUsers), new { id = user.Id }, user);
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogWarning(ex, "Invalid operation in RegisterUser for {Email}", request.Email);
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in RegisterUser for {Email}", request.Email);
                return StatusCode(500, new { error = "An error occurred while registering the user." });
            }
        }
    }
}
