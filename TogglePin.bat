
@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0TogglePin.ps1"
if %errorlevel% neq 0 (
    echo.
    pause
)
