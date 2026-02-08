using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using MedicineDelivery.Domain.Entities;

namespace MedicineDelivery.Infrastructure.Data
{
    public class ApplicationDbContext : IdentityDbContext<Domain.Entities.ApplicationUser>
    {
        private readonly IConfiguration? _configuration;

        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options, IConfiguration? configuration = null) : base(options)
        {
            _configuration = configuration;
        }

        public DbSet<Permission> Permissions { get; set; }
        public DbSet<RolePermission> RolePermissions { get; set; }
        public DbSet<Product> Products { get; set; }
        public DbSet<MedicalStore> MedicalStores { get; set; }
        public DbSet<CustomerSupport> CustomerSupports { get; set; }
        public DbSet<Manager> Managers { get; set; }
        public DbSet<Customer> Customers { get; set; }
        public DbSet<CustomerAddress> CustomerAddresses { get; set; }
        public DbSet<Order> Orders { get; set; }
        public DbSet<OrderAssignmentHistory> OrderAssignmentHistories { get; set; }
        public DbSet<Payment> Payments { get; set; }
        public DbSet<Delivery> Deliveries { get; set; }
        public DbSet<ServiceRegion> ServiceRegions { get; set; }
        public DbSet<ServiceRegionPinCode> ServiceRegionPinCodes { get; set; }
        public DbSet<Consent> Consents { get; set; }
        public DbSet<ConsentLog> ConsentLogs { get; set; }

        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);

            // Configure database provider-specific settings
            ConfigureDatabaseProviderSpecific(builder);

            builder.Entity<Domain.Entities.ApplicationUser>()
                .Property(au => au.Gender)
                .HasMaxLength(20);

            // Configure RolePermission entity to work with Identity roles
            builder.Entity<RolePermission>()
                .HasKey(rp => new { rp.RoleId, rp.PermissionId });

            builder.Entity<RolePermission>()
                .HasOne<Microsoft.AspNetCore.Identity.IdentityRole>()
                .WithMany()
                .HasForeignKey(rp => rp.RoleId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.Entity<RolePermission>()
                .HasOne(rp => rp.Permission)
                .WithMany(p => p.RolePermissions)
                .HasForeignKey(rp => rp.PermissionId)
                .OnDelete(DeleteBehavior.Cascade);

            // Configure MedicalStore entity
            builder.Entity<MedicalStore>()
                .HasKey(ms => ms.MedicalStoreId);

            builder.Entity<MedicalStore>()
                .Property(ms => ms.MedicalName)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<MedicalStore>()
                .Property(ms => ms.OwnerFirstName)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<MedicalStore>()
                .Property(ms => ms.OwnerLastName)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<MedicalStore>()
                .Property(ms => ms.OwnerMiddleName)
                .HasMaxLength(100);

            // Address fields
            builder.Entity<MedicalStore>()
                .Property(ms => ms.AddressLine1)
                .HasMaxLength(300)
                .IsRequired();

            builder.Entity<MedicalStore>()
                .Property(ms => ms.AddressLine2)
                .HasMaxLength(300);

            builder.Entity<MedicalStore>()
                .Property(ms => ms.City)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<MedicalStore>()
                .Property(ms => ms.State)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<MedicalStore>()
                .Property(ms => ms.PostalCode)
                .HasMaxLength(20)
                .IsRequired();

            builder.Entity<MedicalStore>()
                .Property(ms => ms.Latitude)
                .HasColumnType("decimal(18,6)");

            builder.Entity<MedicalStore>()
                .Property(ms => ms.Longitude)
                .HasColumnType("decimal(18,6)");

            builder.Entity<MedicalStore>()
                .Property(ms => ms.MobileNumber)
                .HasMaxLength(15)
                .IsRequired();

            builder.Entity<MedicalStore>()
                .Property(ms => ms.EmailId)
                .HasMaxLength(50)
                .IsRequired();

            builder.Entity<MedicalStore>()
                .Property(ms => ms.AlternativeMobileNumber)
                .HasMaxLength(15);

            // Registration and tax information
            builder.Entity<MedicalStore>()
                .Property(ms => ms.RegistrationStatus)
                .IsRequired();

            builder.Entity<MedicalStore>()
                .Property(ms => ms.GSTIN)
                .HasMaxLength(100);

            builder.Entity<MedicalStore>()
                .Property(ms => ms.PAN)
                .HasMaxLength(100);

            builder.Entity<MedicalStore>()
                .Property(ms => ms.FSSAINo)
                .HasMaxLength(100);

            builder.Entity<MedicalStore>()
                .Property(ms => ms.DLNo)
                .HasMaxLength(100);

            // Pharmacist information
            builder.Entity<MedicalStore>()
                .Property(ms => ms.PharmacistFirstName)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<MedicalStore>()
                .Property(ms => ms.PharmacistLastName)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<MedicalStore>()
                .Property(ms => ms.PharmacistRegistrationNumber)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<MedicalStore>()
                .Property(ms => ms.PharmacistMobileNumber)
                .HasMaxLength(15)
                .IsRequired();

            builder.Entity<MedicalStore>()
                .HasOne<Domain.Entities.ApplicationUser>()
                .WithMany()
                .HasForeignKey(ms => ms.UserId)
                .OnDelete(DeleteBehavior.SetNull);

            // Configure CustomerSupport entity
            builder.Entity<CustomerSupport>()
                .HasKey(cs => cs.CustomerSupportId);

            builder.Entity<CustomerSupport>()
                .Property(cs => cs.CustomerSupportFirstName)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<CustomerSupport>()
                .Property(cs => cs.CustomerSupportLastName)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<CustomerSupport>()
                .Property(cs => cs.CustomerSupportMiddleName)
                .HasMaxLength(100);

            builder.Entity<CustomerSupport>()
                .Property(cs => cs.Address)
                .HasMaxLength(300)
                .IsRequired();

            builder.Entity<CustomerSupport>()
                .Property(cs => cs.City)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<CustomerSupport>()
                .Property(cs => cs.State)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<CustomerSupport>()
                .Property(cs => cs.MobileNumber)
                .HasMaxLength(15)
                .IsRequired();

            builder.Entity<CustomerSupport>()
                .Property(cs => cs.EmailId)
                .HasMaxLength(50)
                .IsRequired();

            builder.Entity<CustomerSupport>()
                .Property(cs => cs.AlternativeMobileNumber)
                .HasMaxLength(15);

            // Employee and photo information
            builder.Entity<CustomerSupport>()
                .Property(cs => cs.EmployeeId)
                .HasMaxLength(50)
                .IsRequired();

            builder.Entity<CustomerSupport>()
                .Property(cs => cs.CustomerSupportPhoto)
                .HasMaxLength(255);

            builder.Entity<CustomerSupport>()
                .HasOne<Domain.Entities.ApplicationUser>()
                .WithMany()
                .HasForeignKey(cs => cs.UserId)
                .OnDelete(DeleteBehavior.SetNull);

            builder.Entity<CustomerSupport>()
                .HasOne(cs => cs.ServiceRegion)
                .WithMany()
                .HasForeignKey(cs => cs.ServiceRegionId)
                .OnDelete(DeleteBehavior.SetNull);

            builder.Entity<CustomerSupport>()
                .HasIndex(cs => cs.ServiceRegionId);

            // Configure Manager entity
            builder.Entity<Manager>()
                .HasKey(m => m.ManagerId);

            builder.Entity<Manager>()
                .Property(m => m.ManagerFirstName)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<Manager>()
                .Property(m => m.ManagerLastName)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<Manager>()
                .Property(m => m.ManagerMiddleName)
                .HasMaxLength(100);

            builder.Entity<Manager>()
                .Property(m => m.Address)
                .HasMaxLength(300)
                .IsRequired();

            builder.Entity<Manager>()
                .Property(m => m.City)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<Manager>()
                .Property(m => m.State)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<Manager>()
                .Property(m => m.MobileNumber)
                .HasMaxLength(15)
                .IsRequired();

            builder.Entity<Manager>()
                .Property(m => m.EmailId)
                .HasMaxLength(50)
                .IsRequired();

            builder.Entity<Manager>()
                .Property(m => m.AlternativeMobileNumber)
                .HasMaxLength(15);

            // Employee and photo information
            builder.Entity<Manager>()
                .Property(m => m.EmployeeId)
                .HasMaxLength(50)
                .IsRequired();

            builder.Entity<Manager>()
                .Property(m => m.ManagerPhoto)
                .HasMaxLength(255);

            builder.Entity<Manager>()
                .HasOne<Domain.Entities.ApplicationUser>()
                .WithMany()
                .HasForeignKey(m => m.UserId)
                .OnDelete(DeleteBehavior.SetNull);

            // Configure Customer entity
            builder.Entity<Customer>()
                .HasKey(c => c.CustomerId);

            builder.Entity<Customer>()
                .Property(c => c.CustomerFirstName)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<Customer>()
                .Property(c => c.CustomerLastName)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<Customer>()
                .Property(c => c.CustomerMiddleName)
                .HasMaxLength(100);

            builder.Entity<Customer>()
                .Property(c => c.MobileNumber)
                .HasMaxLength(15)
                .IsRequired();

            builder.Entity<Customer>()
                .Property(c => c.AlternativeMobileNumber)
                .HasMaxLength(15);

            builder.Entity<Customer>()
                .Property(c => c.EmailId)
                .HasMaxLength(50);


            builder.Entity<Customer>()
                .Property(c => c.Gender)
                .HasMaxLength(10);

            builder.Entity<Customer>()
                .Property(c => c.CustomerPhoto)
                .HasMaxLength(255);

            builder.Entity<Customer>()
                .HasOne<Domain.Entities.ApplicationUser>()
                .WithMany()
                .HasForeignKey(c => c.UserId)
                .OnDelete(DeleteBehavior.SetNull);

            // Configure CustomerAddress entity
            builder.Entity<CustomerAddress>()
                .HasKey(ca => ca.Id);

            builder.Entity<CustomerAddress>()
                .Property(ca => ca.Address)
                .HasMaxLength(300);

            builder.Entity<CustomerAddress>()
                .Property(ca => ca.AddressLine1)
                .HasMaxLength(300);

            builder.Entity<CustomerAddress>()
                .Property(ca => ca.AddressLine2)
                .HasMaxLength(300);

            builder.Entity<CustomerAddress>()
                .Property(ca => ca.AddressLine3)
                .HasMaxLength(300);

            builder.Entity<CustomerAddress>()
                .Property(ca => ca.City)
                .HasMaxLength(100);

            builder.Entity<CustomerAddress>()
                .Property(ca => ca.State)
                .HasMaxLength(100);

            builder.Entity<CustomerAddress>()
                .Property(ca => ca.PostalCode)
                .HasMaxLength(20);

            builder.Entity<CustomerAddress>()
                .Property(ca => ca.Latitude)
                .HasColumnType("decimal(10,8)");

            builder.Entity<CustomerAddress>()
                .Property(ca => ca.Longitude)
                .HasColumnType("decimal(11,8)");

            builder.Entity<CustomerAddress>()
                .HasOne(ca => ca.Customer)
                .WithMany(c => c.Addresses)
                .HasForeignKey(ca => ca.CustomerId)
                .OnDelete(DeleteBehavior.Cascade);

            // Configure Order entity
            builder.Entity<Order>(entity =>
            {
                entity.HasKey(o => o.OrderId);

                entity.Property(o => o.AssignedByType)
                    .HasConversion<string>()
                    .HasMaxLength(20);

                entity.Property(o => o.AssignTo)
                    .HasConversion<string>()
                    .HasMaxLength(20);

                entity.Property(o => o.OrderType)
                    .HasConversion<string>()
                    .HasMaxLength(20);

                entity.Property(o => o.OrderInputType)
                    .HasConversion<string>()
                    .HasMaxLength(20);

                entity.Property(o => o.OrderStatus)
                    .HasConversion<string>()
                    .HasMaxLength(50);

                entity.Property(o => o.OrderInputFileLocation)
                    .HasMaxLength(100);

                entity.Property(o => o.OrderBillFileLocation)
                    .HasMaxLength(255)
                    .IsRequired(false);

                entity.Property(o => o.OrderNumber)
                    .HasMaxLength(10)
                    .IsRequired(false);

                entity.Property(o => o.OTP)
                    .HasMaxLength(4);

                entity.Property(o => o.TotalAmount)
                    .HasColumnType("decimal(10,2)");

                entity.HasOne(o => o.Customer)
                    .WithMany()
                    .HasForeignKey(o => o.CustomerId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(o => o.CustomerAddress)
                    .WithMany()
                    .HasForeignKey(o => o.CustomerAddressId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(o => o.MedicalStore)
                    .WithMany()
                    .HasForeignKey(o => o.MedicalStoreId)
                    .OnDelete(DeleteBehavior.SetNull);

                entity.HasOne(o => o.CustomerSupport)
                    .WithMany()
                    .HasForeignKey(o => o.CustomerSupportId)
                    .OnDelete(DeleteBehavior.SetNull);

                entity.HasOne<Delivery>()
                    .WithMany()
                    .HasForeignKey(o => o.DeliveryId)
                    .OnDelete(DeleteBehavior.SetNull);

                entity.HasIndex(o => o.CustomerId);
                entity.HasIndex(o => o.OrderStatus);
                entity.HasIndex(o => o.MedicalStoreId);
                entity.HasIndex(o => o.DeliveryId);
            });

            // Configure OrderAssignmentHistory entity
            builder.Entity<OrderAssignmentHistory>(entity =>
            {
                entity.HasKey(oah => oah.AssignmentId);

                entity.Property(oah => oah.AssignedByType)
                    .HasConversion<string>()
                    .HasMaxLength(20);

                entity.Property(oah => oah.AssignTo)
                    .HasConversion<string>()
                    .HasMaxLength(20);

                entity.Property(oah => oah.Status)
                    .HasConversion<string>()
                    .HasMaxLength(20);

                entity.Property(oah => oah.RejectNote)
                    .HasMaxLength(250);

                entity.HasOne(oah => oah.Order)
                    .WithMany(o => o.AssignmentHistory)
                    .HasForeignKey(oah => oah.OrderId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(oah => oah.Customer)
                    .WithMany()
                    .HasForeignKey(oah => oah.CustomerId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(oah => oah.MedicalStore)
                    .WithMany()
                    .HasForeignKey(oah => oah.MedicalStoreId)
                    .OnDelete(DeleteBehavior.Restrict)
                    .IsRequired(false);

                entity.HasOne(oah => oah.CustomerSupport)
                    .WithMany()
                    .HasForeignKey(oah => oah.AssignedByCustomerSupportId)
                    .OnDelete(DeleteBehavior.SetNull);

                entity.HasOne<Delivery>()
                    .WithMany()
                    .HasForeignKey(oah => oah.DeliveryId)
                    .OnDelete(DeleteBehavior.SetNull);

                entity.HasIndex(oah => oah.OrderId);
                entity.HasIndex(oah => oah.CustomerId);
                entity.HasIndex(oah => oah.MedicalStoreId);
                entity.HasIndex(oah => oah.DeliveryId);
                entity.HasIndex(oah => oah.Status);
            });

            // Configure Payment entity
            builder.Entity<Payment>(entity =>
            {
                entity.HasKey(p => p.PaymentId);

                entity.Property(p => p.PaymentMode)
                    .HasMaxLength(50)
                    .IsRequired();

                entity.Property(p => p.TransactionId)
                    .HasMaxLength(100)
                    .IsRequired();

                entity.Property(p => p.Amount)
                    .HasColumnType("decimal(10,2)");

                entity.Property(p => p.PaymentStatus)
                    .HasConversion<string>()
                    .HasMaxLength(50);

                entity.HasOne(p => p.Order)
                    .WithMany(o => o.Payments)
                    .HasForeignKey(p => p.OrderId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasIndex(p => p.OrderId);
                entity.HasIndex(p => p.TransactionId).IsUnique();
            });

            // Configure Delivery entity
            builder.Entity<Delivery>(entity =>
            {
                entity.HasKey(d => d.Id);

                entity.Property(d => d.FirstName)
                    .HasMaxLength(100);

                entity.Property(d => d.MiddleName)
                    .HasMaxLength(100);

                entity.Property(d => d.LastName)
                    .HasMaxLength(100);

                entity.Property(d => d.DrivingLicenceNumber)
                    .HasMaxLength(50);

                entity.Property(d => d.MobileNumber)
                    .HasMaxLength(15);

                entity.Property(d => d.IsActive)
                    .IsRequired()
                    .HasDefaultValue(true);

                entity.Property(d => d.IsDeleted)
                    .IsRequired()
                    .HasDefaultValue(false);

                entity.Property(d => d.AddedOn)
                    .IsRequired();

                entity.HasOne(d => d.MedicalStore)
                    .WithMany()
                    .HasForeignKey(d => d.MedicalStoreId)
                    .OnDelete(DeleteBehavior.SetNull);

                entity.HasOne(d => d.ServiceRegion)
                    .WithMany()
                    .HasForeignKey(d => d.ServiceRegionId)
                    .OnDelete(DeleteBehavior.SetNull);

                entity.HasIndex(d => d.MedicalStoreId);
                entity.HasIndex(d => d.ServiceRegionId);
                entity.HasIndex(d => d.IsActive);
                entity.HasIndex(d => d.IsDeleted);
            });

            // Configure ServiceRegion entity (keeps existing table name)
            builder.Entity<ServiceRegion>(entity =>
            {
                entity.ToTable("CustomerSupportRegions");
                entity.HasKey(sr => sr.Id);

                entity.Property(sr => sr.Name)
                    .HasMaxLength(100)
                    .IsRequired();

                entity.Property(sr => sr.City)
                    .HasMaxLength(100)
                    .IsRequired();

                entity.Property(sr => sr.RegionName)
                    .HasMaxLength(100)
                    .IsRequired();

                entity.Property(sr => sr.RegionType)
                    .IsRequired()
                    .HasDefaultValue(Domain.Enums.RegionType.CustomerSupport);

                entity.HasIndex(sr => sr.Name);
                entity.HasIndex(sr => sr.City);
                entity.HasIndex(sr => sr.RegionName);
                entity.HasIndex(sr => sr.RegionType);
            });

            // Configure ServiceRegionPinCode entity (keeps existing table name)
            builder.Entity<ServiceRegionPinCode>(entity =>
            {
                entity.ToTable("CustomerSupportRegionPinCodes");
                entity.HasKey(srpc => srpc.Id);

                entity.Property(srpc => srpc.PinCode)
                    .HasMaxLength(10)
                    .IsRequired();

                entity.HasOne(srpc => srpc.ServiceRegion)
                    .WithMany(sr => sr.RegionPinCodes)
                    .HasForeignKey(srpc => srpc.ServiceRegionId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasIndex(srpc => srpc.ServiceRegionId);
                entity.HasIndex(srpc => srpc.PinCode);
                
                // Ensure unique pin code per region
                entity.HasIndex(srpc => new { srpc.ServiceRegionId, srpc.PinCode })
                    .IsUnique();
            });

            // Configure Consent entity
            builder.Entity<Consent>(entity =>
            {
                entity.HasKey(c => c.ConsentId);

                entity.Property(c => c.Title)
                    .HasMaxLength(200)
                    .IsRequired();

                entity.Property(c => c.Description)
                    .HasMaxLength(1000);

                entity.Property(c => c.Content)
                    .IsRequired();

                entity.HasIndex(c => c.IsActive);
                entity.HasIndex(c => c.CreatedOn);
            });

            // Configure ConsentLog entity
            builder.Entity<ConsentLog>(entity =>
            {
                entity.HasKey(cl => cl.ConsentLogId);

                entity.Property(cl => cl.UserId)
                    .IsRequired();

                entity.Property(cl => cl.UserAgent)
                    .HasMaxLength(500);

                entity.Property(cl => cl.IpAddress)
                    .HasMaxLength(50);

                entity.Property(cl => cl.DeviceInfo)
                    .HasMaxLength(500);

                entity.HasOne(cl => cl.Consent)
                    .WithMany(c => c.ConsentLogs)
                    .HasForeignKey(cl => cl.ConsentId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(cl => cl.User)
                    .WithMany()
                    .HasForeignKey(cl => cl.UserId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasIndex(cl => cl.ConsentId);
                entity.HasIndex(cl => cl.UserId);
                entity.HasIndex(cl => cl.UserType);
                entity.HasIndex(cl => cl.CreatedOn);
            });
        }

        private void ConfigureDatabaseProviderSpecific(ModelBuilder builder)
        {
            var databaseProvider = _configuration?["DatabaseProvider"] ?? "SqlServer";
            
            if (databaseProvider == "PostgreSQL")
            {
                // PostgreSQL-specific configurations
                ConfigureForPostgreSQL(builder);
            }
            else
            {
                // SQL Server-specific configurations (default)
                ConfigureForSqlServer(builder);
            }
        }

        private void ConfigureForSqlServer(ModelBuilder builder)
        {
            // SQL Server specific configurations (existing NEWID() calls)
            builder.Entity<MedicalStore>()
                .Property(ms => ms.MedicalStoreId)
                .HasDefaultValueSql("NEWID()");

            builder.Entity<CustomerSupport>()
                .Property(cs => cs.CustomerSupportId)
                .HasDefaultValueSql("NEWID()");

            builder.Entity<Manager>()
                .Property(m => m.ManagerId)
                .HasDefaultValueSql("NEWID()");

            builder.Entity<Customer>()
                .Property(c => c.CustomerId)
                .HasDefaultValueSql("NEWID()");

            builder.Entity<Order>()
                .Property(o => o.CreatedOn)
                .HasDefaultValueSql("GETUTCDATE()");

            builder.Entity<OrderAssignmentHistory>()
                .Property(oah => oah.AssignedOn)
                .HasDefaultValueSql("GETUTCDATE()");

            builder.Entity<Payment>()
                .Property(p => p.PaidOn)
                .HasDefaultValueSql("GETUTCDATE()");
        }

        private void ConfigureForPostgreSQL(ModelBuilder builder)
        {
            // PostgreSQL specific configurations
            builder.Entity<MedicalStore>()
                .Property(ms => ms.MedicalStoreId)
                .HasDefaultValueSql("gen_random_uuid()");

            builder.Entity<CustomerSupport>()
                .Property(cs => cs.CustomerSupportId)
                .HasDefaultValueSql("gen_random_uuid()");

            builder.Entity<Manager>()
                .Property(m => m.ManagerId)
                .HasDefaultValueSql("gen_random_uuid()");

            builder.Entity<Customer>()
                .Property(c => c.CustomerId)
                .HasDefaultValueSql("gen_random_uuid()");

            // PostgreSQL uses timestamp with time zone for UTC DateTime values
            builder.Entity<MedicalStore>()
                .Property(ms => ms.CreatedOn)
                .HasColumnType("timestamp with time zone");

            builder.Entity<MedicalStore>()
                .Property(ms => ms.UpdatedOn)
                .HasColumnType("timestamp with time zone");

            builder.Entity<CustomerSupport>()
                .Property(cs => cs.CreatedOn)
                .HasColumnType("timestamp with time zone");

            builder.Entity<CustomerSupport>()
                .Property(cs => cs.UpdatedOn)
                .HasColumnType("timestamp with time zone");

            builder.Entity<Manager>()
                .Property(m => m.CreatedOn)
                .HasColumnType("timestamp with time zone");

            builder.Entity<Manager>()
                .Property(m => m.UpdatedOn)
                .HasColumnType("timestamp with time zone");

            builder.Entity<Customer>()
                .Property(c => c.CreatedOn)
                .HasColumnType("timestamp with time zone");

            builder.Entity<Customer>()
                .Property(c => c.UpdatedOn)
                .HasColumnType("timestamp with time zone");

            builder.Entity<Order>()
                .Property(o => o.CreatedOn)
                .HasColumnType("timestamp with time zone")
                .HasDefaultValueSql("now() at time zone 'utc'");

            builder.Entity<Order>()
                .Property(o => o.UpdatedOn)
                .HasColumnType("timestamp with time zone");

            // PostgreSQL datetime configuration for Consent
            builder.Entity<Consent>()
                .Property(c => c.CreatedOn)
                .HasColumnType("timestamp with time zone")
                .HasDefaultValueSql("now() at time zone 'utc'");

            builder.Entity<Consent>()
                .Property(c => c.UpdatedOn)
                .HasColumnType("timestamp with time zone");

            // PostgreSQL datetime configuration for ConsentLog
            builder.Entity<ConsentLog>()
                .Property(cl => cl.CreatedOn)
                .HasColumnType("timestamp with time zone")
                .HasDefaultValueSql("now() at time zone 'utc'");

            builder.Entity<Order>()
                .Property(o => o.TotalAmount)
                .HasColumnType("numeric(10,2)");

            builder.Entity<OrderAssignmentHistory>()
                .Property(oah => oah.AssignedOn)
                .HasColumnType("timestamp with time zone")
                .HasDefaultValueSql("now() at time zone 'utc'");

            builder.Entity<OrderAssignmentHistory>()
                .Property(oah => oah.UpdatedOn)
                .HasColumnType("timestamp with time zone");

            builder.Entity<Payment>()
                .Property(p => p.PaidOn)
                .HasColumnType("timestamp with time zone")
                .HasDefaultValueSql("now() at time zone 'utc'");

            builder.Entity<Payment>()
                .Property(p => p.Amount)
                .HasColumnType("numeric(10,2)");

            // Configure ApplicationUser DateTime properties for PostgreSQL
            builder.Entity<Domain.Entities.ApplicationUser>()
                .Property(au => au.CreatedAt)
                .HasColumnType("timestamp with time zone");

            builder.Entity<Domain.Entities.ApplicationUser>()
                .Property(au => au.LastLoginAt)
                .HasColumnType("timestamp with time zone");

            // User entity removed - using ApplicationUser directly

            // UserRole entity removed - using Identity UserRoles directly

            // Configure RolePermission DateTime properties
            builder.Entity<RolePermission>()
                .Property(rp => rp.GrantedAt)
                .HasColumnType("timestamp with time zone");

            // Configure Permission DateTime properties
            builder.Entity<Permission>()
                .Property(p => p.CreatedAt)
                .HasColumnType("timestamp with time zone");

            // Role entity removed - using Identity roles directly

            // Configure Product DateTime properties
            builder.Entity<Product>()
                .Property(p => p.CreatedAt)
                .HasColumnType("timestamp with time zone");

            builder.Entity<Product>()
                .Property(p => p.UpdatedAt)
                .HasColumnType("timestamp with time zone");

            // Configure Delivery DateTime properties for PostgreSQL
            builder.Entity<Delivery>()
                .Property(d => d.AddedOn)
                .HasColumnType("timestamp with time zone")
                .HasDefaultValueSql("now() at time zone 'utc'");

            builder.Entity<Delivery>()
                .Property(d => d.ModifiedOn)
                .HasColumnType("timestamp with time zone");

            // Configure Consent DateTime properties for PostgreSQL
            builder.Entity<Consent>()
                .Property(c => c.CreatedOn)
                .HasColumnType("timestamp with time zone")
                .HasDefaultValueSql("now() at time zone 'utc'");

            builder.Entity<Consent>()
                .Property(c => c.UpdatedOn)
                .HasColumnType("timestamp with time zone");

            // Configure ConsentLog DateTime properties for PostgreSQL
            builder.Entity<ConsentLog>()
                .Property(cl => cl.CreatedOn)
                .HasColumnType("timestamp with time zone")
                .HasDefaultValueSql("now() at time zone 'utc'");

        }
    }

}
