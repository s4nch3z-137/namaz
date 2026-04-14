@echo off
REM Install Visual Studio C++ components using response file
REM Run as Administrator

setlocal enabledelayedexpansion

echo.
echo Visual Studio C++ Build Tools Installation
echo =============================================
echo.

set VS_INSTALLER="C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe"
set CONFIG_FILE="%~dp0vs_install_config.json"
set BUILD_TOOLS_PATH="C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools"

if not exist %VS_INSTALLER% (
    echo ERROR: Visual Studio Installer not found
    pause
    exit /b 1
)

echo Starting installation with config: %CONFIG_FILE%
echo.
echo This will install:
echo   - MSVC C++ compiler
echo   - CMake tools
echo   - Windows SDK
echo.
echo Please wait (this may take 15-30 minutes)...
echo.

REM Try using the response file
%VS_INSTALLER% --in %CONFIG_FILE% --norestart --quiet

if !ERRORLEVEL! EQU 0 (
    echo.
    echo SUCCESS: Installation completed!
    echo.
    echo Next steps:
    echo   1. Restart your computer (optional but recommended)
    echo   2. Run: flutter doctor -v
    echo   3. Run: flutter clean
    echo   4. Run: flutter run -d windows
) else (
    echo.
    echo Installation may have encountered issues.
    echo Error code: !ERRORLEVEL!
    echo.
    echo Try this manual approach:
    echo   1. Open: C:\Program Files ^(x86^)\Microsoft Visual Studio\Installer\vs_installer.exe
    echo   2. Click "Modify" on Build Tools 2022
    echo   3. Check "Desktop development with C++"
    echo   4. Ensure these are selected:
    echo      - MSVC v143 - VS 2022 C++ x64/x86 build tools
    echo      - C++ CMake tools for Windows
    echo      - Windows 11 SDK
    echo   5. Click "Modify" and wait for completion
)

echo.
pause
