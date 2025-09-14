using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using MedicineDelivery.API.Models;
using MedicineDelivery.API.Services;
using MedicineDelivery.Domain.Interfaces;

namespace MedicineDelivery.API.Authorization
{
    public class PermissionAuthorizationHandler : AuthorizationHandler<PermissionRequirement>
    {
        private readonly IRoleService _roleService;

        public PermissionAuthorizationHandler(IRoleService roleService)
        {
            _roleService = roleService;
        }

        protected override async Task HandleRequirementAsync(
            AuthorizationHandlerContext context,
            PermissionRequirement requirement)
        {
            var userId = context.User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                // Try alternative claim types
                userId = context.User.FindFirst("sub")?.Value;
                if (userId == null)
                {
                    userId = context.User.FindFirst("nameid")?.Value;
                }
            }
            
            if (userId == null)
            {
                context.Fail();
                return;
            }

            var hasPermission = await _roleService.HasPermissionAsync(userId, requirement.Permission);
            
            if (hasPermission)
            {
                context.Succeed(requirement);
            }
            else
            {
                context.Fail();
            }
        }
    }

    public class PermissionRequirement : IAuthorizationRequirement
    {
        public string Permission { get; }

        public PermissionRequirement(string permission)
        {
            Permission = permission;
        }
    }

    public static class PermissionAuthorizationExtensions
    {
        public static AuthorizationPolicyBuilder RequirePermission(this AuthorizationPolicyBuilder builder, string permission)
        {
            return builder.AddRequirements(new PermissionRequirement(permission));
        }
    }
}
