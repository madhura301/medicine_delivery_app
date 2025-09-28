# Fix PostgreSQL Authentication Issue

## Problem
Getting `28P01: password authentication failed for user "postgres"` even though you set password "123" during installation.

## Solution

### Step 1: Check PostgreSQL Authentication Configuration

1. **Find your PostgreSQL installation directory** (usually):
   ```
   C:\Program Files\PostgreSQL\13\data\
   ```

2. **Open `pg_hba.conf` file** in a text editor (run as Administrator)

3. **Look for the authentication lines** and change them to:
   ```
   # TYPE  DATABASE        USER            ADDRESS                 METHOD
   local   all             postgres                                md5
   host    all             postgres        127.0.0.1/32            md5
   host    all             postgres        ::1/128                 md5
   ```

### Step 2: Alternative - Use Trust Method (Less Secure)

If you want to test quickly, you can temporarily use `trust` method:
```
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             postgres                                trust
host    all             postgres        127.0.0.1/32            trust
host    all             postgres        ::1/128                 trust
```

### Step 3: Restart PostgreSQL Service

After making changes to `pg_hba.conf`:
```powershell
Restart-Service postgresql-x64-13
```

### Step 4: Test Connection

Try the migration again:
```bash
dotnet ef database update --project MedicineDelivery.Infrastructure --startup-project MedicineDelivery.API
```

## Alternative Solutions

### Option A: Reset Password Using Command Line

1. Open Command Prompt as Administrator
2. Navigate to PostgreSQL bin directory:
   ```
   cd "C:\Program Files\PostgreSQL\13\bin"
   ```
3. Reset password:
   ```
   psql -U postgres -d postgres -c "ALTER USER postgres PASSWORD '123';"
   ```

### Option B: Use pgAdmin

1. Open pgAdmin
2. Connect to PostgreSQL server
3. Right-click on "postgres" user
4. Select "Properties"
5. Go to "Definition" tab
6. Set new password to "123"
7. Save changes

### Option C: Create New User

1. Open Command Prompt as Administrator
2. Navigate to PostgreSQL bin directory
3. Create new user:
   ```
   psql -U postgres -d postgres -c "CREATE USER medicinedelivery WITH PASSWORD '123';"
   psql -U postgres -d postgres -c "ALTER USER medicinedelivery CREATEDB;"
   ```
4. Update connection string in appsettings.json:
   ```json
   "PostgresConnection": "Host=localhost;Port=5432;Database=postgres;Username=medicinedelivery;Password=123;"
   ```

## Quick Fix Script

Run this PowerShell script as Administrator:

```powershell
# Stop PostgreSQL service
Stop-Service postgresql-x64-13

# Backup original pg_hba.conf
$pgDataPath = "C:\Program Files\PostgreSQL\13\data"
Copy-Item "$pgDataPath\pg_hba.conf" "$pgDataPath\pg_hba.conf.backup"

# Update pg_hba.conf to use md5 authentication
$content = @"
# PostgreSQL Client Authentication Configuration File
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             all                                     md5
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
"@

$content | Out-File -FilePath "$pgDataPath\pg_hba.conf" -Encoding ASCII

# Start PostgreSQL service
Start-Service postgresql-x64-13

Write-Host "PostgreSQL authentication fixed! Try the migration again." -ForegroundColor Green
```
