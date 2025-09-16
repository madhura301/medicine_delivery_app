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
using System.Reflection;
using Microsoft.AspNetCore.Authorization;

var builder = WebApplication.CreateBuilder(args);

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

// Add Entity Framework
builder.Services.AddDbContext<MedicineDelivery.Infrastructure.Data.ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Add Identity
builder.Services.AddIdentity<MedicineDelivery.Infrastructure.Data.ApplicationUser, IdentityRole>(options =>
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
});

// Register the permission authorization handler
builder.Services.AddScoped<IAuthorizationHandler, MedicineDelivery.API.Authorization.PermissionAuthorizationHandler>();

// Add AutoMapper
builder.Services.AddAutoMapper(typeof(MappingProfile));

// Add MediatR
builder.Services.AddMediatR(cfg => cfg.RegisterServicesFromAssembly(typeof(CreateUserCommand).Assembly));

// Add custom services
builder.Services.AddScoped<MedicineDelivery.Domain.Interfaces.IUnitOfWork, UnitOfWork>();
builder.Services.AddScoped<MedicineDelivery.Domain.Interfaces.IAuthService, MedicineDelivery.Infrastructure.Services.AuthService>();
builder.Services.AddScoped<MedicineDelivery.Domain.Interfaces.IRoleService, MedicineDelivery.Infrastructure.Services.RoleService>();
builder.Services.AddScoped<MedicineDelivery.Domain.Interfaces.IPermissionService, MedicineDelivery.Infrastructure.Services.PermissionService>();
builder.Services.AddScoped<MedicineDelivery.API.Services.IPermissionService, MedicineDelivery.API.Services.PermissionService>();
builder.Services.AddScoped<MedicineDelivery.Domain.Interfaces.IUserManager, MedicineDelivery.Infrastructure.Services.UserManagerService>();
builder.Services.AddScoped<MedicineDelivery.Application.Interfaces.IMedicalStoreService, MedicineDelivery.Infrastructure.Services.MedicalStoreService>();

// Add SignInManager explicitly (not automatically registered with AddIdentity)
builder.Services.AddScoped<SignInManager<MedicineDelivery.Infrastructure.Data.ApplicationUser>>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

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

// Seed the database
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var context = services.GetRequiredService<MedicineDelivery.Infrastructure.Data.ApplicationDbContext>();
        var userManager = services.GetRequiredService<UserManager<MedicineDelivery.Infrastructure.Data.ApplicationUser>>();
        var roleManager = services.GetRequiredService<RoleManager<IdentityRole>>();
        var roleService = services.GetRequiredService<MedicineDelivery.Domain.Interfaces.IRoleService>();
        await SeedData.Initialize(context, userManager, roleManager, roleService);
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "An error occurred seeding the DB.");
    }
}

app.Run();
