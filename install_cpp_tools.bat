@echo off
REM Install C++ build tools for Flutter Windows development
echo Installing Visual Studio C++ components...

"C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe" ^
  --modify ^
  --installPath "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools" ^
  --add Microsoft.VisualStudio.Workload.NativeDesktop ^
  --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 ^
  --add Microsoft.VisualStudio.Component.VC.CMake.Project ^
  --add Microsoft.VisualStudio.Component.Windows10SDK ^
  --norestart ^
  --quiet

echo Installation started. This may take 10-20 minutes...
pause
