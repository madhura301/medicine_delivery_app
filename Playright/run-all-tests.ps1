<#
  Runs BOTH validation layers against a locally-running backend:
    1. API contract suite   (Playwright, ~110 endpoints)
    2. Functional flows      (validate_functional.py, PDF sign-off scenarios)

  Prereqs: Postgres up (MedicineDeliveryNew), backend running on $ApiBase against
  local Postgres with a real blob string and SmsSettings:Provider=Console.
  See functional/README.md for the exact backend launch command.

  Usage:  pwsh Playright/run-all-tests.ps1  [-ApiBase http://localhost:5000]
#>
param(
  [string]$ApiBase = "http://localhost:5000"
)
$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$failed = $false

Write-Host "== Pharmaish full validation ==  API=$ApiBase" -ForegroundColor Cyan

# 0) backend reachable?
try {
  Invoke-WebRequest -UseBasicParsing -Uri "$ApiBase/swagger/index.html" -TimeoutSec 10 | Out-Null
} catch {
  Write-Host "Backend not reachable at $ApiBase. Start it first (see functional/README.md)." -ForegroundColor Red
  exit 2
}

# 1) API contract suite
Write-Host "`n-- [1/2] API contract suite (Playwright) --" -ForegroundColor Yellow
Push-Location "$root/e2e"
& npx playwright test --project=api --reporter=line
if ($LASTEXITCODE -ne 0) { $failed = $true; Write-Host "API suite FAILED" -ForegroundColor Red }
Pop-Location

# 2) Functional flows
Write-Host "`n-- [2/2] Functional flows (PDF sign-off scenarios) --" -ForegroundColor Yellow
$env:API_BASE = $ApiBase
& python "$root/functional/validate_functional.py"
if ($LASTEXITCODE -ne 0) { $failed = $true; Write-Host "Functional flows FAILED" -ForegroundColor Red }

if ($failed) { Write-Host "`nRESULT: FAILURES ABOVE" -ForegroundColor Red; exit 1 }
Write-Host "`nRESULT: ALL GREEN" -ForegroundColor Green
