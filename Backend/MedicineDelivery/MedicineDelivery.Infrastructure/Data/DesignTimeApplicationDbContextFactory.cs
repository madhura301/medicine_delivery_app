using System;
using System.IO;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;

namespace MedicineDelivery.Infrastructure.Data;

public class DesignTimeApplicationDbContextFactory : IDesignTimeDbContextFactory<ApplicationDbContext>
{
    public ApplicationDbContext CreateDbContext(string[] args)
    {
        var environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Development";
        var configBasePath = ResolveApiConfigPath();

        var configuration = new ConfigurationBuilder()
            .SetBasePath(configBasePath)
            .AddJsonFile("appsettings.json", optional: true, reloadOnChange: false)
            .AddJsonFile($"appsettings.{environment}.json", optional: true, reloadOnChange: false)
            .AddEnvironmentVariables()
            .Build();

        var databaseProvider = configuration["DatabaseProvider"] ?? "SqlServer";
        var connectionString = databaseProvider switch
        {
            "PostgreSQL" => configuration.GetConnectionString("PostgresConnection"),
            _ => configuration.GetConnectionString("DefaultConnection")
        };

        var optionsBuilder = new DbContextOptionsBuilder<ApplicationDbContext>();

        if (databaseProvider == "PostgreSQL")
        {
            optionsBuilder.UseNpgsql(connectionString);
        }
        else
        {
            optionsBuilder.UseSqlServer(connectionString);
        }

        return new ApplicationDbContext(optionsBuilder.Options, configuration);
    }

    private static string ResolveApiConfigPath()
    {
        var directory = new DirectoryInfo(Directory.GetCurrentDirectory());
        while (directory != null)
        {
            var apiPath = Path.Combine(directory.FullName, "MedicineDelivery.API");
            if (Directory.Exists(apiPath))
            {
                return apiPath;
            }

            var appsettingsPath = Path.Combine(directory.FullName, "appsettings.json");
            if (File.Exists(appsettingsPath))
            {
                return directory.FullName;
            }

            directory = directory.Parent;
        }

        return Directory.GetCurrentDirectory();
    }
}

