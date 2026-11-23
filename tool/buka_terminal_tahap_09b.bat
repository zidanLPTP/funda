@echo off
set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
set ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk
set PATH=C:\Users\M S I\flutter\bin;%LOCALAPPDATA%\Android\Sdk\platform-tools;%LOCALAPPDATA%\Android\Sdk\emulator;%JAVA_HOME%\bin;%PATH%
powershell -NoExit -ExecutionPolicy Bypass -Command "Write-Host 'Terminal Funda Tahap 9B Siap' -ForegroundColor Cyan; Write-Host 'Jalankan runner integration test:' -ForegroundColor Yellow; Write-Host '.\tool\jalankan_test_dan_tangkapan_layar_tahap_09b.ps1' -ForegroundColor Green;"
