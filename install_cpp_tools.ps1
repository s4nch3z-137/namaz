# Install Visual Studio C++ components for Flutter Windows development
param(
    [switch]$RunAsAdmin
)

# Check if running as admin
$isAdmin = ([System.Security.Principal.WindowsIdentity]::GetCurrent()).Groups -contains @([System.Security.Principal.SecurityIdentifier]'S-1-5-32-544')

if (-not $isAdmin -and -not $RunAsAdmin) {
    Write-Host "Requesting administrator privileges..."
    Start-Process powershell -ArgumentList "-File", $PSCommandPath, "-RunAsAdmin" -Verb RunAs -Wait
    exit
}

$vsInstallerPath = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe"
$buildToolsPath = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools"

if (!(Test-Path $vsInstallerPath)) {
    Write-Error "Visual Studio installer not found at $vsInstallerPath"
    exit 1
}

Write-Host "Starting Visual Studio C++ components installation..."
Write-Host "This will take 10-30 minutes. Please wait and do not close this window."
Write-Host ""

$args = @(
    "--modify",
    "--installPath", $buildToolsPath,
    "--add", "Microsoft.VisualStudio.Workload.NativeDesktop",
    "--add", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64",
    "--add", "Microsoft.VisualStudio.Component.VC.CMake.Project",
    "--add", "Microsoft.VisualStudio.Component.Windows10SDK",
    "--norestart",
    "--quiet"
)

Write-Host "Command: $vsInstallerPath $($args -join ' ')"
Write-Host ""

& $vsInstallerPath @args

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Installation completed successfully!"
    Write-Host "You can now build Flutter apps for Windows."
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "1. Run: flutter clean"
    Write-Host "2. Run: flutter run -d windows"
} else {
    Write-Host ""
    Write-Host "Installation failed with exit code: $LASTEXITCODE"
    Write-Host "Run flutter doctor -v for more details"
}
