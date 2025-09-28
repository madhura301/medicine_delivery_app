# PowerShell script to fix PostgreSQL DateTime columns
# This script runs the SQL fix for the DateTime issue

Write-Host "Fixing PostgreSQL DateTime columns..." -ForegroundColor Green

# Read connection string from appsettings.json
$appSettingsPath = "MedicineDelivery.API\appsettings.json"
$appSettings = Get-Content $appSettingsPath | ConvertFrom-Json
$connectionString = $appSettings.ConnectionStrings.PostgresConnection

Write-Host "Connection String: $connectionString" -ForegroundColor Yellow

# Extract connection parameters
if ($connectionString -match "Host=([^;]+);Port=([^;]+);Database=([^;]+);Username=([^;]+);Password=([^;]+);") {
    $host = $matches[1]
    $port = $matches[2]
    $database = $matches[3]
    $username = $matches[4]
    $password = $matches[5]
    
    Write-Host "Host: $host" -ForegroundColor Cyan
    Write-Host "Port: $port" -ForegroundColor Cyan
    Write-Host "Database: $database" -ForegroundColor Cyan
    Write-Host "Username: $username" -ForegroundColor Cyan
    
    # Run the SQL script using psql
    $env:PGPASSWORD = $password
    $sqlScript = Get-Content "fix_postgresql_datetime.sql" -Raw
    
    Write-Host "Executing SQL script..." -ForegroundColor Green
    
    try {
        $sqlScript | psql -h $host -p $port -U $username -d $database
        Write-Host "SQL script executed successfully!" -ForegroundColor Green
    }
    catch {
        Write-Host "Error executing SQL script: $($_.Exception.Message)" -ForegroundColor Red
    }
}
else {
    Write-Host "Could not parse connection string. Please check the format." -ForegroundColor Red
}

Write-Host "DateTime fix completed!" -ForegroundColor Green
