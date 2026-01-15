using Microsoft.AspNetCore.Http;

namespace MedicineDelivery.Infrastructure.Services
{
    public interface IBrowserInfoService
    {
        string GetUserAgent(HttpContext httpContext);
        string GetIpAddress(HttpContext httpContext);
        string? GetDeviceInfo(HttpContext httpContext);
    }

    public class BrowserInfoService : IBrowserInfoService
    {
        public string GetUserAgent(HttpContext httpContext)
        {
            return httpContext.Request.Headers["User-Agent"].ToString() ?? "Unknown";
        }

        public string GetIpAddress(HttpContext httpContext)
        {
            // Try to get IP from X-Forwarded-For header (for proxies/load balancers)
            var forwardedFor = httpContext.Request.Headers["X-Forwarded-For"].FirstOrDefault();
            if (!string.IsNullOrEmpty(forwardedFor))
            {
                var ips = forwardedFor.Split(',');
                if (ips.Length > 0)
                {
                    return ips[0].Trim();
                }
            }

            // Try X-Real-IP header
            var realIp = httpContext.Request.Headers["X-Real-IP"].FirstOrDefault();
            if (!string.IsNullOrEmpty(realIp))
            {
                return realIp;
            }

            // Fallback to RemoteIpAddress
            return httpContext.Connection.RemoteIpAddress?.ToString() ?? "Unknown";
        }

        public string? GetDeviceInfo(HttpContext httpContext)
        {
            var userAgent = GetUserAgent(httpContext);
            if (string.IsNullOrEmpty(userAgent) || userAgent == "Unknown")
            {
                return null;
            }

            // Basic device detection from User-Agent
            var deviceInfo = new System.Text.StringBuilder();

            if (userAgent.Contains("Mobile", StringComparison.OrdinalIgnoreCase) ||
                userAgent.Contains("Android", StringComparison.OrdinalIgnoreCase) ||
                userAgent.Contains("iPhone", StringComparison.OrdinalIgnoreCase) ||
                userAgent.Contains("iPad", StringComparison.OrdinalIgnoreCase))
            {
                deviceInfo.Append("Mobile Device; ");
            }
            else
            {
                deviceInfo.Append("Desktop; ");
            }

            // Extract browser info
            if (userAgent.Contains("Chrome", StringComparison.OrdinalIgnoreCase))
                deviceInfo.Append("Chrome");
            else if (userAgent.Contains("Firefox", StringComparison.OrdinalIgnoreCase))
                deviceInfo.Append("Firefox");
            else if (userAgent.Contains("Safari", StringComparison.OrdinalIgnoreCase))
                deviceInfo.Append("Safari");
            else if (userAgent.Contains("Edge", StringComparison.OrdinalIgnoreCase))
                deviceInfo.Append("Edge");
            else if (userAgent.Contains("Opera", StringComparison.OrdinalIgnoreCase))
                deviceInfo.Append("Opera");
            else
                deviceInfo.Append("Unknown Browser");

            return deviceInfo.ToString();
        }
    }
}