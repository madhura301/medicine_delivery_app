using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MediatR;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Features.RolePermissions.Commands.AddRolePermission;
using MedicineDelivery.Application.Features.RolePermissions.Commands.RemoveRolePermission;
using MedicineDelivery.Application.Features.RolePermissions.Queries.GetRolePermissions;
using System.Security.Claims;

namespace MedicineDelivery.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class RolePermissionsController : ControllerBase
    {
        private readonly IMediator _mediator;

        public RolePermissionsController(IMediator mediator)
        {
            _mediator = mediator;
        }

        [HttpGet("{roleId}")]
        [Authorize(Policy = "RequireManageRolePermission")]
        public async Task<IActionResult> GetRolePermissions(int roleId)
        {
            try
            {
                var query = new GetRolePermissionsQuery { RoleId = roleId };
                var result = await _mediator.Send(query);
                return Ok(result);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "An error occurred while retrieving role permissions." });
            }
        }

        [HttpPost("add")]
        [Authorize(Policy = "RequireManageRolePermission")]
        public async Task<IActionResult> AddRolePermission([FromBody] AddRolePermissionDto request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var currentUserId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                
                var command = new AddRolePermissionCommand
                {
                    RoleId = request.RoleId,
                    PermissionId = request.PermissionId,
                    IsActive = request.IsActive,
                    GrantedBy = currentUserId
                };

                var result = await _mediator.Send(command);
                return Ok(result);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "An error occurred while adding role permission." });
            }
        }

        [HttpPost("remove")]
        [Authorize(Policy = "RequireManageRolePermission")]
        public async Task<IActionResult> RemoveRolePermission([FromBody] RemoveRolePermissionDto request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var command = new RemoveRolePermissionCommand
                {
                    RoleId = request.RoleId,
                    PermissionId = request.PermissionId
                };

                var result = await _mediator.Send(command);
                return Ok(new { success = result, message = "Role permission removed successfully." });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "An error occurred while removing role permission." });
            }
        }
    }
}
