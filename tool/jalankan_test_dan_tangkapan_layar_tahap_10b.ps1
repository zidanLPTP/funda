# Skrip eksekutor integration test Tahap 10B dan penangkap tangkapan layar otomatis
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:PATH = "C:\Users\M S I\flutter\bin;C:\AndroidSdk\platform-tools;C:\AndroidSdk\emulator;$env:JAVA_HOME\bin;$env:PATH"

$adb = "C:\AndroidSdk\platform-tools\adb.exe"
if (-not (Test-Path $adb)) {
    $adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
}
$folder = "docs/tangkapan_layar"
$buktiLog = "docs/bukti/tahap_10b_integration_test.txt"

if (-not (Test-Path $folder)) {
    New-Item -ItemType Directory -Path $folder -Force | Out-Null
}

$folderBukti = "docs/bukti"
if (-not (Test-Path $folderBukti)) {
    New-Item -ItemType Directory -Path $folderBukti -Force | Out-Null
}

Write-Host "================================================================="
Write-Host "Menjalankan Integration Test Tahap 10B pada emulator..."
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
$pinfo.Arguments = "-Command `"`$env:JAVA_HOME = 'C:\Program Files\Android\Android Studio\jbr'; `$env:PATH = 'C:\Users\M S I\flutter\bin;$env:LOCALAPPDATA\Android\Sdk\platform-tools;$env:LOCALAPPDATA\Android\Sdk\emulator;C:\Program Files\Android\Android Studio\jbr\bin;' + `$env:PATH; flutter test integration_test/tahap_10b_emulator_test.dart -d $deviceId 2>&1`""
$pinfo.RedirectStandardOutput = $true
$pinfo.RedirectStandardError = $true
$pinfo.UseShellExecute = $false
$pinfo.CreateNoWindow = $true

$proc = New-Object System.Diagnostics.Process
$proc.StartInfo = $pinfo
$proc.Start() | Out-Null

$fileStream = [System.IO.FileStream]::new($buktiLog, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write, [System.IO.FileShare]::ReadWrite)
$logStream = [System.IO.StreamWriter]::new($fileStream, [System.Text.Encoding]::UTF8)

$buffer = New-Object System.Text.StringBuilder

while (-not $proc.HasExited) {
    $line = $proc.StandardOutput.ReadLine()
    if ($line -ne $null) {
        Write-Host $line
        $logStream.WriteLine($line)
        $logStream.Flush()

        if ($line -match '\[SCREEN_READY:\s*([^\]]+)\]') {
            $screenName = $Matches[1].Trim()
            $targetPath = "$folder/$screenName.png"
            Write-Host "[SCREENSHOT] Menangkap layar $screenName -> $targetPath"
            & "$adb" -s $deviceId exec-out screencap -p > $targetPath
        }
    }
}

$remaining = $proc.StandardOutput.ReadToEnd()
if ($remaining) {
    Write-Host $remaining
    $logStream.Write($remaining)
    $logStream.Flush()
}

$logStream.Close()
$fileStream.Close()

Write-Host "Proses selesai dengan ExitCode: $($proc.ExitCode)"
