# Skrip eksekutor integration test dan penangkap screenshot realtime
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$folder = "docs/tangkapan_layar/tahap_06_emulator"
$buktiLog = "docs/bukti/tahap_06_r_integration_test.txt"

if (-not (Test-Path $folder)) {
    New-Item -ItemType Directory -Path $folder -Force | Out-Null
}

# Bersihkan file uji_coba.png jika ada
if (Test-Path "$folder/uji_coba.png") {
    Remove-Item "$folder/uji_coba.png" -Force
}

Write-Host "Menjalankan integration test alur Modul 1 dan memantau screenshot..."
$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = "powershell.exe"
$pinfo.Arguments = "-Command flutter test integration_test/tahap_06_alur_modul_1_emulator_test.dart -d emulator-5554"
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
                Start-Sleep -Milliseconds 400
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
