@echo off
REM ============================================================
REM  Pharmaish - Run the Flutter frontend as a WEB application
REM  Double-click this file (or run from a terminal).
REM ============================================================
setlocal

REM --- Flutter SDK location (installed here during setup) ---
set "FLUTTER_BIN=J:\flutter\bin"

REM --- Let Flutter find Chrome for the "chrome" device ---
set "CHROME_EXECUTABLE=C:\Program Files\Google\Chrome\Application\chrome.exe"

REM --- Web port + device ---
set "WEB_PORT=8080"
set "DEVICE=chrome"
REM   Tip: set DEVICE=web-server above to just serve at http://localhost:%WEB_PORT%
REM   (no auto-launched browser) instead of opening Chrome.

REM --- Project dir = ..\Flutter_UI relative to this script ---
set "PROJECT_DIR=%~dp0..\Flutter_UI"

REM --- Put Flutter on PATH for this session ---
set "PATH=%FLUTTER_BIN%;%PATH%"

echo ============================================================
echo  Flutter SDK : %FLUTTER_BIN%
echo  Project     : %PROJECT_DIR%
echo  URL         : http://localhost:%WEB_PORT%
echo ============================================================

if not exist "%FLUTTER_BIN%\flutter.bat" (
  echo [ERROR] Flutter not found at %FLUTTER_BIN%.
  echo         Update FLUTTER_BIN in this script to your Flutter SDK path.
  pause
  exit /b 1
)

cd /d "%PROJECT_DIR%" || (
  echo [ERROR] Could not find project folder: %PROJECT_DIR%
  pause
  exit /b 1
)

echo.
echo [1/2] Fetching packages (flutter pub get)...
call flutter pub get
if errorlevel 1 (
  echo [ERROR] flutter pub get failed.
  pause
  exit /b 1
)

echo.
echo [2/2] Launching web app on http://localhost:%WEB_PORT% ...
echo       (Press Ctrl+C in this window to stop.)
call flutter run -d %DEVICE% --web-port %WEB_PORT%

echo.
echo Application stopped.
pause
endlocal
