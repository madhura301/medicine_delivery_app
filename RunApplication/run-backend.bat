@echo off
REM ============================================================
REM  Pharmaish - Run the .NET 8 backend API
REM  Double-click this file (or run from a terminal).
REM ============================================================
setlocal

REM --- API project (relative to this script) ---
set "API_PROJECT=%~dp0..\Backend\MedicineDelivery\MedicineDelivery.API"

REM --- Optional: force Development environment ---
set "ASPNETCORE_ENVIRONMENT=Development"

echo ============================================================
echo  API project : %API_PROJECT%
echo  Environment : %ASPNETCORE_ENVIRONMENT%
echo  Watch the console below for the "Now listening on" URL.
echo ============================================================

where dotnet >nul 2>&1
if errorlevel 1 (
  echo [ERROR] 'dotnet' not found on PATH. Install the .NET 8 SDK.
  pause
  exit /b 1
)

if not exist "%API_PROJECT%\MedicineDelivery.API.csproj" (
  echo [ERROR] Could not find the API project at:
  echo         %API_PROJECT%
  pause
  exit /b 1
)

cd /d "%API_PROJECT%" || (
  echo [ERROR] Could not enter the API project folder.
  pause
  exit /b 1
)

echo.
echo Starting API (dotnet run)...  Press Ctrl+C to stop.
echo.
call dotnet run

echo.
echo API stopped.
pause
endlocal
