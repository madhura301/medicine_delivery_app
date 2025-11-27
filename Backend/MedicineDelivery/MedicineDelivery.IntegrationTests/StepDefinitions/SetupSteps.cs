using System.Net;
using FluentAssertions;
using MedicineDelivery.IntegrationTests.Support;
using TechTalk.SpecFlow;

namespace MedicineDelivery.IntegrationTests.StepDefinitions;

[Binding]
public class SetupSteps
{
    private readonly TestContext _context;

    public SetupSteps(TestContext context)
    {
        _context = context;
    }

    [When(@"I call the endpoint to create predefined roles")]
    public async Task WhenICallTheEndpointToCreatePredefinedRoles()
    {
        _context.LastResponse = await _context.Client.PostAsync("/api/setup/roles/predefined", null);
    }

    [When(@"I call the endpoint to create predefined permissions")]
    public async Task WhenICallTheEndpointToCreatePredefinedPermissions()
    {
        _context.LastResponse = await _context.Client.PostAsync("/api/setup/permissions/predefined", null);
    }

    [Given(@"predefined roles exist")]
    public async Task GivenPredefinedRolesExist()
    {
        var response = await _context.Client.PostAsync("/api/setup/roles/predefined", null);
        response.EnsureSuccessStatusCode();
    }

    [Given(@"predefined permissions exist")]
    public async Task GivenPredefinedPermissionsExist()
    {
        var response = await _context.Client.PostAsync("/api/setup/permissions/predefined", null);
        response.EnsureSuccessStatusCode();
    }

    [When(@"I call the endpoint to map roles to permissions")]
    public async Task WhenICallTheEndpointToMapRolesToPermissions()
    {
        _context.LastResponse = await _context.Client.PostAsync("/api/setup/role-permissions/predefined", null);
    }

    [Then(@"the response should indicate roles were created")]
    public async Task ThenTheResponseShouldIndicateRolesWereCreated()
    {
        var content = await _context.LastResponse!.Content.ReadAsStringAsync();
        content.Should().ContainAny("created", "already exists", "skipped");
    }

    [Then(@"the response should indicate permissions were created")]
    public async Task ThenTheResponseShouldIndicatePermissionsWereCreated()
    {
        var content = await _context.LastResponse!.Content.ReadAsStringAsync();
        content.Should().ContainAny("created", "already exists", "skipped");
    }

    [Then(@"the response should indicate mappings were created")]
    public async Task ThenTheResponseShouldIndicateMappingsWereCreated()
    {
        var content = await _context.LastResponse!.Content.ReadAsStringAsync();
        content.Should().ContainAny("created", "already exists", "mapped");
    }
}

