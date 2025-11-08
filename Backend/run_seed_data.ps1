# =====================================================
# PowerShell Script to Run Seed Data Script
# For Medicine Delivery Application - PostgreSQL
# =====================================================

param(
    [Parameter(Mandatory=$false)]
    [string]$Server = "localhost",
    
    [Parameter(Mandatory=$false)]
    [int]$Port = 5432,
    
    [Parameter(Mandatory=$false)]
    [string]$Database = "MedicineDeliveryDB",
    
    [Parameter(Mandatory=$false)]
    [string]$Username = "postgres",
    
    [Parameter(Mandatory=$false)]
    [string]$Password = ""
)

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "Medicine Delivery App - Seed Data Script" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Check if psql is available
try {
    $psqlVersion = psql --version
    Write-Host "PostgreSQL Client Found: $psqlVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: psql command not found!" -ForegroundColor Red
    Write-Host "Please ensure PostgreSQL client tools are installed and added to PATH" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Connection Details:" -ForegroundColor Yellow
Write-Host "  Server: $Server" -ForegroundColor White
Write-Host "  Port: $Port" -ForegroundColor White
Write-Host "  Database: $Database" -ForegroundColor White
Write-Host "  Username: $Username" -ForegroundColor White
Write-Host ""

# Prompt for password if not provided
if ([string]::IsNullOrWhiteSpace($Password)) {
    $SecurePassword = Read-Host "Enter PostgreSQL Password" -AsSecureString
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
    $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
}

# Set environment variable for password
$env:PGPASSWORD = $Password

Write-Host "Connecting to database..." -ForegroundColor Yellow

# Check if seed_data_script.sql exists
if (-not (Test-Path "seed_data_script.sql")) {
    Write-Host "ERROR: seed_data_script.sql not found in current directory!" -ForegroundColor Red
    exit 1
}

Write-Host "Running seed data script..." -ForegroundColor Yellow
Write-Host ""

# Run the script
try {
    psql -h $Server -p $Port -U $Username -d $Database -f seed_data_script.sql
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "=============================================" -ForegroundColor Green
        Write-Host "Seed Data Script Completed Successfully!" -ForegroundColor Green
        Write-Host "=============================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Default Users Created:" -ForegroundColor Cyan
        Write-Host "  1. Admin         - Mobile: 9999999999 | Password: Admin@123" -ForegroundColor White
        Write-Host "  2. Manager       - Mobile: 8888888888 | Password: Manager@123" -ForegroundColor White
        Write-Host "  3. Support       - Mobile: 7777777777 | Password: Support@123" -ForegroundColor White
        Write-Host "  4. Customer      - Mobile: 6666666666 | Password: Customer@123" -ForegroundColor White
        Write-Host "  5. Chemist       - Mobile: 5555555555 | Password: Chemist@123" -ForegroundColor White
        Write-Host ""
        Write-Host "IMPORTANT: The passwords above are for DEVELOPMENT only!" -ForegroundColor Red
        Write-Host "           Change them before deploying to production!" -ForegroundColor Red
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "ERROR: Script execution failed!" -ForegroundColor Red
        Write-Host "Please check the error messages above." -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host ""
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    # Clear the password from environment
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
}

# Optionally run verification queries
$verify = Read-Host "Would you like to verify the seed data? (Y/N)"
if ($verify -eq "Y" -or $verify -eq "y") {
    Write-Host ""
    Write-Host "Running verification queries..." -ForegroundColor Yellow
    
    $env:PGPASSWORD = $Password
    
    # Create temporary verification script
    $verifyScript = @"
SELECT '=================================================' as "";
SELECT 'SEED DATA VERIFICATION SUMMARY' as "";
SELECT '=================================================' as "";
SELECT COUNT(*) as "Total Roles" FROM "AspNetRoles";
SELECT COUNT(*) as "Total Permissions" FROM "Permissions";
SELECT COUNT(*) as "Total Role-Permission Mappings" FROM "RolePermissions";
SELECT COUNT(*) as "Total Users" FROM "AspNetUsers";
SELECT COUNT(*) as "Total User-Role Mappings" FROM "AspNetUserRoles";
SELECT '=================================================' as "";
SELECT 'USERS WITH THEIR ROLES' as "";
SELECT '=================================================' as "";
SELECT u."UserName", u."Email", u."FirstName", u."LastName", r."Name" as "RoleName"
FROM "AspNetUsers" u
JOIN "AspNetUserRoles" ur ON u."Id" = ur."UserId"
JOIN "AspNetRoles" r ON ur."RoleId" = r."Id"
ORDER BY r."Name", u."UserName";
"@
    
    $verifyScript | psql -h $Server -p $Port -U $Username -d $Database
    
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green

