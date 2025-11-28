# Medicine Delivery API - Postman Collection

## Overview
This Postman collection contains all API endpoints for the Medicine Delivery Application, including the latest endpoints from OrdersController and SetupController.

## File Location
- **Collection File**: `MedicineDelivery_API.postman_collection.json`

## Import Instructions
1. Open Postman
2. Click **Import** button
3. Select `MedicineDelivery_API.postman_collection.json`
4. The collection will be imported with all endpoints organized by controller

## Collection Variables
The collection includes the following variables that you can set:

- `baseUrl`: API base URL (default: `http://localhost:5000`)
- `token`: JWT authentication token (auto-set after login)
- `customerId`: Customer GUID for testing
- `orderId`: Order ID for testing
- `medicalStoreId`: Medical Store GUID for testing
- `addressId`: Address ID for testing
- `productId`: Product ID for testing
- `managerId`: Manager ID for testing
- `customerSupportId`: Customer Support ID for testing
- `roleId`: Role ID for testing

## Test Scripts
The collection includes automated test scripts for:
- **Login**: Automatically saves token to collection variable
- **Get Orders By Customer ID**: Validates response and saves orderId
- **Get Active Orders By Medical Store ID**: Validates all orders are not Completed
- **Accept Order By Chemist**: Validates order status is AcceptedByChemist
- **Reject Order By Chemist**: Validates order status is RejectedByChemist
- **User Creation Endpoints**: Validates successful creation or existing user

## Latest Endpoints Included

### Orders Controller
1. **GET** `/api/orders/{orderId}` - Get order by ID
2. **GET** `/api/orders/customer/{customerId}` - Get all orders by customer ID ⭐ NEW
3. **GET** `/api/orders/medicalstore/{medicalStoreId}/active` - Get active orders by medical store ⭐ NEW
4. **PUT** `/api/orders/{orderId}/accept` - Accept order by chemist ⭐ NEW
5. **PUT** `/api/orders/{orderId}/reject` - Reject order by chemist with note ⭐ NEW
6. **POST** `/api/orders` - Create new order

### Setup Controller
1. **POST** `/api/setup/users/admin/firstuser` - Create admin first user ⭐ NEW
2. **POST** `/api/setup/users/admin` - Create admin user ⭐ NEW
3. **POST** `/api/setup/users/manager` - Create manager user ⭐ NEW
4. **POST** `/api/setup/users/customer-support` - Create customer support user ⭐ NEW
5. **POST** `/api/setup/users/customer` - Create customer user ⭐ NEW
6. **POST** `/api/setup/users/chemist` - Create chemist user ⭐ NEW

## Predefined User Credentials

### Admin First User
- **Mobile**: `8793583675`
- **Email**: `dipmala.patil@medicine.com`
- **Password**: `Admin@123`

### Admin User
- **Mobile**: `9999999999`
- **Email**: `admin@medicine.com`
- **Password**: `Admin@123`

### Manager User
- **Mobile**: `8888888888`
- **Email**: `manager@medicine.com`
- **Password**: `Manager@123`

### CustomerSupport User
- **Mobile**: `7777777777`
- **Email**: `support@medicine.com`
- **Password**: `Support@123`

### Customer User
- **Mobile**: `6666666666`
- **Email**: `customer@medicine.com`
- **Password**: `Customer@123`

### Chemist User
- **Mobile**: `5555555555`
- **Email**: `chemist@medicine.com`
- **Password**: `Chemist@123`

## Testing Workflow

### 1. Setup (Run once)
1. **Create Predefined Roles**: `POST /api/setup/roles/predefined`
2. **Create Predefined Permissions**: `POST /api/setup/permissions/predefined`
3. **Map Role Permissions**: `POST /api/setup/role-permissions/predefined`
4. **Create Users**: Run the user creation endpoints for each role

### 2. Authentication
1. **Login**: Use any of the predefined user credentials
2. Token will be automatically saved to `{{token}}` variable

### 3. Test Orders
1. **Create Order**: Create a new order (requires customer and address)
2. **Get Orders By Customer**: Retrieve all orders for a customer
3. **Get Active Orders**: Get active orders for a medical store
4. **Accept/Reject Order**: Test order acceptance/rejection (requires order with AssignedToChemist status)

## Example Test Data

### Create Order Request
```json
{
  "CustomerId": "00000000-0000-0000-0000-000000000001",
  "CustomerAddressId": "00000000-0000-0000-0000-000000000001",
  "OrderType": 0,
  "OrderInputType": 0,
  "OrderInputText": "Paracetamol 500mg x 2, Aspirin 100mg x 1"
}
```

### Reject Order Request
```json
{
  "rejectNote": "Unable to fulfill order due to stock unavailability"
}
```

## Running Tests
1. Select a request in the collection
2. Click **Send**
3. View test results in the **Test Results** tab
4. Check collection variables to see auto-saved values

## Notes
- All endpoints requiring authentication use `Bearer {{token}}` in the Authorization header
- Test scripts automatically validate responses and save relevant data to variables
- User creation endpoints return 409 (Conflict) if user already exists
- Order accept/reject endpoints only work with orders in `AssignedToChemist` status

