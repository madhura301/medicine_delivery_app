---
name: add-endpoint
description: Add a new API endpoint to an existing controller with full CQRS wiring
user_invocable: true
---

# Add Endpoint Skill

When the user invokes `/add-endpoint`, add a new API endpoint with complete backend wiring.

## Steps

1. Ask the user for:
   - Which controller (existing or new)
   - HTTP method (GET, POST, PUT, DELETE, PATCH)
   - Route pattern
   - What the endpoint should do
   - Required authorization/permissions

2. Create or update:

### Application Layer
- Command or Query class in appropriate `Features/{Feature}/` folder
- Handler class implementing the logic
- DTO for request/response if needed
- FluentValidation validator if the endpoint accepts input

### Infrastructure Layer
- Service method implementation (if new logic needed)
- Repository method (if new data access needed)

### API Layer
- Controller action method with:
  - Proper HTTP attribute (`[HttpGet]`, `[HttpPost]`, etc.)
  - `[Authorize(Policy = "...")]` if permission required
  - ProducesResponseType attributes
  - Thin implementation delegating to MediatR

## Rules
- Always use async/await
- Return proper HTTP status codes (200, 201, 204, 400, 404, etc.)
- Use MediatR `Send()` for CQRS dispatch
- Add authorization policy if the endpoint needs protection
- Validate input with FluentValidation
