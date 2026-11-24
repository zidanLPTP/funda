$ErrorActionPreference = "Stop"

Write-Host "=== Menjalankan Test Integrasi Emulator Tahap 11C ===" -ForegroundColor Cyan

# Pastikan folder bukti ada
$folderBukti = "docs/bukti"
if (-not (Test-Path $folderBukti)) {
    New-Item -ItemType Directory -Path $folderBukti | Out-Null
}

$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
if (-not (Test-Path $adb)) {
    $adb = "adb"
}

Write-Host "Memeriksa perangkat emulator..." -ForegroundColor Yellow
$devices = & $adb devices
Write-Host $devices

if ($devices -notmatch "device\b") {
    Write-Warning "Tidak ada emulator yang aktif/terhubung. Lewati eksekusi fisik."
    exit 0
}

Write-Host "Menjalankan flutter test integration_test/tahap_11c_emulator_test.dart..." -ForegroundColor Green
flutter test integration_test/tahap_11c_emulator_test.dart
