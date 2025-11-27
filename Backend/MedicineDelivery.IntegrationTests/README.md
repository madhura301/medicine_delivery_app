# Medicine Delivery Integration Tests

This project contains SpecFlow-based integration tests for the Medicine Delivery API.

## Prerequisites

- .NET 8.0 SDK
- SpecFlow for Visual Studio extension (optional, for better IDE support)

## Project Structure

```
MedicineDelivery.IntegrationTests/
├── Features/              # Gherkin feature files
│   ├── Auth.feature      # Authentication API tests
│   └── Setup.feature     # Setup/Seeding API tests
├── StepDefinitions/      # Step definition implementations
│   ├── AuthSteps.cs
│   └── SetupSteps.cs
├── Infrastructure/        # Test infrastructure
│   └── TestWebApplicationFactory.cs
└── Support/              # Test support classes
    └── TestContext.cs
```

## Running Tests

### Run all tests
```bash
dotnet test
```

### Run specific feature
```bash
dotnet test --filter "FullyQualifiedName~Auth"
```

### Run with detailed output
```bash
dotnet test --logger "console;verbosity=detailed"
```

## Test Modes

### In-Memory Test Server (Default)

By default, tests use an **in-memory test server** with an in-memory database:
- Each test run starts with a fresh database
- No data persists between test runs
- Tests are isolated and can run in parallel
- No need to run the API separately

### External API Mode (For Debugging)

To test against an **actual API running locally** (e.g., in another Visual Studio instance), you can configure the tests to use an external API URL. This is useful for:
- Debugging API code with breakpoints
- Testing against a real database
- Testing with actual middleware and services

#### Configuration Options

**Option 1: Environment Variables (Recommended)**
```bash
# Windows PowerShell
$env:USE_EXTERNAL_API="true"
$env:EXTERNAL_API_BASE_URL="http://localhost:5000"
dotnet test

# Windows CMD
set USE_EXTERNAL_API=true
set EXTERNAL_API_BASE_URL=http://localhost:5000
dotnet test

# Linux/Mac
export USE_EXTERNAL_API=true
export EXTERNAL_API_BASE_URL=http://localhost:5000
dotnet test
```

**Option 2: appsettings.json**
Edit `appsettings.json` in the test project:
```json
{
  "TestSettings": {
    "UseExternalApi": true,
    "ExternalApiBaseUrl": "http://localhost:5000"
  }
}
```

**Note:** Environment variables take precedence over `appsettings.json`.

#### Steps to Use External API Mode

1. Start your API in another Visual Studio instance (or terminal)
   - Make sure it's running on the URL specified in configuration (default: `http://localhost:5000`)
   - Ensure the API is fully started before running tests

2. Configure the test project to use external API (using one of the methods above)

3. Run the tests:
   ```bash
   dotnet test
   ```

4. The tests will now call your running API instead of creating an in-memory server

#### Important Notes for External API Mode

- **Database State**: Tests will use your actual database, so data may persist between test runs
- **Test Isolation**: Tests may interfere with each other if they use the same data
- **Setup Required**: You may need to manually set up roles, permissions, and seed data before running tests
- **Port Configuration**: Make sure the API is running on the port specified in `EXTERNAL_API_BASE_URL`

## Adding New Tests

1. Create a new `.feature` file in the `Features/` folder
2. Write Gherkin scenarios describing the API behavior
3. Create corresponding step definitions in `StepDefinitions/`
4. Build and run tests

### Example Feature File

```gherkin
Feature: Products API
    As a user
    I want to manage products
    So that I can view and update product information

    Background:
        Given the API is running
        And I am authenticated as an admin

    Scenario: Get all products
        When I request all products
        Then the response status should be 200
        And the response should contain a list of products
```

## Test Context

The `TestContext` class is automatically injected into step definitions and provides:
- `HttpClient Client` - HTTP client for making API requests
- `HttpResponseMessage LastResponse` - Last API response
- `string AuthToken` - JWT token for authenticated requests
- `TestWebApplicationFactory? Factory` - Factory for creating test server (null when using external API)

## Notes

- The test factory automatically configures the API with an in-memory database
- Authentication tokens are stored in `TestContext` for reuse across steps
- All tests run against a fresh database instance

