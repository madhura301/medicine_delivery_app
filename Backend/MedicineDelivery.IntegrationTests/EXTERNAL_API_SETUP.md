# Using External API for Integration Tests

This guide explains how to run integration tests against an actual API instance running locally, which is useful for debugging.

## Quick Start

### Step 1: Start Your API

1. Open the `MedicineDelivery.API` project in Visual Studio (or another instance)
2. Run the API (F5 or Ctrl+F5)
3. Note the URL where it's running (e.g., `http://localhost:5000` or `https://localhost:5001`)

### Step 2: Configure Tests to Use External API

**Option A: Environment Variables (Recommended for one-time use)**

In PowerShell:
```powershell
$env:USE_EXTERNAL_API="true"
$env:EXTERNAL_API_BASE_URL="http://localhost:5000"
dotnet test
```

In CMD:
```cmd
set USE_EXTERNAL_API=true
set EXTERNAL_API_BASE_URL=http://localhost:5000
dotnet test
```

**Option B: appsettings.json (Recommended for persistent configuration)**

Edit `appsettings.json`:
```json
{
  "TestSettings": {
    "UseExternalApi": true,
    "ExternalApiBaseUrl": "http://localhost:5000"
  }
}
```

Then run:
```bash
dotnet test
```

### Step 3: Run Tests

```bash
cd MedicineDelivery.IntegrationTests
dotnet test
```

The tests will now call your running API instead of creating an in-memory server.

## Switching Back to In-Memory Mode

**If using environment variables:**
```powershell
Remove-Item Env:\USE_EXTERNAL_API
Remove-Item Env:\EXTERNAL_API_BASE_URL
```

**If using appsettings.json:**
Set `UseExternalApi` to `false` or remove the environment variables.

## Important Notes

1. **Database State**: When using external API mode, tests will use your actual database. Data may persist between test runs.

2. **Setup Required**: You may need to manually set up roles, permissions, and seed data before running tests, or ensure your test scenarios include the necessary setup steps.

3. **Port Configuration**: Make sure the API is running on the port specified in `EXTERNAL_API_BASE_URL`. Check your API's `launchSettings.json` or console output to confirm the port.

4. **Debugging**: You can now set breakpoints in your API code and debug while tests are running!

## Troubleshooting

**Tests can't connect to API:**
- Verify the API is running and accessible at the configured URL
- Check if the port matches `EXTERNAL_API_BASE_URL`
- Try accessing the API URL in a browser to confirm it's running

**Tests fail with authentication errors:**
- Ensure your API has the necessary roles and permissions set up
- Check if your test scenarios include setup steps for roles/permissions

**Configuration not working:**
- Environment variables take precedence over `appsettings.json`
- Make sure `appsettings.json` is copied to the output directory (it should be automatic)
- Check the console output - it will show "Using external API at: ..." or "Using in-memory test server"

