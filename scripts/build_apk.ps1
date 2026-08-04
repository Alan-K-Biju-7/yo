[CmdletBinding()]
param(
    [ValidateSet('debug', 'release')]
    [string]$Mode = 'release',

    [string]$Flutter = 'flutter'
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$pubspecPath = Join-Path $projectRoot 'pubspec.yaml'
$pubspec = Get-Content -LiteralPath $pubspecPath -Raw
$versionMatch = [regex]::Match($pubspec, '(?m)^version:\s*([^\s+]+)')

if (-not $versionMatch.Success) {
    throw 'Could not read the application version from pubspec.yaml.'
}

$version = $versionMatch.Groups[1].Value
$distDirectory = Join-Path $projectRoot 'dist'
$sourceApk = Join-Path $projectRoot "build\app\outputs\flutter-apk\app-$Mode.apk"
$destinationApk = Join-Path $distDirectory "RSET-Student-App-v$version-universal-$Mode.apk"
$checksumFile = "$destinationApk.sha256"

Push-Location $projectRoot
try {
    & $Flutter pub get
    if ($LASTEXITCODE -ne 0) { throw 'flutter pub get failed.' }

    & $Flutter analyze
    if ($LASTEXITCODE -ne 0) { throw 'flutter analyze failed.' }

    & $Flutter test
    if ($LASTEXITCODE -ne 0) { throw 'flutter test failed.' }

    & $Flutter build apk "--$Mode"
    if ($LASTEXITCODE -ne 0) { throw 'flutter build apk failed.' }

    New-Item -ItemType Directory -Force -Path $distDirectory | Out-Null
    Copy-Item -LiteralPath $sourceApk -Destination $destinationApk -Force

    $hash = (Get-FileHash -LiteralPath $destinationApk -Algorithm SHA256).Hash
    "$hash  $(Split-Path -Leaf $destinationApk)" |
        Set-Content -LiteralPath $checksumFile -Encoding ascii

    Write-Host ''
    Write-Host 'APK ready:'
    Write-Host $destinationApk
    Write-Host "SHA-256: $hash"
}
finally {
    Pop-Location
}
