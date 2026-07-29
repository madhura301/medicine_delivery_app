using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System.Text;
using MedicineDelivery.Infrastructure.Data;
using MedicineDelivery.Infrastructure.Repositories;
using MedicineDelivery.Infrastructure.Services;
using MedicineDelivery.Application.Mappings;
using MedicineDelivery.Application.Features.Users.Commands.CreateUser;
using MedicineDelivery.Application.Features.Users.Queries.GetUsers;
using MedicineDelivery.API.Authorization;
using MedicineDelivery.API.Services;
using MedicineDelivery.API.Middleware;
using System.Reflection;
using Microsoft.AspNetCore.Authorization;
using Serilog;
using Microsoft.ApplicationInsights.Extensibility;
using Microsoft.AspNetCore.DataProtection;
using Azure.Storage.Blobs;
using System.Threading.RateLimiting;
using Microsoft.AspNetCore.RateLimiting;
using System.Security.Claims;

// Bootstrap logger (before config is available) so early log messages are not lost
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Information()
    .WriteTo.Console()
    .CreateLogger();

try
{
    Log.Information("Starting Medicine Delivery API application");

    var builder = WebApplication.CreateBuilder(args);

    // Application Insights: enabled only when a connection string is supplied
    // (e.g. env var ApplicationInsights__ConnectionString on Azure). Locally it
    // stays off, so the console/file sinks behave exactly as before.
    var appInsightsConnectionString = builder.Configuration["ApplicationInsights:ConnectionString"];
    var appInsightsEnabled = !string.IsNullOrWhiteSpace(appInsightsConnectionString);

    // Identifies this deployment in shared telemetry (test vs production vs local).
    // Set via env vars DeploymentEnvironment / CloudRoleName on Azure Container Apps.
    var deploymentEnvironment = builder.Configuration["DeploymentEnvironment"] ?? "Local";
    var cloudRoleName = builder.Configuration["CloudRoleName"] ?? $"pharmaish-api-{deploymentEnvironment.ToLowerInvariant()}";

    if (appInsightsEnabled)
    {
        // Captures requests, dependencies (DB/HTTP), and exceptions automatically.
        builder.Services.AddApplicationInsightsTelemetry(options =>
        {
            options.ConnectionString = appInsightsConnectionString;
        });

        // Tag auto-collected telemetry (requests/dependencies/exceptions).
        builder.Services.AddSingleton<ITelemetryInitializer>(
            new MedicineDelivery.API.Telemetry.CloudRoleNameInitializer(cloudRoleName, deploymentEnvironment));
    }

    // Replace bootstrap logger with fully configured logger from appsettings
    var loggerConfiguration = new LoggerConfiguration()
        .ReadFrom.Configuration(builder.Configuration)
        // Also stamp console/file logs so local and container logs are self-describing.
        .Enrich.WithProperty("DeploymentEnvironment", deploymentEnvironment);

    // Ship structured logs to Application Insights when configured.
    if (appInsightsEnabled)
    {
        // The Serilog sink uses its OWN TelemetryConfiguration, so the initializer must be
        // registered here too — DI registration alone would not tag Serilog traces.
        var serilogTelemetryConfig = new TelemetryConfiguration { ConnectionString = appInsightsConnectionString };
        serilogTelemetryConfig.TelemetryInitializers.Add(
            new MedicineDelivery.API.Telemetry.CloudRoleNameInitializer(cloudRoleName, deploymentEnvironment));

        loggerConfiguration.WriteTo.ApplicationInsights(
            serilogTelemetryConfig,
            TelemetryConverter.Traces);
    }

    Log.Logger = loggerConfiguration.CreateLogger();

    // Add Serilog as the logging provider
    builder.Host.UseSerilog();

    // Persist Data Protection keys to Azure Blob storage so they survive container
    // restarts (the container filesystem is ephemeral). Without this, ASP.NET Core
    // regenerates keys on every restart, invalidating anything encrypted with them.
    // Reuses the existing FileStorage:Azure connection string when available.
    var dpConnectionString = builder.Configuration["FileStorage:Azure:ConnectionString"];
    if (!string.IsNullOrWhiteSpace(dpConnectionString) &&
        !dpConnectionString.StartsWith("SET_VIA_ENV", StringComparison.OrdinalIgnoreCase))
    {
        const string dpContainerName = "dataprotection";
        const string dpBlobName = "keys.xml";

        // Ensure the container exists before Data Protection tries to read/write the blob.
        var dpContainerClient = new BlobContainerClient(dpConnectionString, dpContainerName);
        dpContainerClient.CreateIfNotExists();

        builder.Services.AddDataProtection()
            .SetApplicationName("Pharmaish.API")
            .PersistKeysToAzureBlobStorage(dpContainerClient.GetBlobClient(dpBlobName));

        Log.Information("Data Protection keys persisted to Azure Blob container '{Container}'.", dpContainerName);
    }
    else
    {
        Log.Warning("Data Protection: no Azure blob connection string; keys will use the default ephemeral store.");
    }

// Rate limiting (security finding C-04). Authentication endpoints previously had no
// throttling AND no lockout, allowing unlimited credential brute-force. "auth" is a strict
// per-IP limit for login/OTP/password-reset; "global" is a safety net for everything else.
builder.Services.AddRateLimiter(options =>
{
    options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;

    options.AddPolicy("auth", httpContext =>
        RateLimitPartition.GetFixedWindowLimiter(
            partitionKey: httpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown",
            factory: _ => new FixedWindowRateLimiterOptions
            {
                // Tunable per environment: RateLimiting:AuthPermitPerMinute (default 30).
                // Defence-in-depth alongside account lockout (5 failed logins -> 5 min lock).
                PermitLimit = builder.Configuration.GetValue<int?>("RateLimiting:AuthPermitPerMinute") ?? 30,
                Window = TimeSpan.FromMinutes(1),
                QueueLimit = 0
            }));

    // M-03 / H-06: the delivery OTP is only 4 digits (~9,000 values) and the completion endpoint
    // has no attempt counter, so without throttling it can be brute-forced in seconds. Partition by
    // the authenticated USER (the endpoint requires auth) rather than IP: that is attacker-specific
    // and unaffected by carrier NAT, consistent with the reasoning below.
    options.AddPolicy("otp-verify", httpContext =>
        RateLimitPartition.GetFixedWindowLimiter(
            partitionKey: httpContext.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value
                          ?? httpContext.Connection.RemoteIpAddress?.ToString()
                          ?? "unknown",
            factory: _ => new FixedWindowRateLimiterOptions
            {
                // A human entering a code needs a handful of tries; a brute-forcer needs thousands.
                PermitLimit = builder.Configuration.GetValue<int?>("RateLimiting:OtpVerifyPermitPerMinute") ?? 5,
                Window = TimeSpan.FromMinutes(1),
                QueueLimit = 0
            }));

    // M-03: endpoints that send an SMS cost real money per call (MSG91). The 'auth' policy alone
    // would still permit ~43,000 messages/day from one IP. Cap SMS-triggering requests far tighter.
    options.AddPolicy("sms", httpContext =>
        RateLimitPartition.GetFixedWindowLimiter(
            partitionKey: httpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown",
            factory: _ => new FixedWindowRateLimiterOptions
            {
                PermitLimit = builder.Configuration.GetValue<int?>("RateLimiting:SmsPermitPerWindow") ?? 3,
                Window = TimeSpan.FromMinutes(builder.Configuration.GetValue<int?>("RateLimiting:SmsWindowMinutes") ?? 5),
                QueueLimit = 0
            }));

    // NOTE: deliberately NO global limiter. Mobile carriers/corporate networks NAT many
    // users behind a single IP, so a global per-IP cap blocks legitimate traffic while adding
    // little security value. Brute-force protection comes from the strict 'auth' policy below
    // plus per-ACCOUNT lockout (5 failures -> 5 min), which is attacker-specific rather than IP-wide.
});

// CORS (security finding M-01). The API previously ran AllowAnyOrigin(), letting any website on the
// internet call it from a victim's browser and read the responses. Origins are now an explicit
// allow-list supplied per environment via Cors:AllowedOrigins (env var Cors__AllowedOrigins__0, ...,
// or a single comma/semicolon-separated Cors__AllowedOrigins value).
//
// Note: CORS is a *browser* control — it does not affect the Flutter mobile app, which is unaffected
// by this change. Only browser-based callers (the React web app, Swagger UI on another host) matter.
// AllowCredentials is deliberately NOT enabled: auth uses a Bearer header, not cookies.
const string CorsPolicyName = "PharmaishCors";

// Accept EITHER the indexed form (Cors__AllowedOrigins__0, __1, ... / a JSON array) OR a single
// comma/semicolon-separated value, which is far easier to set as one env var. Read without the
// binder so a scalar value can never throw at startup.
var corsSection = builder.Configuration.GetSection("Cors:AllowedOrigins");
var configuredOrigins = corsSection.GetChildren().Any()
    ? corsSection.GetChildren().Select(c => c.Value ?? string.Empty).ToArray()
    : (corsSection.Value ?? string.Empty)
        .Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);

// Trailing slashes are a common copy/paste error and make the origin never match.
configuredOrigins = configuredOrigins
    .Select(o => o.TrimEnd('/'))
    .Where(o => !string.IsNullOrWhiteSpace(o) && !o.StartsWith("SET_VIA_ENV", StringComparison.OrdinalIgnoreCase))
    .Distinct(StringComparer.OrdinalIgnoreCase)
    .ToArray();

builder.Services.AddCors(options =>
{
    options.AddPolicy(CorsPolicyName, policy =>
    {
        if (configuredOrigins.Length > 0)
        {
            policy.WithOrigins(configuredOrigins).AllowAnyMethod().AllowAnyHeader();
        }
        else if (builder.Environment.IsDevelopment())
        {
            // Local convenience only: any localhost/127.0.0.1 port (Vite, CRA, Swagger).
            policy.SetIsOriginAllowed(origin =>
                    Uri.TryCreate(origin, UriKind.Absolute, out var u) &&
                    (u.IsLoopback || string.Equals(u.Host, "localhost", StringComparison.OrdinalIgnoreCase)))
                .AllowAnyMethod()
                .AllowAnyHeader();
        }
        // Otherwise: no origins allowed — fail closed. Same-origin callers (Swagger on the API host)
        // and non-browser clients (the mobile app, server-to-server, Razorpay webhooks) are unaffected.
    });
});

if (configuredOrigins.Length > 0)
    Log.Information("CORS restricted to {Count} configured origin(s).", configuredOrigins.Length);
else if (builder.Environment.IsDevelopment())
    Log.Warning("CORS: no Cors:AllowedOrigins configured; allowing localhost origins (Development only).");
else
    Log.Warning("CORS: no Cors:AllowedOrigins configured; all cross-origin browser requests will be blocked. " +
                "Set Cors__AllowedOrigins if a browser front-end needs access.");

// Upload limits (security finding M-08). Nothing capped multipart bodies, so the only ceiling was
// Kestrel's ~30 MB default — enough for cheap storage/bandwidth DoS, and far larger than any
// legitimate prescription photo or policy PDF. Per-endpoint [RequestSizeLimit] attributes tighten
// this further; services additionally validate size, extension and magic bytes.
var maxUploadBytes = builder.Configuration.GetValue<long?>("Uploads:MaxRequestBytes") ?? (12L * 1024 * 1024); // 12 MB

builder.Services.Configure<Microsoft.AspNetCore.Http.Features.FormOptions>(options =>
{
    options.MultipartBodyLengthLimit = maxUploadBytes;
});

builder.Services.Configure<Microsoft.AspNetCore.Server.Kestrel.Core.KestrelServerOptions>(options =>
{
    options.Limits.MaxRequestBodySize = maxUploadBytes;
});

// Add services to the container.
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.AllowTrailingCommas = true;
    });

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "MedicineDelivery API", Version = "v1" });
    
    // Add JWT authentication to Swagger
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme. Example: \"Authorization: Bearer {token}\"",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });
    
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            new string[] {}
        }
    });
});

// Add Entity Framework with configurable database provider
var databaseProvider = builder.Configuration["DatabaseProvider"];
var connectionString = databaseProvider switch
{
    "PostgreSQL" => builder.Configuration.GetConnectionString("PostgresConnection"),
    "SqlServer" => builder.Configuration.GetConnectionString("DefaultConnection"),
    _ => builder.Configuration.GetConnectionString("DefaultConnection")
};

builder.Services.AddDbContext<MedicineDelivery.Infrastructure.Data.ApplicationDbContext>((serviceProvider, options) =>
{
    switch (databaseProvider)
    {
        case "PostgreSQL":
            options.UseNpgsql(connectionString);
            break;
        case "SqlServer":
        default:
            options.UseNpgsql(connectionString);
            break;
    }
});

// Add Identity
builder.Services.AddIdentity<MedicineDelivery.Domain.Entities.ApplicationUser, IdentityRole>(options =>
{
    // Password settings
    options.Password.RequireDigit = true;
    options.Password.RequireLowercase = true;
    options.Password.RequireNonAlphanumeric = true;
    options.Password.RequireUppercase = true;
    options.Password.RequiredLength = 6;
    options.Password.RequiredUniqueChars = 1;

    // Lockout settings
    options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(5);
    options.Lockout.MaxFailedAccessAttempts = 5;
    options.Lockout.AllowedForNewUsers = true;

    // User settings
    options.User.AllowedUserNameCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._@+";
    options.User.RequireUniqueEmail = false;
})
.AddEntityFrameworkStores<MedicineDelivery.Infrastructure.Data.ApplicationDbContext>()
.AddDefaultTokenProviders();

// Add JWT Authentication
var jwtSettings = builder.Configuration.GetSection("JwtSettings");
var secretKey = jwtSettings["SecretKey"] ?? string.Empty;

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtSettings["Issuer"],
        ValidAudience = jwtSettings["Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey))
    };
});

// Add Authorization
builder.Services.AddAuthorization(options =>
{
    // Register permission-based policies
    // Seeding endpoints (/api/setup/*): authenticated Admin OR a valid X-Setup-Token.
    // Fails closed when no token is configured outside Development.
    options.AddPolicy("RequireSetupAccess", policy =>
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.SetupAccessRequirement()));

    options.AddPolicy("RequireReadUsersPermission", policy =>
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("ReadUsers")));
    
    options.AddPolicy("RequireCreateUsersPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("CreateUsers")));
    
    options.AddPolicy("RequireUpdateUsersPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("UpdateUsers")));
    
    options.AddPolicy("RequireDeleteUsersPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("DeleteUsers")));
    
    options.AddPolicy("RequireReadProductsPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("ReadProducts")));
    
    options.AddPolicy("RequireCreateProductsPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("CreateProducts")));
    
    options.AddPolicy("RequireUpdateProductsPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("UpdateProducts")));
    
    options.AddPolicy("RequireDeleteProductsPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("DeleteProducts")));
    
    options.AddPolicy("RequireOrderReadPermission", policy =>
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("ReadOrders")));
    
    options.AddPolicy("RequireOrderCreatePermission", policy =>
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("CreateOrders")));
    
    options.AddPolicy("RequireOrderUpdatePermission", policy =>
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("UpdateOrders")));
    
    options.AddPolicy("RequireOrderDeletePermission", policy =>
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("DeleteOrders")));

    options.AddPolicy("RequireOrderCancelPermission", policy =>
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("CancelOrders")));
    
    options.AddPolicy("RequireListAllOrdersPermission", policy =>
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("ListAllOrders")));
    
    // Admin User Management Policies
    options.AddPolicy("RequireAdminReadUsersPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("AdminReadUsers")));
    
    options.AddPolicy("RequireAdminCreateUsersPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("AdminCreateUsers")));
    
    options.AddPolicy("RequireAdminUpdateUsersPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("AdminUpdateUsers")));
    
    options.AddPolicy("RequireAdminDeleteUsersPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("AdminDeleteUsers")));
    
    // Manager User Management Policies
    options.AddPolicy("RequireManagerReadUsersPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("ManagerReadUsers")));
    
    options.AddPolicy("RequireManagerCreateUsersPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("ManagerCreateUsers")));
    
    options.AddPolicy("RequireManagerUpdateUsersPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("ManagerUpdateUsers")));
    
    options.AddPolicy("RequireManagerDeleteUsersPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("ManagerDeleteUsers")));
    
    // CustomerSupport User Management Policies
    options.AddPolicy("RequireCustomerSupportReadUsersPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("CustomerSupportReadUsers")));
    
    options.AddPolicy("RequireCustomerSupportCreateUsersPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("CustomerSupportCreateUsers")));
    
    options.AddPolicy("RequireCustomerSupportUpdateUsersPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("CustomerSupportUpdateUsers")));
    
    options.AddPolicy("RequireCustomerSupportDeleteUsersPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("CustomerSupportDeleteUsers")));
    
    // Chemist User Management Policies
    options.AddPolicy("RequireChemistReadUsersPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("ChemistReadUsers")));
    
    options.AddPolicy("RequireChemistCreateUsersPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("ChemistCreateUsers")));
    
    options.AddPolicy("RequireChemistUpdateUsersPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("ChemistUpdateUsers")));
    
    options.AddPolicy("RequireChemistDeleteUsersPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("ChemistDeleteUsers")));
    
    // Role Permission Management Policy
    options.AddPolicy("RequireManageRolePermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("ManageRolePermission")));
    
    // Chemist CRUD Policies
    options.AddPolicy("RequireChemistReadPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("ChemistRead")));
    
    options.AddPolicy("RequireChemistCreatePermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("ChemistCreate")));
    
    options.AddPolicy("RequireChemistUpdatePermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("ChemistUpdate")));
    
    options.AddPolicy("RequireChemistDeletePermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("ChemistDelete")));
    
    // CustomerSupport CRUD Policies
    options.AddPolicy("RequireCustomerSupportReadPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("CustomerSupportRead")));
    
    options.AddPolicy("RequireCustomerSupportCreatePermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("CustomerSupportCreate")));
    
    options.AddPolicy("RequireCustomerSupportUpdatePermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("CustomerSupportUpdate")));
    
    options.AddPolicy("RequireCustomerSupportDeletePermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("CustomerSupportDelete")));
    
    // Manager CRUD Policies
    options.AddPolicy("RequireManagerSupportReadPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("ManagerSupportRead")));
    
    options.AddPolicy("RequireManagerSupportCreatePermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("ManagerSupportCreate")));
    
    options.AddPolicy("RequireManagerSupportUpdatePermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("ManagerSupportUpdate")));
    
    options.AddPolicy("RequireManagerSupportDeletePermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("ManagerSupportDelete")));
    
    // Customer CRUD Policies (for own records only)
    options.AddPolicy("RequireCustomerReadPermission", policy =>
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("CustomerRead")));

    // Dual-use customer read (own OR any): customers read their own record (CustomerRead)
    // while staff (Support/Admin/Manager) look up any customer (AllCustomerRead).
    options.AddPolicy("RequireCustomerReadAnyPermission", policy =>
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("CustomerRead", "AllCustomerRead")));

    options.AddPolicy("RequireCustomerCreatePermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("CustomerCreate")));
    
    options.AddPolicy("RequireCustomerUpdatePermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("CustomerUpdate")));
    
    options.AddPolicy("RequireCustomerDeletePermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("CustomerDelete")));
    
    // All Customer CRUD Policies (for all customer records)
    options.AddPolicy("RequireAllCustomerReadPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("AllCustomerRead")));
    
    options.AddPolicy("RequireAllCustomerUpdatePermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("AllCustomerUpdate")));
    
    options.AddPolicy("RequireAllCustomerDeletePermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("AllCustomerDelete")));
    
    // Consent CRUD Policies
    options.AddPolicy("RequireReadConsentsPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("ReadConsents")));
    
    options.AddPolicy("RequireCreateConsentsPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("CreateConsents")));
    
    options.AddPolicy("RequireUpdateConsentsPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("UpdateConsents")));
    
    options.AddPolicy("RequireDeleteConsentsPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("DeleteConsents")));
    
    options.AddPolicy("RequireReadConsentLogsPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("ReadConsentLogs")));
    
    // Delivery CRUD Policies
    options.AddPolicy("RequireDeliveryReadPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("DeliveryRead")));
    
    options.AddPolicy("RequireDeliveryCreatePermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("DeliveryCreate")));
    
    options.AddPolicy("RequireDeliveryUpdatePermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("DeliveryUpdate")));
    
    options.AddPolicy("RequireDeliveryDeletePermission", policy =>
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("DeliveryDelete")));

    // M-07: uploading/replacing publicly served policy documents is an administrative action.
    options.AddPolicy("RequireManagePolicyDocumentsPermission", policy =>
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("ManagePolicyDocuments")));
});

// Register the permission authorization handler
builder.Services.AddScoped<MedicineDelivery.Application.Interfaces.IOrderAccessGuard, MedicineDelivery.Infrastructure.Services.OrderAccessGuard>();
builder.Services.AddScoped<IAuthorizationHandler, MedicineDelivery.API.Authorization.PermissionAuthorizationHandler>();
// Guards the /api/setup/* seeding endpoints (see SetupAccessHandler).
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<IAuthorizationHandler, MedicineDelivery.API.Authorization.SetupAccessHandler>();

// Add AutoMapper
builder.Services.AddAutoMapper(typeof(MappingProfile));

// Add MediatR
builder.Services.AddMediatR(cfg => cfg.RegisterServicesFromAssembly(typeof(CreateUserCommand).Assembly));

// Add custom services
builder.Services.AddScoped<MedicineDelivery.Domain.Interfaces.IUnitOfWork, UnitOfWork>();
builder.Services.AddScoped<MedicineDelivery.Domain.Interfaces.IAuthService, MedicineDelivery.API.Services.AuthService>();
builder.Services.AddScoped<MedicineDelivery.Domain.Interfaces.IRoleService, MedicineDelivery.Infrastructure.Services.RoleService>();
builder.Services.AddScoped<MedicineDelivery.Domain.Interfaces.IPermissionService, MedicineDelivery.Infrastructure.Services.PermissionService>();
builder.Services.AddScoped<MedicineDelivery.API.Services.IPermissionService, MedicineDelivery.API.Services.PermissionService>();
builder.Services.AddScoped<MedicineDelivery.Domain.Interfaces.IUserManager, MedicineDelivery.Infrastructure.Services.UserManagerService>();
builder.Services.AddScoped<MedicineDelivery.Application.Interfaces.IMedicalStoreService, MedicineDelivery.Infrastructure.Services.MedicalStoreService>();
builder.Services.AddScoped<MedicineDelivery.Application.Interfaces.ICustomerSupportService, MedicineDelivery.Infrastructure.Services.CustomerSupportService>();
builder.Services.AddScoped<MedicineDelivery.Application.Interfaces.IManagerService, MedicineDelivery.Infrastructure.Services.ManagerService>();
builder.Services.AddScoped<MedicineDelivery.Application.Interfaces.ICustomerService, MedicineDelivery.Infrastructure.Services.CustomerService>();
builder.Services.AddScoped<MedicineDelivery.Application.Interfaces.ICustomerAddressService, MedicineDelivery.Infrastructure.Services.CustomerAddressService>();
builder.Services.AddScoped<MedicineDelivery.Application.Interfaces.IDeliveryService, MedicineDelivery.Infrastructure.Services.DeliveryService>();
builder.Services.AddScoped<MedicineDelivery.Application.Interfaces.IServiceRegionService, MedicineDelivery.Infrastructure.Services.ServiceRegionService>();
builder.Services.AddScoped<MedicineDelivery.Application.Interfaces.IPhotoUploadService, MedicineDelivery.Infrastructure.Services.PhotoUploadService>();
// File storage: driven by FileStorage:Provider in appsettings.json ("Local" or "Azure")
var fileStorageProvider = builder.Configuration["FileStorage:Provider"] ?? "Local";
if (fileStorageProvider.Equals("Azure", StringComparison.OrdinalIgnoreCase))
{
    builder.Services.AddScoped<MedicineDelivery.Application.Interfaces.IFileStorageService, MedicineDelivery.Infrastructure.Services.AzureBlobStorageService>();
}
else
{
    builder.Services.AddScoped<MedicineDelivery.Application.Interfaces.IFileStorageService, MedicineDelivery.Infrastructure.Services.LocalFileStorageService>();
}
builder.Services.AddScoped<MedicineDelivery.Application.Interfaces.IPolicyDocumentService, MedicineDelivery.Infrastructure.Services.PolicyDocumentService>();
builder.Services.AddScoped<MedicineDelivery.Application.Interfaces.IPermissionCheckerService, MedicineDelivery.Infrastructure.Services.PermissionCheckerService>();
builder.Services.AddScoped<MedicineDelivery.Application.Interfaces.IOrderService, MedicineDelivery.Infrastructure.Services.OrderService>();
builder.Services.AddScoped<MedicineDelivery.Application.Interfaces.IConsentService, MedicineDelivery.Infrastructure.Services.ConsentService>();
builder.Services.AddScoped<MedicineDelivery.Application.Interfaces.IPaymentService, MedicineDelivery.Infrastructure.Services.PaymentService>();
builder.Services.AddScoped<MedicineDelivery.Infrastructure.Services.IBrowserInfoService, MedicineDelivery.Infrastructure.Services.BrowserInfoService>();
// SMS provider: driven by SmsSettings:Provider in appsettings.json ("Console" or "Msg91")
var smsProvider = builder.Configuration["SmsSettings:Provider"] ?? "Console";
if (smsProvider.Equals("Msg91", StringComparison.OrdinalIgnoreCase))
{
    builder.Services.AddHttpClient<MedicineDelivery.Domain.Interfaces.ISmsService, MedicineDelivery.Infrastructure.Services.Msg91SmsService>();
}
else
{
    builder.Services.AddScoped<MedicineDelivery.Domain.Interfaces.ISmsService, MedicineDelivery.Infrastructure.Services.ConsoleSmsService>();
}
builder.Services.AddScoped<MedicineDelivery.Domain.Interfaces.IRazorpayService, MedicineDelivery.Infrastructure.Services.RazorpayService>();
builder.Services.AddScoped<MedicineDelivery.Application.Interfaces.IChemistPayoutService, MedicineDelivery.Infrastructure.Services.ChemistPayoutService>();
builder.Services.AddScoped<MedicineDelivery.Application.Interfaces.IChemistActivationService, MedicineDelivery.Infrastructure.Services.ChemistActivationService>();
builder.Services.AddScoped<MedicineDelivery.Application.Interfaces.IPlatformFeeCalculator, MedicineDelivery.Infrastructure.Services.PlatformFeeCalculator>();

// Razorpay Route onboarding client (typed HttpClient hitting the v2 Accounts API)
builder.Services.AddHttpClient<MedicineDelivery.Application.Interfaces.IRazorpayRouteClient, MedicineDelivery.Infrastructure.Services.RazorpayRouteClient>();
// Razorpay Payment Links client (typed HttpClient) for the chemist activation fee
builder.Services.AddHttpClient<MedicineDelivery.Application.Interfaces.IRazorpayPaymentLinkClient, MedicineDelivery.Infrastructure.Services.RazorpayPaymentLinkClient>();

// Add SignInManager explicitly (not automatically registered with AddIdentity)
builder.Services.AddScoped<SignInManager<MedicineDelivery.Domain.Entities.ApplicationUser>>();

var app = builder.Build();

// Configure the HTTP request pipeline.
app.UseSwagger();
app.UseSwaggerUI();

// Serilog request logging - logs every HTTP request with method, path, status code, and duration
app.UseSerilogRequestLogging();

app.UseHttpsRedirection();

// Add global exception handling middleware
app.UseMiddleware<GlobalExceptionMiddleware>();

// Serve static files from wwwroot
app.UseStaticFiles();

// M-01: explicit allow-list policy instead of the previous AllowAnyOrigin().
app.UseCors(CorsPolicyName);

app.UseAuthentication();

// M-03: MUST run after UseAuthentication — the 'otp-verify' policy partitions by the authenticated
// user id, and HttpContext.User is only populated once authentication has run. Placed earlier, that
// policy would silently degrade to a per-IP limit (which carrier NAT makes ineffective).
// IP-partitioned policies ('auth', 'sms') are unaffected by the position.
app.UseRateLimiter();

app.UseAuthorization();

app.MapControllers();

Log.Information("Application configured and ready to start");

// Add a test logging endpoint for debugging
app.MapGet("/test-logging", () =>
{
    Log.Information("Test logging endpoint called at {Timestamp}", DateTime.UtcNow);
    Log.Warning("This is a test warning log");
    Log.Error("This is a test error log");
    return Results.Ok(new { message = "Test logs written successfully", timestamp = DateTime.UtcNow });
});

var assemblyLocation = Assembly.GetExecutingAssembly().Location;
var buildTimeUtc = string.IsNullOrEmpty(assemblyLocation) ? (DateTime?)null : File.GetLastWriteTimeUtc(assemblyLocation);
Log.Information(
    "Medicine Delivery API is starting up. Environment={Environment}, BuildTimeUtc={BuildTimeUtc}",
    builder.Environment.EnvironmentName, buildTimeUtc);
app.Run();
}
catch (Exception ex)
{
    Log.Fatal(ex, "Application terminated unexpectedly");
}
finally
{
    Log.CloseAndFlush();
}
