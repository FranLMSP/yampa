$token = $env:GITEA_TOKEN
$repo = $env:CI_REPO
$tag = $env:CI_COMMIT_TAG
$baseUrl = $env:CI_FORGE_URL
$apiUrl = "$baseUrl/api/v1/repos/$repo/releases"
$headers = @{ 'Authorization' = "token $token" }

Write-Host "Creating/Getting release for tag $tag..."
try {
    $body = @{ tag_name = $tag; name = $tag; body = "Release $tag" } | ConvertTo-Json
    $release = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers ($headers + @{'Content-Type'='application/json'}) -Body $body
} catch {
    Write-Host "Release might already exist, fetching it..."
    $release = Invoke-RestMethod -Uri "$apiUrl/tags/$tag" -Method Get -Headers $headers
}

$releaseId = $release.id
$zipFile = "dist/yampa-windows-x64-$tag.zip"

Write-Host "--- DEBUG INFO ---"
Write-Host "Current Directory: $(Get-Location)"
Write-Host "CI_WORKSPACE: $($env:CI_WORKSPACE)"
Write-Host "Expected Zip Path: $zipFile"
Write-Host "Listing root directory contents:"
Get-ChildItem
if (Test-Path dist) {
    Write-Host "Listing 'dist' directory contents:"
    Get-ChildItem dist
} else {
    Write-Warning "'dist' directory does not exist in $(Get-Location)"
}
Write-Host "------------------"

if (Test-Path $zipFile) {
    $fileName = [System.IO.Path]::GetFileName($zipFile)
    Write-Host "Found zip file: $zipFile"
    Write-Host "Checking for existing asset $fileName in release $releaseId..."
    $assets = Invoke-RestMethod -Uri "$apiUrl/$releaseId/assets" -Method Get -Headers $headers
    $existing = $assets | Where-Object { $_.name -eq $fileName }
    if ($existing) {
        Write-Host "Deleting existing asset $($existing.id)..."
        Invoke-RestMethod -Uri "$apiUrl/$releaseId/assets/$($existing.id)" -Method Delete -Headers $headers
    }
    
    Write-Host "Uploading $zipFile..."
    $uploadUrl = "$apiUrl/$releaseId/assets"
    curl.exe -H "Authorization: token $token" -F "attachment=@$zipFile" $uploadUrl
} else {
    Write-Error "Zip file not found: $zipFile"
    exit 1
}
