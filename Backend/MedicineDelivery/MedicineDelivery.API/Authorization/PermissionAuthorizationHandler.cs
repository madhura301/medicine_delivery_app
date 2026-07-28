using System.Collections.Generic;
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
        private readonly ILogger<PermissionAuthorizationHandler> _logger;

        public PermissionAuthorizationHandler(IRoleService roleService, ILogger<PermissionAuthorizationHandler> logger)
        {
            _roleService = roleService;
            _logger = logger;
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
                _logger.LogWarning("Authorization failed: no user ID found in claims for permission '{Permission}'", requirement.Permission);
                context.Fail();
                return;
            }

            try
            {
                var hasPermission = false;
                foreach (var permission in requirement.Permissions)
                {
                    if (await _roleService.HasPermissionAsync(userId, permission))
                    {
                        hasPermission = true;
                        break;
                    }
                }

                if (hasPermission)
                {
                    _logger.LogDebug("Authorization succeeded: UserId {UserId}, Permission '{Permission}'", userId, requirement.Permission);
                    context.Succeed(requirement);
                }
                else
                {
                    _logger.LogWarning("Authorization denied: UserId {UserId} lacks permission '{Permission}'", userId, requirement.Permission);
                    context.Fail();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Authorization error checking permission '{Permission}' for UserId {UserId}", requirement.Permission, userId);
                context.Fail();
            }
        }
    }

    public class PermissionRequirement : IAuthorizationRequirement
    {
        /// <summary>The user must hold AT LEAST ONE of these permissions.</summary>
        public IReadOnlyList<string> Permissions { get; }

        /// <summary>
        /// Requires the user to have at least one of the given permissions. Pass a
        /// single permission for the common case, or several for "any of" access
        /// (e.g. a dual-use endpoint readable with either CustomerRead or AllCustomerRead).
        /// </summary>
        public PermissionRequirement(params string[] permissions)
        {
            Permissions = permissions;
        }

        /// <summary>Human-readable description of the accepted permissions (for logging).</summary>
        public string Permission => string.Join(" or ", Permissions);
    }

    public static class PermissionAuthorizationExtensions
    {
        public static AuthorizationPolicyBuilder RequirePermission(this AuthorizationPolicyBuilder builder, string permission)
        {
            return builder.AddRequirements(new PermissionRequirement(permission));
        }
    }
}
