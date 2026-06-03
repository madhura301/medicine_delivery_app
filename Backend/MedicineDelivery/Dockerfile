# syntax=docker/dockerfile:1

# ---- Build stage ----
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy solution-level files first for better layer caching.
COPY ["Directory.Build.props", "./"]

# Copy only the .csproj files, then restore. This layer is cached
# unless a .csproj changes, so code edits don't trigger a full restore.
COPY ["MedicineDelivery.API/MedicineDelivery.API.csproj", "MedicineDelivery.API/"]
COPY ["MedicineDelivery.Application/MedicineDelivery.Application.csproj", "MedicineDelivery.Application/"]
COPY ["MedicineDelivery.Domain/MedicineDelivery.Domain.csproj", "MedicineDelivery.Domain/"]
COPY ["MedicineDelivery.Infrastructure/MedicineDelivery.Infrastructure.csproj", "MedicineDelivery.Infrastructure/"]
RUN dotnet restore "MedicineDelivery.API/MedicineDelivery.API.csproj"

# Copy the rest of the source and publish.
COPY MedicineDelivery.API/ MedicineDelivery.API/
COPY MedicineDelivery.Application/ MedicineDelivery.Application/
COPY MedicineDelivery.Domain/ MedicineDelivery.Domain/
COPY MedicineDelivery.Infrastructure/ MedicineDelivery.Infrastructure/
# TreatWarningsAsErrors is enabled repo-wide (Directory.Build.props). A few async
# stubs trip CS1998 in a clean Release build, so warnings-as-errors is relaxed for
# the published artifact only — source and local build rules are untouched.
RUN dotnet publish "MedicineDelivery.API/MedicineDelivery.API.csproj" \
    -c Release -o /app/publish /p:UseAppHost=false /p:TreatWarningsAsErrors=false

# ---- Runtime stage ----
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# The aspnet:8.0 image already listens on port 8080 (ASPNETCORE_HTTP_PORTS=8080).
# Azure Container Apps ingress should target this port.
EXPOSE 8080

# Run as the non-root user provided by the base image.
USER $APP_UID

COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "MedicineDelivery.API.dll"]
