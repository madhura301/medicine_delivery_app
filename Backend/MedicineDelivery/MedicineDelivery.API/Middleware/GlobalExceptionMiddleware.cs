using System.Net;
using System.Security.Claims;
using System.Text.Json;
using MedicineDelivery.Domain.Exceptions;

namespace MedicineDelivery.API.Middleware
{
    public class GlobalExceptionMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<GlobalExceptionMiddleware> _logger;

        public GlobalExceptionMiddleware(RequestDelegate next, ILogger<GlobalExceptionMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            try
            {
                await _next(context);
            }
            catch (Exception ex)
            {
                var userId = context.User?.FindFirstValue(ClaimTypes.NameIdentifier) 
                    ?? context.User?.FindFirstValue("sub") 
                    ?? "anonymous";
                var traceId = context.TraceIdentifier;

                _logger.LogError(ex,
                    "Unhandled exception. TraceId: {TraceId}, UserId: {UserId}, " +
                    "Request: {Method} {Path}{QueryString}, ContentType: {ContentType}, " +
                    "ExceptionType: {ExceptionType}",
                    traceId,
                    userId,
                    context.Request.Method,
                    context.Request.Path,
                    context.Request.QueryString,
                    context.Request.ContentType,
                    ex.GetType().Name);

                await HandleExceptionAsync(context, ex);
            }
        }

        private static async Task HandleExceptionAsync(HttpContext context, Exception exception)
        {
            context.Response.ContentType = "application/json";
            var traceId = context.TraceIdentifier;

            object response;

            if (exception is PaymentIncompleteException paymentEx)
            {
                context.Response.StatusCode = StatusCodes.Status402PaymentRequired;
                response = new
                {
                    error = "PaymentIncomplete",
                    message = paymentEx.Message,
                    orderId = paymentEx.OrderId,
                    totalAmount = paymentEx.TotalAmount,
                    paidAmount = paymentEx.PaidAmount,
                    remainingAmount = paymentEx.RemainingAmount,
                    traceId,
                    timestamp = DateTime.UtcNow
                };
            }
            else
            {
                context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
                response = new
                {
                    error = "An internal server error occurred",
                    message = exception.Message,
                    traceId,
                    timestamp = DateTime.UtcNow
                };
            }

            var jsonResponse = JsonSerializer.Serialize(response, new JsonSerializerOptions
            {
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase
            });

            await context.Response.WriteAsync(jsonResponse);
        }
    }
}
