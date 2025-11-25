using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using MedicineDelivery.API;
using MedicineDelivery.Infrastructure.Data;

namespace MedicineDelivery.IntegrationTests.Infrastructure;

// Reference to the API's Program class for WebApplicationFactory
using MedicineDelivery.API;

public class TestWebApplicationFactory : WebApplicationFactory<Program>
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.ConfigureServices(services =>
        {
            // Remove the real database context
            var descriptor = services.SingleOrDefault(
                d => d.ServiceType == typeof(DbContextOptions<ApplicationDbContext>));

            if (descriptor != null)
            {
                services.Remove(descriptor);
            }

            // Add in-memory database for testing
            // Use a unique database name for each test scenario to ensure isolation
            var databaseName = $"TestDatabase_{Guid.NewGuid()}";
            services.AddDbContext<ApplicationDbContext>(options =>
            {
                // Use in-memory database for integration tests
                // In a real scenario, you might want to use a test PostgreSQL database
                options.UseInMemoryDatabase(databaseName)
                    .ConfigureWarnings(warnings => warnings.Ignore(Microsoft.EntityFrameworkCore.Diagnostics.InMemoryEventId.TransactionIgnoredWarning));
            });

            // Build the service provider to ensure database is created
            var sp = services.BuildServiceProvider();
            using (var scope = sp.CreateScope())
            {
                var scopedServices = scope.ServiceProvider;
                var db = scopedServices.GetRequiredService<ApplicationDbContext>();
                db.Database.EnsureCreated();
            }
        });
    }
}

