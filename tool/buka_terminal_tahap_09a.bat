@echo off
set "JAVA_HOME=C:\Program Files\Android\Android Studio\jbr"
set "PATH=C:\Users\M S I\flutter\bin;C:\AndroidSdk\platform-tools;C:\AndroidSdk\emulator;%LOCALAPPDATA%\Android\Sdk\platform-tools;%LOCALAPPDATA%\Android\Sdk\emulator;%JAVA_HOME%\bin;%PATH%"

echo =================================================================
echo Membuka PowerShell untuk Menjalankan Integration Test Tahap 9A...
echo =================================================================

powershell -NoExit -ExecutionPolicy Bypass -File .\tool\jalankan_test_dan_tangkapan_layar_tahap_09a.ps1
