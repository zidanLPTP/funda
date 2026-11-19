# Skrip eksekutor integration test Tahap 7 dan penangkap tangkapan layar otomatis
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$folder = "docs/tangkapan_layar"
$buktiLog = "docs/bukti/tahap_07_r_integration_test.txt"

if (-not (Test-Path $folder)) {
    New-Item -ItemType Directory -Path $folder -Force | Out-Null
}

$folderBukti = "docs/bukti"
if (-not (Test-Path $folderBukti)) {
    New-Item -ItemType Directory -Path $folderBukti -Force | Out-Null
}

Write-Host "Menjalankan integration test Tahap 7 pada emulator-5554..."
$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = "powershell.exe"
$pinfo.Arguments = "-Command flutter test integration_test/tahap_07_laporan_dan_cadangan_emulator_test.dart -d emulator-5554 2>&1"
$pinfo.RedirectStandardOutput = $true
$pinfo.RedirectStandardError = $true
$pinfo.UseShellExecute = $false
$pinfo.CreateNoWindow = $true

$proc = New-Object System.Diagnostics.Process
$proc.StartInfo = $pinfo
$proc.Start() | Out-Null

$logStream = [System.IO.File]::CreateText($buktiLog)
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
                cmd /c "`"$adb`" exec-out screencap -p > `"$tujuan`""
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
Write-Host "Integration test selesai dengan kode keluar: $($proc.ExitCode)"
exit $proc.ExitCode
