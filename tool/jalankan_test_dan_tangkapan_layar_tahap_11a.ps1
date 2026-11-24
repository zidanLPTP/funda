# Skrip eksekutor integration test Tahap 11A dan penangkap tangkapan layar otomatis
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:PATH = "C:\Users\M S I\flutter\bin;C:\AndroidSdk\platform-tools;C:\AndroidSdk\emulator;$env:JAVA_HOME\bin;$env:PATH"

$adb = "C:\AndroidSdk\platform-tools\adb.exe"
if (-not (Test-Path $adb)) {
    $adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
}
$folder = "docs/tangkapan_layar"
$buktiLog = "docs/bukti/tahap_11a_integration_test.txt"

if (-not (Test-Path $folder)) {
    New-Item -ItemType Directory -Path $folder -Force | Out-Null
}

$folderBukti = "docs/bukti"
if (-not (Test-Path $folderBukti)) {
    New-Item -ItemType Directory -Path $folderBukti -Force | Out-Null
}

Write-Host "================================================================="
Write-Host "Menjalankan Integration Test Tahap 11A pada emulator..."
Write-Host "Log dicatat di: $buktiLog"
Write-Host "Tangkapan layar di: $folder"
Write-Host "================================================================="

$devicesOutput = & "$adb" devices
$devicesText = ($devicesOutput | Out-String)
$deviceId = "emulator-5554"
if ($devicesText -match '(emulator-\d+)\s+device') {
    $deviceId = $Matches[1]
    Write-Host "Ditemukan device aktif: $deviceId"
} else {
    Write-Host "Device belum aktif. Mencoba target emulator-5554..."
}

$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = "powershell.exe"
$pinfo.Arguments = "-Command `"`$env:JAVA_HOME = 'C:\Program Files\Android\Android Studio\jbr'; `$env:PATH = 'C:\Users\M S I\flutter\bin;$env:LOCALAPPDATA\Android\Sdk\platform-tools;$env:LOCALAPPDATA\Android\Sdk\emulator;C:\Program Files\Android\Android Studio\jbr\bin;' + `$env:PATH; flutter test integration_test/tahap_11a_emulator_test.dart -d $deviceId 2>&1`""
$pinfo.RedirectStandardOutput = $true
$pinfo.RedirectStandardError = $true
$pinfo.UseShellExecute = $false
$pinfo.CreateNoWindow = $true

$proc = New-Object System.Diagnostics.Process
$proc.StartInfo = $pinfo

$sb = New-Object System.Text.StringBuilder

$action = {
    if ($EventArgs.Data) {
        $line = $EventArgs.Data
        [void]$sb.AppendLine($line)
        Write-Host $line

        if ($line -match '\[SCREEN_READY:\s*([^\]]+)\]') {
            $namaLayar = $Matches[1]
            $fileTarget = "$folder/$namaLayar.png"
            Write-Host ">>> MENANGKAP LAYAR: $namaLayar -> $fileTarget"
            & "$adb" -s $deviceId exec-out screencap -p > "$fileTarget"
        }
    }
}

$handler = [System.Diagnostics.DataReceivedEventHandler]$action
$proc.add_OutputDataReceived($handler)
$proc.add_ErrorDataReceived($handler)

$proc.Start() | Out-Null
$proc.BeginOutputReadLine()
$proc.BeginErrorReadLine()

$proc.WaitForExit()

$sb.ToString() | Out-File -FilePath $buktiLog -Encoding utf8
Write-Host "Selesai. Kode keluar: $($proc.ExitCode)"
