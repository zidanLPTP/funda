# Skrip eksekutor integration test Tahap 8D dan penangkap tangkapan layar otomatis
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:PATH = "C:\Users\M S I\flutter\bin;$env:LOCALAPPDATA\Android\Sdk\platform-tools;$env:LOCALAPPDATA\Android\Sdk\emulator;$env:JAVA_HOME\bin;$env:PATH"

$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
if (-not (Test-Path $adb)) {
    if (Test-Path "C:\AndroidSdk\platform-tools\adb.exe") {
        $adb = "C:\AndroidSdk\platform-tools\adb.exe"
    }
}
$folder = "docs/tangkapan_layar"
$buktiLog = "docs/bukti/tahap_08d_integration_test.txt"

if (-not (Test-Path $folder)) {
    New-Item -ItemType Directory -Path $folder -Force | Out-Null
}

$folderBukti = "docs/bukti"
if (-not (Test-Path $folderBukti)) {
    New-Item -ItemType Directory -Path $folderBukti -Force | Out-Null
}

Write-Host "================================================================="
Write-Host "Menjalankan Integration Test Tahap 8D pada emulator..."
Write-Host "Log dicatat di: $buktiLog"
Write-Host "Tangkapan layar di: $folder"
Write-Host "================================================================="

$devicesOutput = & "$adb" devices
$deviceId = "emulator-5554"
if ($devicesOutput -match '(emulator-\d+)\s+device') {
    $deviceId = $Matches[1]
    Write-Host "Ditemukan device aktif: $deviceId"
} else {
    Write-Host "Device belum aktif. Mencoba target emulator-5554..."
}

$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = "powershell.exe"
$pinfo.Arguments = "-Command `"`$env:JAVA_HOME = 'C:\Program Files\Android\Android Studio\jbr'; `$env:PATH = 'C:\Users\M S I\flutter\bin;$env:LOCALAPPDATA\Android\Sdk\platform-tools;$env:LOCALAPPDATA\Android\Sdk\emulator;C:\Program Files\Android\Android Studio\jbr\bin;' + `$env:PATH; flutter test integration_test/tahap_08d_emulator_test.dart -d $deviceId 2>&1`""
$pinfo.RedirectStandardOutput = $true
$pinfo.RedirectStandardError = $true
$pinfo.UseShellExecute = $false
$pinfo.CreateNoWindow = $true

$proc = New-Object System.Diagnostics.Process
$proc.StartInfo = $pinfo
$proc.Start() | Out-Null

$fileStream = [System.IO.FileStream]::new($buktiLog, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write, [System.IO.FileShare]::ReadWrite)
$logStream = [System.IO.StreamWriter]::new($fileStream, [System.Text.Encoding]::UTF8)
$sudahDiambil = @{}

while (-not $proc.HasExited -or -not $proc.StandardOutput.EndOfStream) {
    $line = $proc.StandardOutput.ReadLine()
    if ($line -ne $null) {
        Write-Host $line
        $logStream.WriteLine($line)
        $logStream.Flush()

        if ($line -match '\[SCREEN_READY:\s*([a-zA-Z0-9_]+)\]') {
            $nama = $Matches[1]
            if (-not $sudahDiambil.ContainsKey($nama)) {
                $sudahDiambil[$nama] = $true
                $tujuan = Join-Path $folder "$nama.png"
                Write-Host "--> MENGAMBIL SCREENSHOT: $tujuan"
                & "$adb" -s $deviceId shell screencap -p /sdcard/temp_screen.png
                & "$adb" -s $deviceId pull /sdcard/temp_screen.png "$tujuan" | Out-Null
                Start-Sleep -Milliseconds 500
                if (Test-Path $tujuan) {
                    $ukuran = (Get-Item $tujuan).Length
                    Write-Host "--> TERSIMPAN: $nama.png ($ukuran bytes)"
                }
            }
        }
    }
}

$proc.WaitForExit()
$logStream.Close()

if (Test-Path $buktiLog) {
    $content = Get-Content $buktiLog -Raw
    if ($content -match '(?s)(=== RINCIAN JUMLAH BARIS PER TABEL SEBELUM CADANGAN/PEMULIHAN.*\[REGRESI SUKSES\].*?\n)') {
        $Matches[1] | Out-File -FilePath "docs/bukti/tahap_08d_regresi_tabel.txt" -Encoding utf8
        Write-Host "--> BUKTI REGRESI TERSIMPAN: docs/bukti/tahap_08d_regresi_tabel.txt"
    }
}

Write-Host "================================================================="
Write-Host "Integration test Tahap 8D selesai dengan kode keluar: $($proc.ExitCode)"
Write-Host "================================================================="
exit $proc.ExitCode
