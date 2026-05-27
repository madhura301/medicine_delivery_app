---
name: add-feature
description: Scaffold a new backend feature following Clean Architecture CQRS pattern
user_invocable: true
---

# Add Feature Skill

When the user invokes `/add-feature <FeatureName>`, scaffold the full CQRS structure for a new feature in the backend.

## Steps

1. Ask the user for:
   - Feature/entity name (e.g., "Prescription")
   - Whether they need Commands, Queries, or both
   - Specific operations needed (e.g., Create, Update, Delete, GetAll, GetById)

2. Create the following files following the project's Clean Architecture pattern:

### Domain Layer (`Backend/MedicineDelivery/MedicineDelivery.Domain/`)
- `Entities/{EntityName}.cs` — Domain entity class
- `Interfaces/I{EntityName}Repository.cs` — Repository interface (if needed)

### Application Layer (`Backend/MedicineDelivery/MedicineDelivery.Application/`)
- `DTOs/{EntityName}Dto.cs` — Read DTO (record type)
- `DTOs/Create{EntityName}Dto.cs` — Create DTO (if Create command needed)
- `DTOs/Update{EntityName}Dto.cs` — Update DTO (if Update command needed)
- `Features/{FeatureName}/Commands/{CommandName}/{CommandName}Command.cs`
- `Features/{FeatureName}/Commands/{CommandName}/{CommandName}CommandHandler.cs`
- `Features/{FeatureName}/Queries/{QueryName}/{QueryName}Query.cs`
- `Features/{FeatureName}/Queries/{QueryName}/{QueryName}QueryHandler.cs`
- Update `Mappings/MappingProfile.cs` with new mappings

### Infrastructure Layer (`Backend/MedicineDelivery/MedicineDelivery.Infrastructure/`)
- `Services/{EntityName}Service.cs` — Service implementation
- Add DbSet to `ApplicationDbContext`
- Create EF Core configuration if needed

### API Layer (`Backend/MedicineDelivery/MedicineDelivery.API/`)
- `Controllers/{EntitiesName}Controller.cs` — API controller (plural name)
- Register services in `Program.cs`

## Rules
- Follow all naming conventions from Backend CLAUDE.md
- Use async/await, nullable reference types, record DTOs
- Controllers must be thin — delegate to MediatR
- Respect Clean Architecture dependency flow
