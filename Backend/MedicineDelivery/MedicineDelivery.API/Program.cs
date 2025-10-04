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
using MedicineDelivery.API.Data;
using MedicineDelivery.API.Authorization;
using MedicineDelivery.API.Services;
using MedicineDelivery.API.Middleware;
using System.Reflection;
using Microsoft.AspNetCore.Authorization;
using Serilog;

// Configure Serilog - This will be configured later with the builder's configuration

try
{
    Log.Information("Starting Medicine Delivery API application");

    var builder = WebApplication.CreateBuilder(args);

    // Configure Serilog with the builder's configuration
    Log.Logger = new LoggerConfiguration()
        .ReadFrom.Configuration(builder.Configuration)
        .CreateLogger();

    // Add Serilog
    builder.Host.UseSerilog();

// Add services to the container.
builder.Services.AddControllers();

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
            options.UseSqlServer(connectionString);
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
var secretKey = jwtSettings["SecretKey"];

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
    
    options.AddPolicy("RequireReadOrdersPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("ReadOrders")));
    
    options.AddPolicy("RequireCreateOrdersPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("CreateOrders")));
    
    options.AddPolicy("RequireUpdateOrdersPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("UpdateOrders")));
    
    options.AddPolicy("RequireDeleteOrdersPermission", policy => 
        policy.Requirements.Add(new MedicineDelivery.API.Authorization.PermissionRequirement("DeleteOrders")));
    
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
});

// Register the permission authorization handler
builder.Services.AddScoped<IAuthorizationHandler, MedicineDelivery.API.Authorization.PermissionAuthorizationHandler>();

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
builder.Services.AddScoped<MedicineDelivery.Application.Interfaces.IPhotoUploadService, MedicineDelivery.Infrastructure.Services.PhotoUploadService>();
builder.Services.AddScoped<MedicineDelivery.Application.Interfaces.IPermissionCheckerService, MedicineDelivery.Infrastructure.Services.PermissionCheckerService>();

// Add SignInManager explicitly (not automatically registered with AddIdentity)
builder.Services.AddScoped<SignInManager<MedicineDelivery.Domain.Entities.ApplicationUser>>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
    Log.Information("Swagger UI enabled for development environment");
}

app.UseSwagger();
app.UseSwaggerUI();

app.UseHttpsRedirection();

// Add global exception handling middleware
app.UseMiddleware<GlobalExceptionMiddleware>();

app.UseCors(builder =>
{
    builder
        .AllowAnyOrigin()
        .AllowAnyMethod()
        .AllowAnyHeader();
});

app.UseAuthentication();
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

// Seed the database
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        Log.Information("Starting database seeding process");
        var context = services.GetRequiredService<MedicineDelivery.Infrastructure.Data.ApplicationDbContext>();
        var userManager = services.GetRequiredService<UserManager<MedicineDelivery.Domain.Entities.ApplicationUser>>();
        var roleManager = services.GetRequiredService<RoleManager<IdentityRole>>();
        var roleService = services.GetRequiredService<MedicineDelivery.Domain.Interfaces.IRoleService>();
        await SeedData.Initialize(context, userManager, roleManager, roleService);
        Log.Information("Database seeding completed successfully");
    }
    catch (Exception ex)
    {
        Log.Error(ex, "An error occurred seeding the database");
        throw;
    }
}

Log.Information("Medicine Delivery API is starting up");
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
