# MedicineDelivery API

Entity Framework
Generate Migration : dotnet ef migrations add AddOrderNumberAndCustomerAddressCoordinates --project MedicineDelivery.Infrastructure --startup-project MedicineDelivery.API
Generate Migration Script : dotnet ef migrations script InitialCreate AddOrderNumberAndCustomerAddressCoordinates --idempotent --project MedicineDelivery.Infrastructure --startup-project MedicineDelivery.API --output migration_script.sql

A .NET 8 Web API project with Clean Architecture, JWT-based authentication and permission-based authorization using ASP.NET Core Identity.

## Architecture

This project follows Clean Architecture principles with the following layers:

- **Domain Layer** (`MedicineDelivery.Domain`): Contains entities, interfaces, and business logic
- **Application Layer** (`MedicineDelivery.Application`): Contains use cases, DTOs, and application services
- **Infrastructure Layer** (`MedicineDelivery.Infrastructure`): Contains data access, external services, and implementations
- **Presentation Layer** (`MedicineDelivery.API`): Contains controllers, middleware, and API configuration

## Features

- Clean Architecture with separation of concerns
- JWT-based authentication
- Permission-based authorization
- ASP.NET Core Identity for user management
- Entity Framework Core with SQL Server
- CQRS pattern with MediatR
- AutoMapper for object mapping
- Swagger/OpenAPI documentation
- Role-based access control

## Getting Started

1. Make sure you have .NET 8 SDK installed
2. Update the connection string in `MedicineDelivery.API/appsettings.json` if needed
3. Run the following commands:

```bash
cd MedicineDelivery.API
dotnet restore
dotnet ef database update
dotnet run
```

## API Endpoints

### Authentication
- POST `/api/auth/login` - Login with email and password
- POST `/api/auth/register` - Register a new user

### Users (Requires authentication)
- GET `/api/users` - Get all users (Requires ReadUsers permission)
- GET `/api/users/{id}` - Get user by ID (Requires ReadUsers permission)
- POST `/api/users` - Create new user (Requires CreateUsers permission)
- PUT `/api/users/{id}` - Update user (Requires UpdateUsers permission)
- DELETE `/api/users/{id}` - Delete user (Requires DeleteUsers permission)
- GET `/api/users/{id}/permissions` - Get user permissions (Requires ReadUsers permission)
- POST `/api/users/{id}/permissions` - Grant permission to user (Requires UpdateUsers permission)

### Products (Requires authentication)
- GET `/api/products` - Get all products (Requires ReadProducts permission)
- GET `/api/products/{id}` - Get product by ID (Requires ReadProducts permission)
- POST `/api/products` - Create new product (Requires CreateProducts permission)
- PUT `/api/products/{id}` - Update product (Requires UpdateProducts permission)
- DELETE `/api/products/{id}` - Delete product (Requires DeleteProducts permission)

### Orders (Requires authentication)
- GET `/api/orders` - Get all orders (Requires ReadOrders permission)
- GET `/api/orders/{id}` - Get order by ID (Requires ReadOrders permission)
- POST `/api/orders` - Create new order (Requires CreateOrders permission)
- PUT `/api/orders/{id}` - Update order (Requires UpdateOrders permission)
- DELETE `/api/orders/{id}` - Delete order (Requires DeleteOrders permission)

## Default Users

The application creates two default users on startup:

1. Admin User
   - Email: admin@medimart.com
   - Password: Admin123!
   - Has all permissions

2. Regular User
   - Email: user@medimart.com
   - Password: User123!
   - Has read permissions only

## Permissions

The system includes the following permissions:

- ReadUsers, CreateUsers, UpdateUsers, DeleteUsers
- ReadProducts, CreateProducts, UpdateProducts, DeleteProducts
- ReadOrders, CreateOrders, UpdateOrders, DeleteOrders

## Authentication

To authenticate, send a POST request to `/api/auth/login` with:
```json
{
  "email": "admin@medimart.com",
  "password": "Admin123!"
}
```

The response will include a JWT token. Include this token in the Authorization header for protected endpoints:
```
Authorization: Bearer <your-jwt-token>
```

Add Mgration
Add-Migration RemovedOrderAndOrderItemTable

Generate Script
Script-Migration RemovedOrderAndOrderItemTable

Append script to API->MigrationScript->Migration_Script.sql