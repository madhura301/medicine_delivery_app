@echo off
REM ============================================================
REM  Pharmaish - Launch BOTH the backend API and the Flutter
REM  web app, each in its own console window.
REM ============================================================
start "Pharmaish API"  cmd /k "%~dp0run-backend.bat"
start "Pharmaish Web"  cmd /k "%~dp0run-frontend-web.bat"
echo Launched backend + frontend in separate windows.
