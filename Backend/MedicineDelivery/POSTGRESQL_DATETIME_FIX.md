# PostgreSQL DateTime Fix

## Problem
You are encountering the following error when registering a medical store:
```
Cannot write DateTime with Kind=UTC to PostgreSQL type 'timestamp without time zone', 
consider using 'timestamp with time zone'. 
Note that it's not possible to mix DateTimes with different Kinds in an array, range, or multirange. (Parameter 'value')
```

## Root Cause
The issue occurs because:
1. Your application code uses `DateTime.UtcNow` which creates DateTime values with `Kind=UTC`
2. Your PostgreSQL database columns are configured as `timestamp` (without time zone)
3. PostgreSQL's `timestamp` type doesn't store timezone information, but `DateTime.UtcNow` has timezone information

## Solution

### Option 1: Update Database Schema (Recommended)
Run the SQL script to update existing columns to use `timestamp with time zone`:

```bash
# Navigate to the MedicineDelivery directory
cd MedicineDelivery

# Run the PowerShell script (requires psql to be installed)
.\run_datetime_fix.ps1

# OR manually run the SQL script
psql -h localhost -p 5432 -U postgres -d MedicineDelivery -f fix_postgresql_datetime.sql
```

### Option 2: Update Entity Framework Configuration
The `ApplicationDbContext.cs` has been updated to configure all DateTime properties to use `timestamp with time zone` for PostgreSQL. This ensures future migrations will create the correct column types.

### Option 3: Use DateTime.Now instead of DateTime.UtcNow (Not Recommended)
You could change all `DateTime.UtcNow` calls to `DateTime.Now`, but this is not recommended as it can cause timezone-related issues.

## Files Modified

### 1. ApplicationDbContext.cs
- Updated `ConfigureForPostgreSQL` method to use `timestamp with time zone` for all DateTime properties
- Added comprehensive DateTime configuration for all entities

### 2. SQL Scripts
- `fix_postgresql_datetime.sql` - SQL script to update existing database schema
- `run_datetime_fix.ps1` - PowerShell script to execute the SQL fix

## Testing the Fix

After applying the fix, test the medical store registration:

1. Start your application
2. Make a POST request to `/api/medicalstores/register`
3. The DateTime error should no longer occur

## Verification

You can verify the fix by checking the database schema:

```sql
-- Check column types for MedicalStores table
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'MedicalStores' 
AND column_name IN ('CreatedOn', 'UpdatedOn');
```

The `data_type` should show `timestamp with time zone`.

## Additional Notes

- This fix ensures consistent DateTime handling across your application
- All future DateTime operations will work correctly with PostgreSQL
- The fix is backward compatible and won't affect existing data
- Consider using `DateTimeOffset` in future projects for better timezone handling
