@echo off
REM Visual Studio C++ Components Installer for Flutter Windows Development
REM Run this file as Administrator

title Installing Visual Studio C++ Tools...
echo.
echo Installing Visual Studio C++ Build Tools for Flutter Windows Development
echo This will install necessary components: C++ compiler, CMake, and Windows SDK
echo.
echo Please wait - this may take 15-30 minutes...
echo.

REM Path to VS installer
set VS_INSTALLER="C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe"
set BUILD_TOOLS_PATH="C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools"

REM Install C++ components
%VS_INSTALLER% --modify --installPath %BUILD_TOOLS_PATH% ^
  --add Microsoft.VisualStudio.Workload.NativeDesktop ^
  --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 ^
  --add Microsoft.VisualStudio.Component.VC.CMake.Project ^
  --add Microsoft.VisualStudio.Component.Windows10SDK ^
  --norestart --quiet

echo.
if %ERRORLEVEL% EQU 0 (
    echo Visual Studio C++ components installed successfully!
    echo.
    echo You can now build Flutter for Windows.
    echo.
    echo Next steps:
    echo 1. Open Command Prompt or PowerShell
    echo 2. Navigate to your project folder
    echo 3. Run: flutter clean
    echo 4. Run: flutter run -d windows
) else (
    echo Installation had issues. Exit code: %ERRORLEVEL%
    echo Try running Flutter doctor for more details: flutter doctor -v
)

echo.
pause
