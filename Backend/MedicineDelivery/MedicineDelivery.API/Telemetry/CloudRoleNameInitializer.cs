using Microsoft.ApplicationInsights.Channel;
using Microsoft.ApplicationInsights.DataContracts;
using Microsoft.ApplicationInsights.Extensibility;

namespace MedicineDelivery.API.Telemetry
{
    /// <summary>
    /// Stamps every telemetry item with the deployment it came from, so test and production
    /// can be told apart while sharing one Application Insights resource.
    ///
    /// Sets:
    ///   • <c>cloud_RoleName</c>  — the standard dimension (e.g. "pharmaish-api-prod");
    ///   • custom property <c>DeploymentEnvironment</c> — "Production" / "Test" / "Local".
    ///
    /// Configure per environment with the <c>DeploymentEnvironment</c> and
    /// <c>CloudRoleName</c> settings (env vars on Azure Container Apps).
    /// </summary>
    public class CloudRoleNameInitializer : ITelemetryInitializer
    {
        private readonly string _roleName;
        private readonly string _deploymentEnvironment;

        public CloudRoleNameInitializer(string roleName, string deploymentEnvironment)
        {
            _roleName = roleName;
            _deploymentEnvironment = deploymentEnvironment;
        }

        public void Initialize(ITelemetry telemetry)
        {
            if (!string.IsNullOrWhiteSpace(_roleName))
            {
                telemetry.Context.Cloud.RoleName = _roleName;
            }

            if (telemetry is ISupportProperties supportProperties &&
                !supportProperties.Properties.ContainsKey("DeploymentEnvironment"))
            {
                supportProperties.Properties["DeploymentEnvironment"] = _deploymentEnvironment;
            }
        }
    }
}
