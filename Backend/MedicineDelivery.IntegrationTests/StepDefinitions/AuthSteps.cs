using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using FluentAssertions;
using MedicineDelivery.IntegrationTests.Infrastructure;
using MedicineDelivery.IntegrationTests.Support;
using TechTalk.SpecFlow;

namespace MedicineDelivery.IntegrationTests.StepDefinitions;

[Binding]
public class AuthSteps
{
    private readonly TestContext _context;
    private readonly TestConfiguration _config;

    public AuthSteps(TestContext context)
    {
        _context = context;
        _config = TestConfiguration.Instance;
    }

    [Given(@"the API is running")]
    public void GivenTheApiIsRunning()
    {
        if (_config.UseExternalApi)
        {
            // Use external API running in another Visual Studio instance
            _context.Client = new HttpClient
            {
                BaseAddress = new Uri(_config.ExternalApiBaseUrl)
            };
            Console.WriteLine($"Using external API at: {_config.ExternalApiBaseUrl}");
        }
        else
        {
            // Use in-memory test server
            _context.Factory = new TestWebApplicationFactory();
            _context.Client = _context.Factory.CreateClient();
            Console.WriteLine("Using in-memory test server");
        }
    }

    [Given(@"I have registration data with mobile number ""(.*)"" and password ""(.*)""")]
    public void GivenIHaveRegistrationData(string mobileNumber, string password)
    {
        // Store registration data in test context
        _context.MobileNumber = mobileNumber;
        _context.Password = password;
    }

    [Given(@"a user exists with mobile number ""(.*)"" and password ""(.*)""")]
    public async Task GivenAUserExists(string mobileNumber, string password)
    {
        // First register the user
        var registrationData = new
        {
            MobileNumber = mobileNumber,
            Email = $"{mobileNumber}@test.com",
            Password = password,
            FirstName = "Test",
            LastName = "User"
        };

        var response = await _context.Client.PostAsJsonAsync("/api/auth/register", registrationData);
        
        if (!response.IsSuccessStatusCode)
        {
            var errorContent = await response.Content.ReadAsStringAsync();
            throw new Exception($"Registration failed with status {response.StatusCode}: {errorContent}");
        }
    }

    [When(@"I register a new user")]
    public async Task WhenIRegisterANewUser()
    {
        var mobileNumber = _context.MobileNumber!;
        var password = _context.Password!;

        var registrationData = new
        {
            MobileNumber = mobileNumber,
            Email = $"{mobileNumber}@test.com",
            Password = password,
            FirstName = "Test",
            LastName = "User"
        };

        _context.LastResponse = await _context.Client.PostAsJsonAsync("/api/auth/register", registrationData);
    }

    [When(@"I login with mobile number ""(.*)"" and password ""(.*)""")]
    public async Task WhenILoginWithMobileNumberAndPassword(string mobileNumber, string password)
    {
        var loginData = new
        {
            MobileNumber = mobileNumber,
            Password = password
        };

        _context.LastResponse = await _context.Client.PostAsJsonAsync("/api/auth/login", loginData);
    }

    [Then(@"the response status should be (\d+)")]
    public void ThenTheResponseStatusShouldBe(int expectedStatus)
    {
        _context.LastResponse.Should().NotBeNull();
        _context.LastResponse!.StatusCode.Should().Be((HttpStatusCode)expectedStatus);
    }

    [Then(@"the response should contain user information")]
    public async Task ThenTheResponseShouldContainUserInformation()
    {
        var content = await _context.LastResponse!.Content.ReadAsStringAsync();
        content.Should().Contain("token");
    }

    [Then(@"the response should contain a JWT token")]
    public async Task ThenTheResponseShouldContainAJwtToken()
    {
        var content = await _context.LastResponse!.Content.ReadAsStringAsync();
        var json = JsonDocument.Parse(content);
        
        json.RootElement.TryGetProperty("token", out var tokenProperty).Should().BeTrue();
        tokenProperty.GetString().Should().NotBeNullOrEmpty();
        
        // Store token for future requests
        _context.AuthToken = tokenProperty.GetString();
    }
}

