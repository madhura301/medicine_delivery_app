# 🔧 Troubleshooting 401 Unauthorized Errors

## Problem: Login works but all other APIs return 401

This is a common issue with JWT token authentication in Postman. Here's how to fix it:

## 🚀 Quick Fix Steps

### Step 1: Use the Debug Collection

I've created a simple debug collection (`test_auth_debug.postman_collection.json`) to help identify the issue:

1. **Import the debug collection**
2. **Run the 3 requests in order:**
   - Login and Get Token
   - Test Token - Get Users  
   - Test Medical Store Registration

### Step 2: Check Console Output

After running the debug collection, check the **Postman Console** (View → Show Postman Console) for:

```
✅ Expected Output:
- "Token set successfully: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
- "Success! Token is working"
- "Medical store registration successful"

❌ If you see errors:
- "No accessToken found in response"
- "401 Unauthorized - Token issue"
- "ERROR: No auth token available"
```

## 🔍 Common Issues and Solutions

### Issue 1: Token Not Being Set

**Problem:** Login succeeds but token isn't stored in environment variable.

**Solution:**
1. Check if the login response contains `accessToken` field
2. Verify the test script is running correctly
3. Check environment variable name matches

### Issue 2: Token Format Issues

**Problem:** Token is set but format is incorrect.

**Check:**
- Token should start with `eyJ` (base64 encoded JWT)
- No extra spaces or characters
- Should be a single string

### Issue 3: Authorization Header Format

**Problem:** Authorization header not formatted correctly.

**Correct Format:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Common Mistakes:**
- Missing "Bearer " prefix
- Extra spaces
- Wrong header name (should be "Authorization")

### Issue 4: API Server Issues

**Problem:** API server not properly configured for JWT.

**Check:**
1. **JWT Configuration** in `Program.cs`:
```csharp
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options => {
        // JWT configuration
    });
```

2. **Authorization Policies** are properly set up

3. **Controllers** have `[Authorize]` attributes

## 🛠️ Manual Testing Steps

### Step 1: Test Login Manually

```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@test.com","password":"Admin@123"}'
```

**Expected Response:**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "userId": "some-guid",
  "expiresAt": "2025-09-19T20:30:00Z"
}
```

### Step 2: Test with Token

```bash
curl -X GET http://localhost:5000/api/users \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## 🔧 Postman-Specific Fixes

### Fix 1: Environment Variables

1. **Create Environment:**
   - Click gear icon (⚙️) in top-right
   - Click "Add" to create new environment
   - Add variable: `auth_token` with empty value

2. **Select Environment:**
   - Make sure the environment is selected in dropdown

### Fix 2: Authorization Setup

**Option A: Collection Level (Recommended)**
1. Right-click collection → "Edit"
2. Go to "Authorization" tab
3. Type: "Bearer Token"
4. Token: `{{auth_token}}`

**Option B: Request Level**
1. Go to each request
2. Click "Authorization" tab
3. Type: "Bearer Token"  
4. Token: `{{auth_token}}`

**Option C: Header Level**
1. Go to "Headers" tab
2. Add header:
   - Key: `Authorization`
   - Value: `Bearer {{auth_token}}`

### Fix 3: Test Scripts

Make sure login requests have this test script:

```javascript
pm.test("Set auth token", function () {
    if (pm.response.code === 200) {
        const jsonData = pm.response.json();
        if (jsonData.accessToken) {
            pm.environment.set('auth_token', jsonData.accessToken);
            console.log('Token set:', jsonData.accessToken);
        }
    }
});
```

## 🚨 Emergency Fix

If nothing else works, try this manual approach:

1. **Run login request**
2. **Copy the token from response**
3. **Manually set environment variable:**
   - Go to environment settings
   - Set `auth_token` to the copied token
4. **Run other requests**

## 📋 Checklist

- [ ] API server is running on `http://localhost:5000`
- [ ] Login request returns 200 with `accessToken`
- [ ] Environment variable `auth_token` is set
- [ ] Environment is selected in Postman
- [ ] Authorization header format: `Bearer {{auth_token}}`
- [ ] Token starts with `eyJ`
- [ ] No extra spaces in token or header

## 🆘 Still Having Issues?

1. **Check API Console** for server-side errors
2. **Verify Database** is running and migrated
3. **Check JWT Secret** in `appsettings.json`
4. **Test with curl** to isolate Postman issues
5. **Check Postman Console** for detailed error messages

---

**Run the debug collection first - it will tell you exactly what's wrong! 🔍**
