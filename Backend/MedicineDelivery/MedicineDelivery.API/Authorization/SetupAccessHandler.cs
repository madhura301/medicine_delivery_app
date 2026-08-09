using System.Security.Cryptography;
using System.Text;
using Microsoft.AspNetCore.Authorization;

namespace MedicineDelivery.API.Authorization
{
    /// <summary>
    /// Requirement guarding the seeding endpoints (<c>/api/setup/*</c>). These create roles,
    /// permissions and privileged users, so they must never be anonymously callable in a
    /// deployed environment.
    /// </summary>
    public class SetupAccessRequirement : IAuthorizationRequirement
    {
    }

    /// <summary>
    /// Grants access to the setup endpoints when EITHER:
    /// <list type="bullet">
    ///   <item>the caller presents a valid <c>X-Setup-Token</c> matching <c>Setup:AccessToken</c>
    ///         (used by CI/seeding automation), OR</item>
    ///   <item>the caller is an authenticated Admin.</item>
    /// </list>
    /// Fails CLOSED: if no token is configured, access is denied outside Development. This is a
    /// deliberate reversal of the previous behaviour, where every setup endpoint was
    /// <c>[AllowAnonymous]</c> — including one that creates an Admin user with a hardcoded password.
    /// </summary>
    public class SetupAccessHandler : AuthorizationHandler<SetupAccessRequirement>
    {
        private const string TokenHeader = "X-Setup-Token";

        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly IConfiguration _configuration;
        private readonly IWebHostEnvironment _environment;
        private readonly ILogger<SetupAccessHandler> _logger;

        public SetupAccessHandler(
            IHttpContextAccessor httpContextAccessor,
            IConfiguration configuration,
            IWebHostEnvironment environment,
            ILogger<SetupAccessHandler> logger)
        {
            _httpContextAccessor = httpContextAccessor;
            _configuration = configuration;
            _environment = environment;
            _logger = logger;
        }

        protected override Task HandleRequirementAsync(
            AuthorizationHandlerContext context,
            SetupAccessRequirement requirement)
        {
            // 1) An authenticated Admin may always run setup.
            if (context.User?.Identity?.IsAuthenticated == true && context.User.IsInRole("Admin"))
            {
                context.Succeed(requirement);
                return Task.CompletedTask;
            }

            var configuredToken = _configuration["Setup:AccessToken"];

            // 2) Automation may present the shared setup token.
            if (!string.IsNullOrWhiteSpace(configuredToken))
            {
                var presented = _httpContextAccessor.HttpContext?.Request.Headers[TokenHeader].FirstOrDefault();
                if (!string.IsNullOrEmpty(presented) && FixedTimeEquals(presented, configuredToken))
                {
                    context.Succeed(requirement);
                    return Task.CompletedTask;
                }

                _logger.LogWarning("Setup endpoint denied: missing or invalid {Header}.", TokenHeader);
                return Task.CompletedTask;
            }

            // 3) No token configured — allow only in Development, otherwise fail closed.
            if (_environment.IsDevelopment())
            {
                _logger.LogWarning("Setup endpoint allowed without a token because the environment is Development.");
                context.Succeed(requirement);
                return Task.CompletedTask;
            }

            _logger.LogWarning(
                "Setup endpoint denied: Setup:AccessToken is not configured and the environment is {Environment}.",
                _environment.EnvironmentName);
            return Task.CompletedTask;
        }

        private static bool FixedTimeEquals(string a, string b)
        {
            var bytesA = Encoding.UTF8.GetBytes(a);
            var bytesB = Encoding.UTF8.GetBytes(b);
            return bytesA.Length == bytesB.Length && CryptographicOperations.FixedTimeEquals(bytesA, bytesB);
        }
    }
}
