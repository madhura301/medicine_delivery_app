# Generating Password Hashes for Seed Data

## Overview
The password hashes in `seed_data_script.sql` are placeholders. This document explains how to generate proper ASP.NET Core Identity password hashes for your seed data.

## Method 1: Using a C# Console Application (Recommended)

Create a simple console app to generate password hashes:

### Step 1: Create Console App
```bash
dotnet new console -n PasswordHashGenerator
cd PasswordHashGenerator
```

### Step 2: Add Required Package
```bash
dotnet add package Microsoft.AspNetCore.Identity
```

### Step 3: Create Password Hash Generator

Create `Program.cs`:
```csharp
using Microsoft.AspNetCore.Identity;

// Define a dummy user class for password hashing
public class ApplicationUser
{
    public string Id { get; set; } = string.Empty;
}

class Program
{
    static void Main(string[] args)
    {
        var passwordHasher = new PasswordHasher<ApplicationUser>();
        var user = new ApplicationUser();

        // Passwords for each role
        var passwords = new Dictionary<string, string>
        {
            { "Admin", "Admin@123" },
            { "Manager", "Manager@123" },
            { "CustomerSupport", "Support@123" },
            { "Customer", "Customer@123" },
            { "Chemist", "Chemist@123" }
        };

        Console.WriteLine("=================================================");
        Console.WriteLine("ASP.NET Core Identity Password Hashes");
        Console.WriteLine("=================================================");
        Console.WriteLine();

        foreach (var kvp in passwords)
        {
            var hash = passwordHasher.HashPassword(user, kvp.Value);
            Console.WriteLine($"Role: {kvp.Key}");
            Console.WriteLine($"Password: {kvp.Value}");
            Console.WriteLine($"Hash: {hash}");
            Console.WriteLine();
        }

        Console.WriteLine("=================================================");
        Console.WriteLine("Copy these hashes to your seed_data_script.sql");
        Console.WriteLine("=================================================");
    }
}
```

### Step 4: Run the Generator
```bash
dotnet run
```

### Step 5: Update SQL Script
Copy the generated hashes and update the `PasswordHash` column in Section 4 of `seed_data_script.sql`.

## Method 2: Using Existing Application

You can also generate password hashes using your existing application:

### Step 1: Add Temporary Controller Method

Add this method to your `AuthController.cs` (temporary, remove after use):

```csharp
[HttpPost("generate-hash")]
[AllowAnonymous] // Remove this in production!
public IActionResult GeneratePasswordHash([FromBody] string password)
{
    var user = new ApplicationUser();
    var passwordHasher = new PasswordHasher<ApplicationUser>();
    var hash = passwordHasher.HashPassword(user, password);
    
    return Ok(new { password, hash });
}
```

### Step 2: Call the Endpoint

Using PowerShell:
```powershell
$body = @{
    password = "Admin@123"
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://localhost:5001/api/auth/generate-hash" `
    -Method POST `
    -Body $body `
    -ContentType "application/json"
```

Using curl:
```bash
curl -X POST https://localhost:5001/api/auth/generate-hash \
  -H "Content-Type: application/json" \
  -d '"Admin@123"'
```

### Step 3: ⚠️ Remove the Method
**IMPORTANT**: Delete this method after generating hashes. Never deploy it to production!

## Method 3: Using PowerShell with Reflection

Create `GeneratePasswordHashes.ps1`:

```powershell
# Path to your API DLL
$dllPath = ".\MedicineDelivery\MedicineDelivery.API\bin\Debug\net8.0\MedicineDelivery.API.dll"

# Load required assemblies
Add-Type -Path $dllPath
Add-Type -AssemblyName "Microsoft.AspNetCore.Identity"

# Create hasher instance
$userType = [MedicineDelivery.Domain.Entities.ApplicationUser]
$hasherType = [Microsoft.AspNetCore.Identity.PasswordHasher``1].MakeGenericType($userType)
$hasher = [Activator]::CreateInstance($hasherType)
$user = [Activator]::CreateInstance($userType)

# Passwords to hash
$passwords = @{
    "Admin" = "Admin@123"
    "Manager" = "Manager@123"
    "CustomerSupport" = "Support@123"
    "Customer" = "Customer@123"
    "Chemist" = "Chemist@123"
}

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "Password Hashes for Seed Data" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

foreach ($role in $passwords.Keys) {
    $password = $passwords[$role]
    $hash = $hasher.HashPassword($user, $password)
    
    Write-Host ""
    Write-Host "Role: $role" -ForegroundColor Yellow
    Write-Host "Password: $password" -ForegroundColor White
    Write-Host "Hash: $hash" -ForegroundColor Green
}

Write-Host ""
Write-Host "=================================================" -ForegroundColor Cyan
```

Run:
```powershell
.\GeneratePasswordHashes.ps1
```

## Method 4: Using SQL Script with Direct Hashes (Pre-Generated)

If you just want to use pre-generated hashes for the default passwords, here they are:

### For .NET 8+ (PasswordHasherCompatibilityMode.IdentityV3)

Update Section 4 in `seed_data_script.sql`:

```sql
-- Admin User (Password: Admin@123)
-- Replace the PasswordHash with:
'AQAAAAIAAYagAAAAEJhZWxsbyB3b3JsZCEgVGhpcyBpcyBhIHRlc3QgcGFzc3dvcmQgaGFzaC4gUGxlYXNlIGdlbmVyYXRlIGEgcmVhbCBvbmUh'

-- NOTE: This is still a placeholder! Generate a real hash using Method 1 or 2
```

## Understanding Password Hash Format

ASP.NET Core Identity V3 password hash format:
```
[Format Marker][PRF][Iteration Count][Salt][Subkey]
```

- **Format Marker**: `0x01` (Identity V3)
- **PRF**: HMAC-SHA256 or HMAC-SHA512
- **Iteration Count**: Number of PBKDF2 iterations (default: 100,000 for V3)
- **Salt**: Random 128-bit value
- **Subkey**: Derived 256-bit key

The entire hash is Base64 encoded.

## Updating the SQL Script

After generating hashes, update `seed_data_script.sql` Section 4:

### Before (with placeholder):
```sql
INSERT INTO "AspNetUsers" 
    (..., "PasswordHash", ...)
VALUES 
    (...,
     'AQAAAAIAAYagAAAAEFQ1Z1x3YzN2VzJ3NzV6V3RzMnN0czN3VzJ2N3Z2dzN2N3Z2N3Y2NjY2N3Z2N2Y=',
     ...)
```

### After (with real hash):
```sql
INSERT INTO "AspNetUsers" 
    (..., "PasswordHash", ...)
VALUES 
    (...,
     'AQAAAAIAAYagAAAAEKnOwL8bMhYvCfPl9pVDx6vPQQxLH5k3yqNVBCqHQJ+gE/Z9vR5wL3xN2mP7U8qA==',
     ...)
```

## Verification

To verify your password hashes work:

1. Run the seed data script with your generated hashes
2. Try to login using the application's login endpoint:

```powershell
$body = @{
    username = "9999999999"
    password = "Admin@123"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "https://localhost:5001/api/auth/login" `
    -Method POST `
    -Body $body `
    -ContentType "application/json"

if ($response.token) {
    Write-Host "✅ Login successful! Password hash is correct." -ForegroundColor Green
} else {
    Write-Host "❌ Login failed! Password hash may be incorrect." -ForegroundColor Red
}
```

## Security Notes

### ⚠️ Important Security Practices:

1. **Never commit password hashes to public repositories**
   - Use environment-specific seed scripts
   - Store production hashes securely (Azure Key Vault, AWS Secrets Manager, etc.)

2. **Use strong passwords in production**
   - Minimum 12 characters
   - Mix of uppercase, lowercase, numbers, symbols
   - No dictionary words
   - No personal information

3. **Change default passwords immediately**
   - Force password change on first login
   - Implement password expiration policies

4. **Use additional security layers**
   - Enable two-factor authentication
   - Implement account lockout policies
   - Use IP whitelisting for admin accounts
   - Monitor failed login attempts

5. **Generate unique hashes per environment**
   - Development hashes ≠ Production hashes
   - Different passwords for different environments

## Example: Complete Workflow

### For Development Environment:

1. Generate password hashes:
   ```bash
   dotnet new console -n HashGen
   cd HashGen
   dotnet add package Microsoft.AspNetCore.Identity
   # Add Program.cs code from Method 1
   dotnet run > hashes.txt
   ```

2. Copy hashes from `hashes.txt` to `seed_data_script.sql`

3. Run seed script:
   ```powershell
   .\run_seed_data.ps1
   ```

4. Test login:
   ```powershell
   # Test each user
   $users = @(
       @{ username = "9999999999"; password = "Admin@123" },
       @{ username = "8888888888"; password = "Manager@123" },
       @{ username = "7777777777"; password = "Support@123" },
       @{ username = "6666666666"; password = "Customer@123" },
       @{ username = "5555555555"; password = "Chemist@123" }
   )
   
   foreach ($user in $users) {
       $body = $user | ConvertTo-Json
       try {
           $response = Invoke-RestMethod -Uri "https://localhost:5001/api/auth/login" `
               -Method POST -Body $body -ContentType "application/json"
           Write-Host "✅ $($user.username) login successful" -ForegroundColor Green
       } catch {
           Write-Host "❌ $($user.username) login failed" -ForegroundColor Red
       }
   }
   ```

### For Production Environment:

1. **DO NOT use the default passwords**
2. Generate strong, unique passwords for each account
3. Generate password hashes for production passwords
4. Store hashes in secure secret management system
5. Use separate seed script for production
6. Force password change on first login
7. Enable MFA for all privileged accounts

## Troubleshooting

### Hash doesn't work / Login fails

**Check:**
1. ✅ Hash was generated using correct `PasswordHasher<ApplicationUser>`
2. ✅ Hash is Base64 encoded string
3. ✅ Hash starts with `AQAAAA` (for Identity V3)
4. ✅ No extra spaces or newlines in hash
5. ✅ Password matches what you're testing with
6. ✅ User account is active (`IsActive = true`)
7. ✅ User account is not locked out

### "Invalid algorithm specified" error

**Cause:** Mismatch between hash version and Identity configuration.
**Solution:** Ensure you're using `PasswordHasher<ApplicationUser>` from the same package version as your application.

## References

- [ASP.NET Core Identity Documentation](https://docs.microsoft.com/en-us/aspnet/core/security/authentication/identity)
- [Password Hashing in ASP.NET Core](https://andrewlock.net/exploring-the-asp-net-core-identity-passwordhasher/)
- [PBKDF2 Specification](https://tools.ietf.org/html/rfc2898)

---
*Last Updated: October 2025*

