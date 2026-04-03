# Backend — .NET 8 Clean Architecture

## Layer Rules (STRICT)

### Domain (`MedicineDelivery.Domain/`)
- ZERO NuGet packages (except primitives)
- ZERO references to other layers
- Contains: Entities, Enums, Interfaces, Exceptions, ValueObjects
- Entities are anemic — no business logic
- One file per entity, named exactly as the class

### Application (`MedicineDelivery.Application/`)
- References Domain only
- Contains: DTOs (record types, `Dto` suffix), Features (CQRS), Mappings, Validators, Interfaces
- CQRS structure: `Features/{Feature}/Commands/{CommandName}/` and `Features/{Feature}/Queries/{QueryName}/`
- Each Command/Query has its own folder with `{Name}Command.cs` + `{Name}CommandHandler.cs`
- Commands change state (return Id or bool), Queries are read-only (return DTOs)
- Never put business logic in handlers — delegate to domain/services

### Infrastructure (`MedicineDelivery.Infrastructure/`)
- References Domain + Application
- Contains: Data (DbContext, Configurations), Migrations, Repositories, Services, External clients
- One Fluent API configuration file per entity in `Data/Configurations/`
- Never edit migration files after creation
- Service classes implement interfaces from Application layer

### API (`MedicineDelivery.API/`)
- References Application + Infrastructure (for DI registration only)
- Contains: Controllers, Middleware, Authorization, Models, Extensions
- Controllers must be thin — HTTP concerns only, delegate to MediatR/services
- Controller names are plural (`OrdersController`)
- Never use Domain entities directly — always use DTOs from Application
- Never put service implementations here — use Infrastructure

## Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Entity | PascalCase, singular | `Customer.cs` |
| DTO | `{Entity}Dto` or `{Action}{Entity}Dto` | `CustomerDto.cs`, `CreateOrderDto.cs` |
| Interface | `I{Name}` | `IOrderService.cs` |
| Controller | `{Entities}Controller` (plural) | `OrdersController.cs` |
| Command | `{Verb}{Entity}Command` | `CreateOrderCommand.cs` |
| Query | `Get{Entity/Entities}Query` | `GetOrdersQuery.cs` |
| Handler | `{Command/Query}Handler` | `CreateOrderCommandHandler.cs` |
| EF Config | `{Entity}Configuration` | `OrderConfiguration.cs` |
| Validator | `{Command}Validator` | `CreateOrderCommandValidator.cs` |

## Coding Standards

- C# 12 / .NET 8, nullable reference types enabled
- Async/await everywhere — never `.Result` or `.Wait()`
- Constructor injection for DI
- Structured logging with `ILogger<T>`
- Proper HTTP status codes from controllers
- No magic strings/numbers — use enums and constants

## Key Commands

```bash
# Build & run
dotnet restore
dotnet build
dotnet run --project MedicineDelivery.API

# Migrations
dotnet ef migrations add {Name} --project MedicineDelivery.Infrastructure --startup-project MedicineDelivery.API
dotnet ef database update --project MedicineDelivery.Infrastructure --startup-project MedicineDelivery.API
dotnet ef migrations script {From} {To} --idempotent --project MedicineDelivery.Infrastructure --startup-project MedicineDelivery.API --output migration_script.sql

# Tests
dotnet test
dotnet test --filter "FullyQualifiedName~Auth"
dotnet test --logger "console;verbosity=detailed"
```

## Authorization

- Permission-based system with `PermissionRequirement` + `PermissionAuthorizationHandler`
- Policies registered in `Program.cs` for each permission
- Role-specific permissions prefixed: `AdminReadUsers`, `ChemistReadUsers`, etc.
- Use `[Authorize(Policy = "PermissionName")]` on controller actions

## Database

- PostgreSQL via Npgsql EF Core provider
- `ApplicationDbContext` extends `IdentityDbContext<ApplicationUser>`
- 13+ DbSets covering all business entities
- Supports geographic coordinates (NetTopologySuite)
