$tag = $env:CI_COMMIT_TAG
Write-Host "Starting build for tag: $tag"

if (Test-Path dist) { Write-Host "Cleaning dist..."; Remove-Item -Recurse -Force dist }
if (Test-Path build) { Write-Host "Cleaning build..."; Remove-Item -Recurse -Force build }
New-Item -ItemType Directory -Path dist -Force

Write-Host "Running flutter pub get..."
flutter pub get
if ($LASTEXITCODE -ne 0) { throw "flutter pub get failed" }

Write-Host "Building windows..."
flutter build windows --release
if ($LASTEXITCODE -ne 0) { throw "flutter build windows failed" }

Write-Host "Copying artifacts..."
$releaseDir = "build\windows\x64\runner\Release"
$destDir = "dist\yampa-windows-release"
xcopy /E /I $releaseDir $destDir

$zipPath = "dist\yampa-windows-x64-$tag.zip"
Write-Host "Creating zip: $zipPath"
Compress-Archive -Path "$destDir\*" -DestinationPath $zipPath -Force

Write-Host "Build complete. Files in dist:"
Get-ChildItem dist\
