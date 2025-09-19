# Quick Setup Guide for Medicine Delivery API Testing

## 🚀 One-Click API Testing Setup

Follow these simple steps to test all API endpoints with a single click:

### Step 1: Start the API Server

```bash
# Navigate to the Backend directory
cd J:\Projects\MedicineDeliveryRepo\medicine_delivery_app\Backend

# Start the API server
dotnet run --project MedicineDelivery/MedicineDelivery.API
```

**Expected Output:**
```
Now listening on: http://localhost:5000
Application started. Press Ctrl+C to shut down.
```

### Step 2: Import Postman Collection

1. **Open Postman**
2. **Click "Import"** button
3. **Import both files:**
   - `MedicineDelivery_API_Tests.postman_collection.json`
   - `MedicineDelivery_API_Environment.postman_environment.json` (optional)

### Step 3: Run All Tests

1. **Right-click** on "Medicine Delivery API Tests" collection
2. **Select "Run collection"**
3. **Click "Run Medicine Delivery API Tests"**
4. **Watch all 20+ tests execute automatically!**

## ✅ What Gets Tested

### 🔐 Authentication
- User registration and login
- JWT token generation and validation

### 🏥 Medical Stores
- Registration with new address structure (AddressLine1, AddressLine2, City, State, PostalCode)
- Pharmacist information handling
- Registration status and GSTIN validation
- Full CRUD operations

### 👥 Customer Support
- Registration with Employee ID
- Photo upload functionality
- Full CRUD operations

### 👨‍💼 Managers
- Registration with Employee ID
- Photo upload functionality
- Full CRUD operations

### 👤 User Management
- User retrieval and management

### 🧹 Cleanup
- Optional cleanup of test data

## 📊 Test Results

After running, you'll see:
- ✅ **Green checkmarks** for passed tests
- ❌ **Red X marks** for failed tests
- 📝 **Console logs** with generated passwords and photo URLs
- 🔄 **Automatic variable setting** for subsequent requests

## 🎯 Key Features

- **Single Click Testing**: Run all endpoints with one click
- **Automatic Authentication**: Handles login and token management
- **Variable Management**: Automatically stores IDs and tokens
- **Photo Upload Testing**: Tests file upload functionality
- **Realistic Test Data**: Uses proper sample data
- **Comprehensive Coverage**: Tests all CRUD operations
- **Error Handling**: Validates error responses

## 🔧 Troubleshooting

### API Not Starting?
```bash
# Check if port 5000 is available
netstat -an | findstr :5000

# Try a different port
dotnet run --project MedicineDelivery/MedicineDelivery.API --urls="http://localhost:5001"
```

### Tests Failing?
1. **Check API Console** for error messages
2. **Verify Database** is running and migrated
3. **Check Authentication** - ensure login test passes first
4. **Review Variables** - ensure auth_token is set

### Photo Upload Issues?
- Tests use sample base64 images
- Ensure uploads directory exists
- Check file permissions

## 📈 Expected Test Results

When everything works correctly, you should see:
- **~20+ tests passing**
- **Generated passwords** in console
- **Photo URLs** returned for upload tests
- **Entity IDs** stored for subsequent tests

## 🎉 Success!

If all tests pass, your Medicine Delivery API is working perfectly with:
- ✅ New address structure for medical stores
- ✅ Pharmacist information handling
- ✅ Employee ID management
- ✅ Photo upload functionality
- ✅ Registration status validation
- ✅ Complete CRUD operations

---

**Ready to test? Just follow the 3 steps above and click "Run"! 🚀**
