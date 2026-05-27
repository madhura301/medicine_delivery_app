---
name: run-backend
description: Build and run the .NET backend API
user_invocable: true
---

# Run Backend Skill

Build, restore, and run the .NET backend API server.

## Steps

1. Restore packages:
   ```bash
   cd Backend/MedicineDelivery && dotnet restore
   ```

2. Build the solution:
   ```bash
   cd Backend/MedicineDelivery && dotnet build
   ```

3. If build succeeds, run the API:
   ```bash
   cd Backend/MedicineDelivery && dotnet run --project MedicineDelivery.API
   ```

4. If build fails, analyze errors and help fix them before re-running.
