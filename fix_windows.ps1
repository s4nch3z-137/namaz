$ErrorActionPreference = "Stop"

Write-Host "Installing Microsoft Visual Studio Build Tools..."
Write-Host "NOTE: You may see a blue Windows UAC popup. Please click 'Yes' to allow the installation."
Write-Host "This download is roughly 6 GB, so it will take some time in the background."

winget install Microsoft.VisualStudio.2022.BuildTools --override "--add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended --quiet" --accept-package-agreements --accept-source-agreements

Write-Host "Once the installation finishes, Developer Mode MUST be on to build Windows Apps."
Write-Host "Go to: Windows Settings > System > For Developers > Turn ON 'Developer Mode'."
