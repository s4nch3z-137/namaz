$ErrorActionPreference = "Stop"

Write-Host "Downloading cmdline-tools..."
$tempZip = "$env:TEMP\cmdline-tools.zip"
Invoke-WebRequest -Uri "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip" -OutFile $tempZip

Write-Host "Extracting cmdline-tools..."
$extractPath = "$env:LOCALAPPDATA\Android\Sdk\cmdline-tools"
if (Test-Path "$extractPath\latest") { Remove-Item -Recurse -Force "$extractPath\latest" }
if (Test-Path "$extractPath\cmdline-tools") { Remove-Item -Recurse -Force "$extractPath\cmdline-tools" }

Expand-Archive -Path $tempZip -DestinationPath $extractPath -Force
Rename-Item -Path "$extractPath\cmdline-tools" -NewName "latest"

Write-Host "Accepting Android Licenses..."
1..15 | ForEach-Object { "y" } | flutter doctor --android-licenses

Write-Host "Checking Flutter Doctor for Android..."
flutter doctor -v

Write-Host "Done setting up Android Emulator tools."
