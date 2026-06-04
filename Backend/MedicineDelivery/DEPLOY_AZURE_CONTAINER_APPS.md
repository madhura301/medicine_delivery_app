# Deploy API to Azure Container Apps (low-cost test environment)

Target setup:
- **API** → Azure Container Apps (scale-to-zero, ~$0 within the monthly free grant)
- **Image registry** → Docker Hub (1 free private repo)
- **Database** → Azure PostgreSQL Flexible Server, `B1ms` burstable (~$13/mo; stop it between test sessions to save more)
- **Blob storage** → existing `pharmaishblobstorage`

Estimated total: **~$13/mo** (database only).

> No application code changes are required. ASP.NET Core reads environment variables by
> default, and nested keys use a double underscore (`__`). So every value in
> `appsettings.json` can be overridden in Container Apps without rebuilding the image.

---

## 1. Build and push the image to Docker Hub

Run from the solution folder: `Backend/MedicineDelivery/` (where the `Dockerfile` lives).

```bash
# Log in (use a Docker Hub Access Token, not your password)
docker login -u <your-dockerhub-username>

# Build (tag = <username>/<repo>:<tag>)
docker build -t <your-dockerhub-username>/pharmaish-api:latest .

# Push
docker push <your-dockerhub-username>/pharmaish-api:latest
```

Then on hub.docker.com, set the `pharmaish-api` repository to **Private**.

Create an **Access Token** at: Docker Hub → Account Settings → Security → New Access Token.
You'll use this token (not your password) as the registry password in Container Apps.

---

## 2. Connect to your PostgreSQL Flexible Server

> You are creating the PostgreSQL instance manually in the Azure Portal. Once it exists,
> make sure of the following so Container Apps can reach it:
>
> - Networking → **Allow public access** is enabled and
>   **"Allow public access from any Azure service within Azure"** is checked.
> - A database exists on the server (e.g. `pharmaish`).

Build the connection string (Npgsql format):

```
Host=<server-name>.postgres.database.azure.com;Port=5432;Database=pharmaish;Username=<admin>;Password=<password>;SSL Mode=Require;Trust Server Certificate=true
```

> Azure PostgreSQL requires SSL — note the `SSL Mode=Require;Trust Server Certificate=true`
> at the end (your local connection string did not have this).

### Apply the schema (migrations)

The app does not auto-migrate on startup. Apply migrations once from your machine,
pointing EF at the Azure DB:

```bash
# PowerShell example — set the connection string as an env var, then update the DB
$env:ConnectionStrings__PostgresConnection = "Host=<server>.postgres.database.azure.com;Port=5432;Database=pharmaish;Username=<admin>;Password=<pw>;SSL Mode=Require;Trust Server Certificate=true"
dotnet ef database update --project MedicineDelivery.Infrastructure --startup-project MedicineDelivery.API
```

---

## 3. Create the Container App (Portal)

1. Portal → **Container Apps** → Create.
2. **Basics**: new Resource Group, region (e.g. Central India), app name `pharmaish-api`.
   A new **Container Apps Environment** is created automatically (it provisions a Log
   Analytics workspace — first 5 GB/month of logs are free).
3. **Container** tab:
   - Image source: **Docker Hub or other registries**
   - Registry login server: `docker.io`
   - Image and tag: `<your-dockerhub-username>/pharmaish-api:latest`
   - Registry credentials: your Docker Hub username + **access token**.
   - CPU/Memory: `0.25 vCPU / 0.5 Gi` (cheapest, fine for testing).
4. **Ingress** tab:
   - Enable ingress, **Accepting traffic from anywhere**.
   - **Target port: `8080`** (the .NET 8 runtime image listens here).
5. Create.

### Scale-to-zero (the part that keeps it free)

After creation: Container App → **Scaling** → set **Min replicas = 0**, Max = 1.
With 0 minimum replicas, you pay nothing while idle; the first request after idle has a
short cold start.

---

## 4. Set the environment variables (secrets)

Container App → **Containers** → Edit and deploy → your container → **Environment variables**.
Add these (override `appsettings.json` values; `__` = nesting):

| Name | Value |
|------|-------|
| `ASPNETCORE_ENVIRONMENT` | `Production` |
| `DatabaseProvider` | `PostgreSQL` |
| `ConnectionStrings__PostgresConnection` | `Host=...;Port=5432;Database=pharmaish;Username=...;Password=...;SSL Mode=Require;Trust Server Certificate=true` |
| `JwtSettings__SecretKey` | a new long random secret (≥ 32 chars) |
| `JwtSettings__Issuer` | `MediMart.API` |
| `JwtSettings__Audience` | `MediMart.API.Users` |
| `FileStorage__Provider` | `Azure` |
| `FileStorage__Azure__ConnectionString` | your blob storage connection string |
| `FileStorage__Azure__ContainerName` | `image` |
| `RazorpaySettings__KeyId` | your Razorpay key id |
| `RazorpaySettings__KeySecret` | your Razorpay key secret |

> For real secrets you can instead use Container Apps **Secrets** and reference them from
> env vars — recommended over plain text, but plain env vars are acceptable for a test env.

---

## 5. Verify

- Container App → **Application Url** → open `https://<app>.<region>.azurecontainerapps.io/swagger`.
- TLS is terminated at the ingress; the container speaks plain HTTP on 8080. The app's
  `UseHttpsRedirection()` is harmless here (no internal HTTPS port, so it won't redirect).

---

## Cost-saving tips

- **Stop the Postgres server** when not testing (Portal → server → Stop). You then pay
  storage only. It auto-starts on the next manual start (Azure may auto-restart after 7 days).
- Keep **Min replicas = 0** on the Container App.
- Docker Hub free tier limits pulls (~100–200 / 6h). With scale-to-zero each cold start
  pulls the image; fine for low-traffic testing.

## Redeploying a new version

```bash
docker build -t <username>/pharmaish-api:latest .
docker push <username>/pharmaish-api:latest
# Then in the Portal: Container App → Revision management → Create new revision
# (or just "Restart" the active revision to re-pull :latest)
```

> Tip: use a unique tag per build (e.g. `:2026-05-31`) instead of `:latest` so revisions
> are explicit and rollback is easy.
