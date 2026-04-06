---
name: run-tests
description: Run backend integration tests (SpecFlow BDD) and report results
user_invocable: true
---

# Run Tests Skill

Run the SpecFlow BDD integration tests for the backend.

## Steps

1. Run all tests:
   ```bash
   cd Backend/MedicineDelivery && dotnet test --logger "console;verbosity=detailed"
   ```

2. If the user provides a filter argument, run filtered:
   ```bash
   cd Backend/MedicineDelivery && dotnet test --filter "FullyQualifiedName~{Filter}" --logger "console;verbosity=detailed"
   ```

3. Parse the output and report:
   - Total tests, passed, failed, skipped
   - Details of any failures (test name, error message, stack trace)

4. If tests fail, analyze the failures and suggest fixes.
