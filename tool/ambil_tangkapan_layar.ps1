# Skrip Pengambilan Tangkapan Layar Emulator Funda
# Menggunakan perintah resmi: adb exec-out screencap -p
param (
    [string]$NamaBerkas = "tangkapan_layar.png",
    [string]$FolderTujuan = "docs/tangkapan_layar/tahap_05_emulator"
)

$adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
if (-not (Test-Path $adbPath)) {
    $adbPath = "C:\AndroidSdk\platform-tools\adb.exe"
}
if (-not (Test-Path $adbPath)) {
    $adbCmd = Get-Command "adb" -ErrorAction SilentlyContinue
    if ($adbCmd) {
        $adbPath = $adbCmd.Source
    } else {
        Write-Error "ADB tidak ditemukan di $adbPath maupun di PATH sistem."
        exit 1
    }
}

if (-not (Test-Path $FolderTujuan)) {
    New-Item -ItemType Directory -Path $FolderTujuan -Force | Out-Null
}

$targetPath = Join-Path $FolderTujuan $NamaBerkas
Write-Host "Mengambil tangkapan layar emulator ke: $targetPath"

# Jalankan adb exec-out screencap -p dengan binary stdout redirection via cmd
cmd /c "`"$adbPath`" exec-out screencap -p > `"$targetPath`""

if (Test-Path $targetPath) {
    $ukuran = (Get-Item $targetPath).Length
    Write-Host "Berhasil menyimpan: $targetPath ($ukuran bytes)"
} else {
    Write-Error "Gagal mengambil tangkapan layar."
}
