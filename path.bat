@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
    exit /b 1
)

set "NEW_PATH=%~1"

if "!NEW_PATH:~-1!"=="\" set "NEW_PATH=!NEW_PATH:~0,-1!"

set "CURRENT_PATH="
for /f "skip=2 tokens=3*" %%a in ('reg query "HKCU\Environment" /v PATH 2^>nul') do (
    set "CURRENT_PATH=%%a %%b"
)

if not "!CURRENT_PATH!"=="" (
    if "!CURRENT_PATH:~-1!"==";" set "CURRENT_PATH=!CURRENT_PATH:~0,-1!"
)

if not defined CURRENT_PATH set "CURRENT_PATH="
echo !CURRENT_PATH! | find /i "!NEW_PATH!" >nul
if !errorlevel! equ 0 (
    echo Path already exists: !NEW_PATH!
    exit /b 0
)

if "!CURRENT_PATH!"=="" (
    setx PATH "!NEW_PATH!" >nul
) else (
    setx PATH "!CURRENT_PATH!;!NEW_PATH!;" >nul
)

if !errorlevel! equ 0 (
    echo Successfully added to PATH: !NEW_PATH!
    echo Restart the terminal for the changes to take effect.
) else (
    echo Failed to set the environment variable.
    echo Please add the environment variable manually: !NEW_PATH!
    exit /b 1
)

endlocal
