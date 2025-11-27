using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using FluentAssertions;
using MedicineDelivery.IntegrationTests.Support;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.DependencyInjection;
using TechTalk.SpecFlow;

namespace MedicineDelivery.IntegrationTests.StepDefinitions;

[Binding]
public class CustomerSteps
{
    private readonly TestContext _context;

    public CustomerSteps(TestContext context)
    {
        _context = context;
    }

    [Given(@"I have customer registration data with mobile number ""(.*)""")]
    public void GivenIHaveCustomerRegistrationData(string mobileNumber)
    {
        _context.MobileNumber = mobileNumber;
    }

    [Given(@"a customer exists with mobile number ""(.*)"" and password ""(.*)""")]
    public async Task GivenACustomerExists(string mobileNumber, string password)
    {
        // Register the customer
        var registrationData = new
        {
            CustomerFirstName = "John",
            CustomerLastName = "Doe",
            MobileNumber = mobileNumber,
            Password = password,
            EmailId = $"{mobileNumber}@test.com",
            DateOfBirth = new DateTime(1990, 1, 1),
            Gender = "Male",
            Addresses = new[]
            {
                new
                {
                    AddressLine1 = "123 Main St",
                    City = "Test City",
                    State = "Test State",
                    PostalCode = "12345",
                    IsDefault = true
                }
            }
        };

        var response = await _context.Client.PostAsJsonAsync("/api/customers/register", registrationData);
        
        if (!response.IsSuccessStatusCode)
        {
            var errorContent = await response.Content.ReadAsStringAsync();
            throw new Exception($"Customer registration failed with status {response.StatusCode}: {errorContent}");
        }

        var content = await response.Content.ReadAsStringAsync();
        var json = JsonDocument.Parse(content);
        
        // The response from CreatedAtAction wraps the result in a "value" property
        // Try to find customerId in various possible locations
        JsonElement root = json.RootElement;
        
        // Check if response is wrapped in "value" (CreatedAtAction does this)
        if (root.TryGetProperty("value", out var valueElement))
        {
            root = valueElement;
        }
        
        // Try to find customer object
        JsonElement customerElement = root;
        if (root.TryGetProperty("customer", out var customerProp))
        {
            customerElement = customerProp;
        }
        else if (root.TryGetProperty("Customer", out var customerPropUpper))
        {
            customerElement = customerPropUpper;
        }
        
        // Extract customerId
        if (customerElement.TryGetProperty("customerId", out var customerIdElement))
        {
            _context.CustomerId = Guid.Parse(customerIdElement.GetString()!);
        }
        else if (customerElement.TryGetProperty("CustomerId", out var customerIdElementUpper))
        {
            _context.CustomerId = Guid.Parse(customerIdElementUpper.GetString()!);
        }
        else
        {
            // If we couldn't find customerId, log the response for debugging
            throw new Exception($"Could not extract customerId from registration response. Response: {content}");
        }
    }

    [Given(@"another customer exists with mobile number ""(.*)"" and password ""(.*)""")]
    public async Task GivenAnotherCustomerExists(string mobileNumber, string password)
    {
        // Store the first customer ID before creating the second one
        var firstCustomerId = _context.CustomerId;
        await GivenACustomerExists(mobileNumber, password);
        _context.SecondCustomerId = _context.CustomerId;
        // Restore first customer ID if it was set
        if (firstCustomerId.HasValue)
        {
            _context.CustomerId = firstCustomerId;
        }
    }

    [Given(@"an admin user exists with mobile number ""(.*)"" and password ""(.*)""")]
    public async Task GivenAnAdminUserExists(string mobileNumber, string password)
    {
        // Store admin credentials
        _context.AdminMobileNumber = mobileNumber;
        _context.AdminPassword = password;

        // First register the user
        var registrationData = new
        {
            MobileNumber = mobileNumber,
            Email = $"{mobileNumber}@test.com",
            Password = password,
            FirstName = "Admin",
            LastName = "User"
        };

        var response = await _context.Client.PostAsJsonAsync("/api/auth/register", registrationData);
        
        if (!response.IsSuccessStatusCode)
        {
            var errorContent = await response.Content.ReadAsStringAsync();
            throw new Exception($"Admin user registration failed with status {response.StatusCode}: {errorContent}");
        }

        // Assign Admin role using the test factory's service provider
        using var scope = _context.Factory.Services.CreateScope();
        var userManager = scope.ServiceProvider.GetRequiredService<UserManager<MedicineDelivery.Domain.Entities.ApplicationUser>>();
        var roleManager = scope.ServiceProvider.GetRequiredService<RoleManager<IdentityRole>>();
        
        var user = await userManager.FindByNameAsync(mobileNumber);
        if (user != null)
        {
            // Ensure Admin role exists
            if (!await roleManager.RoleExistsAsync("Admin"))
            {
                await roleManager.CreateAsync(new IdentityRole("Admin"));
            }
            
            // Assign Admin role to user
            if (!await userManager.IsInRoleAsync(user, "Admin"))
            {
                await userManager.AddToRoleAsync(user, "Admin");
            }
        }
    }

    [Given(@"I am logged in as the customer with mobile number ""(.*)"" and password ""(.*)""")]
    public async Task GivenIAmLoggedInAsTheCustomer(string mobileNumber, string password)
    {
        await GivenIAmLoggedIn(mobileNumber, password);
    }

    [Given(@"I am logged in as the admin user")]
    public async Task GivenIAmLoggedInAsTheAdminUser()
    {
        // This assumes the admin user was created in a previous step
        // We'll need to track the admin credentials
        if (string.IsNullOrEmpty(_context.AdminMobileNumber) || string.IsNullOrEmpty(_context.AdminPassword))
        {
            throw new Exception("Admin user credentials not set. Please create admin user first.");
        }
        
        await GivenIAmLoggedIn(_context.AdminMobileNumber, _context.AdminPassword);
    }

    [Given(@"I am logged in as the second customer with mobile number ""(.*)"" and password ""(.*)""")]
    public async Task GivenIAmLoggedInAsTheSecondCustomer(string mobileNumber, string password)
    {
        await GivenIAmLoggedIn(mobileNumber, password);
    }

    private async Task GivenIAmLoggedIn(string mobileNumber, string password)
    {
        var loginData = new
        {
            MobileNumber = mobileNumber,
            Password = password
        };

        var response = await _context.Client.PostAsJsonAsync("/api/auth/login", loginData);
        
        if (!response.IsSuccessStatusCode)
        {
            var errorContent = await response.Content.ReadAsStringAsync();
            throw new Exception($"Login failed with status {response.StatusCode}: {errorContent}");
        }

        var content = await response.Content.ReadAsStringAsync();
        var json = JsonDocument.Parse(content);
        
        if (json.RootElement.TryGetProperty("token", out var tokenProperty))
        {
            _context.AuthToken = tokenProperty.GetString();
            _context.Client.DefaultRequestHeaders.Authorization = 
                new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", _context.AuthToken);
        }
        else
        {
            throw new Exception("Token not found in login response");
        }
    }

    [Given(@"I have the customer ID")]
    public void GivenIHaveTheCustomerId()
    {
        // Customer ID should already be set from previous steps
        _context.CustomerId.Should().NotBeEmpty("Customer ID should be set from previous steps");
    }

    [Given(@"I have the first customer ID")]
    public void GivenIHaveTheFirstCustomerId()
    {
        // The first customer ID should already be stored in _context.CustomerId
        // (the "another customer exists" step preserves it)
        _context.CustomerId.Should().NotBeEmpty("First customer ID should be set from previous steps");
    }

    [Given(@"I have customer creation data with mobile number ""(.*)""")]
    public void GivenIHaveCustomerCreationData(string mobileNumber)
    {
        _context.MobileNumber = mobileNumber;
    }

    [Given(@"I have customer update data")]
    public void GivenIHaveCustomerUpdateData()
    {
        // Update data will be used in When steps
        _context.UpdateData = new
        {
            CustomerFirstName = "Jane",
            CustomerLastName = "Updated",
            MobileNumber = _context.MobileNumber ?? "0000000000",
            EmailId = $"{_context.MobileNumber}@updated.com",
            DateOfBirth = new DateTime(1995, 5, 15),
            Gender = "Female",
            IsActive = true
        };
    }

    [When(@"I register a new customer")]
    public async Task WhenIRegisterANewCustomer()
    {
        var registrationData = new
        {
            CustomerFirstName = "John",
            CustomerLastName = "Doe",
            MobileNumber = _context.MobileNumber,
            Password = "Test@123",
            EmailId = $"{_context.MobileNumber}@test.com",
            DateOfBirth = new DateTime(1990, 1, 1),
            Gender = "Male",
            Addresses = new[]
            {
                new
                {
                    AddressLine1 = "123 Main St",
                    City = "Test City",
                    State = "Test State",
                    PostalCode = "12345",
                    IsDefault = true
                }
            }
        };

        _context.LastResponse = await _context.Client.PostAsJsonAsync("/api/customers/register", registrationData);
    }

    [When(@"I request my profile")]
    public async Task WhenIRequestMyProfile()
    {
        _context.LastResponse = await _context.Client.GetAsync("/api/customers/my-profile");
    }

    [When(@"I request all customers")]
    public async Task WhenIRequestAllCustomers()
    {
        _context.LastResponse = await _context.Client.GetAsync("/api/customers");
    }

    [When(@"I request the customer by ID")]
    public async Task WhenIRequestTheCustomerById()
    {
        _context.LastResponse = await _context.Client.GetAsync($"/api/customers/{_context.CustomerId}");
    }

    [When(@"I request the customer by mobile number ""(.*)""")]
    public async Task WhenIRequestTheCustomerByMobileNumber(string mobileNumber)
    {
        _context.LastResponse = await _context.Client.GetAsync($"/api/customers/by-mobile/{mobileNumber}");
    }

    [When(@"I create a new customer")]
    public async Task WhenICreateANewCustomer()
    {
        var createData = new
        {
            CustomerFirstName = "New",
            CustomerLastName = "Customer",
            MobileNumber = _context.MobileNumber,
            EmailId = $"{_context.MobileNumber}@test.com",
            DateOfBirth = new DateTime(1990, 1, 1),
            Gender = "Male",
            Addresses = new[]
            {
                new
                {
                    AddressLine1 = "456 New St",
                    City = "New City",
                    State = "New State",
                    PostalCode = "54321",
                    IsDefault = true
                }
            }
        };

        _context.LastResponse = await _context.Client.PostAsJsonAsync("/api/customers", createData);
    }

    [When(@"I update my customer profile")]
    public async Task WhenIUpdateMyCustomerProfile()
    {
        // First get the customer ID from my profile
        var profileResponse = await _context.Client.GetAsync("/api/customers/my-profile");
        if (profileResponse.IsSuccessStatusCode)
        {
            var content = await profileResponse.Content.ReadAsStringAsync();
            var json = JsonDocument.Parse(content);
            if (json.RootElement.TryGetProperty("customerId", out var customerIdElement))
            {
                _context.CustomerId = Guid.Parse(customerIdElement.GetString()!);
            }
        }

        _context.LastResponse = await _context.Client.PutAsJsonAsync(
            $"/api/customers/{_context.CustomerId}", 
            _context.UpdateData);
    }

    [When(@"I update the customer by ID")]
    public async Task WhenIUpdateTheCustomerById()
    {
        _context.LastResponse = await _context.Client.PutAsJsonAsync(
            $"/api/customers/{_context.CustomerId}", 
            _context.UpdateData);
    }

    [When(@"I delete the customer by ID")]
    public async Task WhenIDeleteTheCustomerById()
    {
        _context.LastResponse = await _context.Client.DeleteAsync($"/api/customers/{_context.CustomerId}");
    }

    [When(@"I request all customers without authentication")]
    public async Task WhenIRequestAllCustomersWithoutAuthentication()
    {
        // Clear any existing authorization header
        _context.Client.DefaultRequestHeaders.Authorization = null;
        _context.LastResponse = await _context.Client.GetAsync("/api/customers");
    }

    [When(@"I request the first customer by ID")]
    public async Task WhenIRequestTheFirstCustomerById()
    {
        // Use the first customer ID (stored in _context.CustomerId)
        _context.LastResponse = await _context.Client.GetAsync($"/api/customers/{_context.CustomerId}");
    }

    [Then(@"the response should contain customer information")]
    public async Task ThenTheResponseShouldContainCustomerInformation()
    {
        var content = await _context.LastResponse!.Content.ReadAsStringAsync();
        content.Should().Contain("customerId");
        content.Should().Contain("customerFirstName");
    }

    [Then(@"the response should contain my customer information")]
    public async Task ThenTheResponseShouldContainMyCustomerInformation()
    {
        var content = await _context.LastResponse!.Content.ReadAsStringAsync();
        content.Should().Contain("customerId");
        content.Should().Contain("customerFirstName");
        
        // Store customer ID for future use
        var json = JsonDocument.Parse(content);
        if (json.RootElement.TryGetProperty("customerId", out var customerIdElement))
        {
            _context.CustomerId = Guid.Parse(customerIdElement.GetString()!);
        }
    }

    [Then(@"the response should contain a list of customers")]
    public async Task ThenTheResponseShouldContainAListOfCustomers()
    {
        var content = await _context.LastResponse!.Content.ReadAsStringAsync();
        var json = JsonDocument.Parse(content);
        json.RootElement.ValueKind.Should().Be(JsonValueKind.Array);
    }

    [Then(@"the response should contain the customer information")]
    public async Task ThenTheResponseShouldContainTheCustomerInformation()
    {
        var content = await _context.LastResponse!.Content.ReadAsStringAsync();
        content.Should().Contain("customerId");
    }

    [Then(@"the response should contain the created customer information")]
    public async Task ThenTheResponseShouldContainTheCreatedCustomerInformation()
    {
        var content = await _context.LastResponse!.Content.ReadAsStringAsync();
        content.Should().Contain("customerId");
        
        // Store customer ID
        var json = JsonDocument.Parse(content);
        if (json.RootElement.TryGetProperty("customerId", out var customerIdElement))
        {
            _context.CustomerId = Guid.Parse(customerIdElement.GetString()!);
        }
    }

    [Then(@"the response should contain the updated customer information")]
    public async Task ThenTheResponseShouldContainTheUpdatedCustomerInformation()
    {
        var content = await _context.LastResponse!.Content.ReadAsStringAsync();
        content.Should().Contain("customerId");
        content.Should().Contain("Updated"); // Check for updated last name
    }
}
