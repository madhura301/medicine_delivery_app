# Medicine Delivery API - Postman Testing Guide

This guide explains how to use the provided Postman collection to test all API endpoints with a single click.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Setup Instructions](#setup-instructions)
3. [Running the Tests](#running-the-tests)
4. [Test Collection Overview](#test-collection-overview)
5. [Understanding Test Results](#understanding-test-results)
6. [Troubleshooting](#troubleshooting)
7. [API Endpoints Covered](#api-endpoints-covered)

## 🚀 Prerequisites

- **Postman Application** installed on your computer
- **Medicine Delivery API** running on `http://localhost:5000`
- **Database** properly configured and migrated
- **Admin User** created in the system (or use the registration endpoint)

## 📥 Setup Instructions

### Step 1: Import the Collection

1. **Open Postman**
2. **Click "Import"** button (top-left corner)
3. **Select the file** `MedicineDelivery_API_Tests.postman_collection.json`
4. **Click "Import"** to add the collection to your workspace

### Step 2: Verify Collection Import

After importing, you should see:
- **Collection Name:** "Medicine Delivery API Tests"
- **Folders:** Authentication, Medical Stores, Customer Support, Managers, Users Management, Customers, Customer Addresses, Cleanup
- **Total Requests:** 30+ API endpoints

### Step 3: Set Environment Variables (Optional)

The collection uses these variables automatically:
- `base_url`: `http://localhost:5000` (default)
- `auth_token`: Automatically set after login
- `admin_user_id`: Automatically set after registration/login
- `medical_store_id`: Automatically set after medical store creation
- `customer_support_id`: Automatically set after customer support creation
- `manager_id`: Automatically set after manager creation
- `customer_id`: Automatically set after customer registration
- `admin_created_customer_id`: Automatically set after admin creates customer
- `customer_address_id`: Automatically set after customer address creation

## ▶️ Running the Tests

### Method 1: Run All Tests (Recommended)

1. **Right-click** on the collection name "Medicine Delivery API Tests"
2. **Select "Run collection"**
3. **Click "Run Medicine Delivery API Tests"** button
4. **Watch the progress** as all tests execute automatically

### Method 2: Run Individual Folders

1. **Right-click** on any folder (e.g., "Authentication")
2. **Select "Run folder"**
3. **Click "Run"** to test only that specific module

### Method 3: Run Individual Requests

1. **Click** on any request
2. **Click "Send"** to test that specific endpoint

## 📊 Test Collection Overview

### 🔐 Authentication (2 tests)
- **Register Admin User** - Creates a new admin user
- **Login Admin User** - Authenticates and gets access token

### 🏥 Medical Stores (4 tests)
- **Register Medical Store** - Creates medical store with new address structure
- **Get All Medical Stores** - Retrieves all medical stores
- **Get Medical Store by ID** - Retrieves specific medical store
- **Update Medical Store** - Updates medical store information

### 👥 Customer Support (5 tests)
- **Register Customer Support** - Creates customer support with employee ID
- **Get All Customer Supports** - Retrieves all customer support records
- **Get Customer Support by ID** - Retrieves specific customer support
- **Upload Customer Support Photo** - Tests photo upload functionality
- **Update Customer Support** - Updates customer support information

### 👨‍💼 Managers (5 tests)
- **Register Manager** - Creates manager with employee ID
- **Get All Managers** - Retrieves all managers
- **Get Manager by ID** - Retrieves specific manager
- **Upload Manager Photo** - Tests photo upload functionality
- **Update Manager** - Updates manager information

### 👤 Users Management (2 tests)
- **Get All Users** - Retrieves all users
- **Get User by ID** - Retrieves specific user

### 👥 Customers (8 tests)
- **Register Customer (Anonymous)** - Customer self-registration with addresses
- **Create Customer (Admin)** - Admin creates customer with addresses
- **Get All Customers** - Retrieves all customers
- **Get Customer by ID** - Retrieves specific customer
- **Get Customer by Mobile Number** - Retrieves customer by mobile
- **Get My Profile** - Customer gets their own profile
- **Update Customer** - Updates customer information
- **Delete Customer** - Deletes customer

### 🏠 Customer Addresses (6 tests)
- **Create Customer Address** - Creates new customer address with address lines
- **Get Customer Address by ID** - Retrieves specific customer address
- **Get Customer Addresses by Customer ID** - Retrieves all addresses for a customer
- **Update Customer Address** - Updates customer address information
- **Set Default Customer Address** - Sets an address as default for a customer
- **Delete Customer Address** - Deletes customer address

### 🧹 Cleanup (Optional) (3 tests)
- **Delete Medical Store** - Soft deletes medical store
- **Delete Customer Support** - Soft deletes customer support
- **Delete Manager** - Soft deletes manager

## ✅ Understanding Test Results

### Test Results Indicators

- **✅ Green Checkmark**: Test passed
- **❌ Red X**: Test failed
- **⏸️ Gray Circle**: Test skipped

### Console Output

The tests log important information to the console:
- **Generated Passwords** for new users
- **Photo URLs** after successful uploads
- **Entity IDs** for created records

### Test Assertions

Each test includes multiple assertions:
- **Status Code Validation** - Ensures correct HTTP status codes
- **Response Structure Validation** - Verifies response contains expected fields
- **Data Validation** - Checks specific values in responses
- **Variable Setting** - Automatically stores IDs and tokens for subsequent requests

## 🔧 Troubleshooting

### Common Issues and Solutions

#### 1. **"Connection Refused" Error**
```
Error: Could not get any response
```
**Solution:**
- Ensure the API is running: `dotnet run --project MedicineDelivery/MedicineDelivery.API`
- Check if the API is accessible at `http://localhost:5000`
- Verify the `base_url` variable in Postman

#### 2. **"401 Unauthorized" Error**
```
Status code is 401
```
**Solution:**
- Ensure authentication tests run first
- Check if the `auth_token` variable is set
- Verify the admin user credentials are correct

#### 3. **"500 Internal Server Error"**
```
Status code is 500
```
**Solution:**
- Check the API console for detailed error messages
- Ensure the database is properly configured
- Verify all required packages are installed

#### 4. **"404 Not Found" Error**
```
Status code is 404
```
**Solution:**
- Check if the API endpoints are correctly configured
- Verify the API is running the latest version
- Ensure the route paths match the controller endpoints

#### 5. **Photo Upload Tests Failing**
```
Invalid photo file format
```
**Solution:**
- The collection includes sample base64 images for testing
- Ensure the photo upload service is properly configured
- Check if the uploads directory exists and is writable

### Debugging Tips

1. **Check Console Output**: Look at the Postman console for detailed error messages
2. **Verify Variables**: Ensure all environment variables are properly set
3. **Test Individual Requests**: Run requests one by one to isolate issues
4. **Check API Logs**: Monitor the API console for server-side errors
5. **Database Verification**: Ensure the database is properly migrated and seeded

## 📡 API Endpoints Covered

### Authentication Endpoints
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User authentication

### Medical Store Endpoints
- `POST /api/medicalstores/register` - Register medical store
- `GET /api/medicalstores` - Get all medical stores
- `GET /api/medicalstores/{id}` - Get medical store by ID
- `PUT /api/medicalstores/{id}` - Update medical store
- `DELETE /api/medicalstores/{id}` - Delete medical store

### Customer Support Endpoints
- `POST /api/customersupports/register` - Register customer support
- `GET /api/customersupports` - Get all customer supports
- `GET /api/customersupports/{id}` - Get customer support by ID
- `POST /api/customersupports/{id}/photo` - Upload photo
- `PUT /api/customersupports/{id}` - Update customer support
- `DELETE /api/customersupports/{id}` - Delete customer support

### Manager Endpoints
- `POST /api/managers/register` - Register manager
- `GET /api/managers` - Get all managers
- `GET /api/managers/{id}` - Get manager by ID
- `POST /api/managers/{id}/photo` - Upload photo
- `PUT /api/managers/{id}` - Update manager
- `DELETE /api/managers/{id}` - Delete manager

### User Management Endpoints
- `GET /api/users` - Get all users
- `GET /api/users/{id}` - Get user by ID

### Customer Endpoints
- `POST /api/customers/register` - Register customer (anonymous)
- `POST /api/customers` - Create customer (admin)
- `GET /api/customers` - Get all customers
- `GET /api/customers/{id}` - Get customer by ID
- `GET /api/customers/by-mobile/{mobileNumber}` - Get customer by mobile
- `GET /api/customers/my-profile` - Get my profile
- `PUT /api/customers/{id}` - Update customer
- `DELETE /api/customers/{id}` - Delete customer

### Customer Address Endpoints
- `POST /api/customeraddresses` - Create customer address
- `GET /api/customeraddresses/{id}` - Get customer address by ID
- `GET /api/customeraddresses/customer/{customerId}` - Get addresses by customer ID
- `PUT /api/customeraddresses/{id}` - Update customer address
- `PUT /api/customeraddresses/{customerId}/default/{addressId}` - Set default address
- `DELETE /api/customeraddresses/{id}` - Delete customer address

## 🎯 Test Data

The collection uses realistic test data:

### Medical Store Data
- **Medical Name**: "Test Medical Store"
- **Owner**: John William Doe
- **Address**: 123 Main Street, Suite 100, Mumbai, Maharashtra 400001
- **Pharmacist**: Dr. Jane Smith
- **Registration Status**: true (GSTIN required)

### Customer Support Data
- **Name**: Alice Marie Johnson
- **Address**: 789 Customer Support Street, Delhi
- **Employee ID**: EMP001

### Manager Data
- **Name**: Bob Robert Wilson
- **Address**: 321 Manager Avenue, Bangalore, Karnataka
- **Employee ID**: MGR001

### Customer Data
- **Name**: John William Doe
- **Mobile**: 9876543210
- **Email**: john.doe@example.com
- **Date of Birth**: 1990-05-15
- **Gender**: Male
- **Addresses**: Includes address lines 1, 2, 3

### Customer Address Data
- **Address**: 123 Main Street
- **Address Line 1**: Building A
- **Address Line 2**: Floor 2
- **Address Line 3**: Unit 201
- **City**: Mumbai, Maharashtra
- **Postal Code**: 400001
- **Default**: true

## 📈 Performance Testing

The collection is designed for functional testing. For performance testing:

1. **Use Postman Runner** with multiple iterations
2. **Monitor response times** in the test results
3. **Check for memory leaks** during extended testing
4. **Test concurrent requests** using Postman's collection runner

## 🔄 Continuous Integration

To integrate with CI/CD pipelines:

1. **Install Newman** (Postman CLI): `npm install -g newman`
2. **Run collection via CLI**: `newman run MedicineDelivery_API_Tests.postman_collection.json`
3. **Generate reports**: `newman run collection.json --reporters html --reporter-html-export report.html`

## 📝 Notes

- **Generated Passwords**: All generated passwords are logged to the console for reference
- **Photo Uploads**: Uses sample base64 images for testing photo upload functionality
- **Soft Deletes**: Delete operations perform soft deletes (IsDeleted = true)
- **Authorization**: All endpoints require proper authentication tokens
- **Data Persistence**: Created data persists between test runs unless cleaned up

## 🤝 Support

If you encounter any issues:

1. **Check the troubleshooting section** above
2. **Verify your API setup** matches the requirements
3. **Review the console output** for detailed error messages
4. **Ensure all dependencies** are properly installed

---

**Happy Testing! 🚀**

This collection provides comprehensive testing for all Medicine Delivery API endpoints, ensuring your application works correctly across all modules.
