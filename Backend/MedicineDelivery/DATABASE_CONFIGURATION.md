# Database Configuration Guide

This application now supports both **SQL Server** and **PostgreSQL** databases. You can switch between them using a simple configuration flag.

## Configuration

### 1. Database Provider Flag

Set the `DatabaseProvider` flag in your configuration files:

```json
{
  "DatabaseProvider": "SqlServer"  // or "PostgreSQL"
}
```

### 2. Connection Strings

Configure the appropriate connection string based on your chosen provider:

#### SQL Server Configuration
```json
{
  "DatabaseProvider": "SqlServer",
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=MedicineDelivery;Trusted_Connection=True;MultipleActiveResultSets=true;TrustServerCertificate=True"
  }
}
```

#### PostgreSQL Configuration
```json
{
  "DatabaseProvider": "PostgreSQL",
  "ConnectionStrings": {
    "PostgresConnection": "Host=localhost;Database=MedicineDelivery;Username=postgres;Password=your_password;Port=5432"
  }
}
```

## Environment-Specific Configuration

### Development Environment (appsettings.Development.json)
```json
{
  "DatabaseProvider": "PostgreSQL",
  "ConnectionStrings": {
    "PostgresConnection": "Host=localhost;Database=MedicineDeliveryDev;Username=postgres;Password=your_password_here;Port=5432"
  }
}
```

### Production Environment (appsettings.json)
```json
{
  "DatabaseProvider": "SqlServer",
  "ConnectionStrings": {
    "DefaultConnection": "Server=your-server;Database=MedicineDelivery;User Id=your-user;Password=your-password;TrustServerCertificate=True"
  }
}
```

## Database Migrations

### For SQL Server
```bash
dotnet ef migrations add InitialCreate --project MedicineDelivery.Infrastructure --startup-project MedicineDelivery.API
dotnet ef database update --project MedicineDelivery.Infrastructure --startup-project MedicineDelivery.API
```

### For PostgreSQL
1. First, switch your configuration to PostgreSQL
2. Run the same migration commands:
```bash
dotnet ef migrations add InitialCreate --project MedicineDelivery.Infrastructure --startup-project MedicineDelivery.API
dotnet ef database update --project MedicineDelivery.Infrastructure --startup-project MedicineDelivery.API
```

## Database Provider Differences

The application automatically handles the following differences between providers:

### SQL Server
- Uses `NEWID()` for GUID generation
- Uses `datetime2(7)` for timestamp columns
- Default provider

### PostgreSQL
- Uses `gen_random_uuid()` for GUID generation
- Uses `timestamp` for timestamp columns
- Requires Npgsql.EntityFrameworkCore.PostgreSQL package

## Switching Between Providers

1. **Update Configuration**: Change the `DatabaseProvider` flag in your configuration
2. **Update Connection String**: Ensure the correct connection string is configured
3. **Run Migrations**: Generate and apply new migrations for the target database
4. **Restart Application**: The application will automatically use the new provider

## Prerequisites

### SQL Server
- SQL Server instance running
- Database created (or let EF create it via migrations)

### PostgreSQL
- PostgreSQL server running
- Database created (or let EF create it via migrations)
- `Npgsql.EntityFrameworkCore.PostgreSQL` package installed (already added to project)

## Troubleshooting

### Common Issues

1. **Connection String Format**: Ensure connection strings match the expected format for each provider
2. **Package Dependencies**: Make sure both SQL Server and PostgreSQL EF packages are installed
3. **Migration Conflicts**: If switching providers, you may need to drop and recreate the database
4. **GUID Generation**: The application handles provider-specific GUID generation automatically

### Testing Configuration

You can test your configuration by:
1. Running the application
2. Checking the database connection in the logs
3. Verifying that tables are created with the correct schema for your chosen provider

## Example Configuration Files

### Complete appsettings.json (SQL Server)
```json
{
  "DatabaseProvider": "SqlServer",
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=MedicineDelivery;Trusted_Connection=True;MultipleActiveResultSets=true;TrustServerCertificate=True",
    "PostgresConnection": "Host=localhost;Database=MedicineDelivery;Username=postgres;Password=your_password_here;Port=5432"
  },
  "JwtSettings": {
    "SecretKey": "ThisIsAVeryLongSecretKeyThatShouldBeAtLeast32CharactersLong",
    "Issuer": "MediMart.API",
    "Audience": "MediMart.API.Users",
    "ExpiryInHours": 1
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

### Complete appsettings.Development.json (PostgreSQL)
```json
{
  "DatabaseProvider": "PostgreSQL",
  "ConnectionStrings": {
    "PostgresConnection": "Host=localhost;Database=MedicineDeliveryDev;Username=postgres;Password=your_password_here;Port=5432"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning",
      "Microsoft.EntityFrameworkCore": "Information"
    }
  }
}
```
