@echo off
title Integration Test Tahap 8D - Funda
echo ======================================================================
echo FUNDA - INTEGRATION TEST TAHAP 8D PADA EMULATOR
echo ======================================================================
echo JAVA_HOME diatur ke Java 21 OpenJDK Android Studio...
set "JAVA_HOME=C:\Program Files\Android\Android Studio\jbr"
set "PATH=%LOCALAPPDATA%\Android\Sdk\platform-tools;C:\AndroidSdk\platform-tools;%PATH%"
cd /d "D:\Proyek Coding\Flutter\Funda"

echo.
echo Memeriksa perangkat emulator yang aktif...
adb devices
echo.
echo Menjalankan skrip integrasi Tahap 8D...
echo.

powershell -NoExit -ExecutionPolicy Bypass -Command "& { $env:JAVA_HOME = 'C:\Program Files\Android\Android Studio\jbr'; .\tool\jalankan_test_dan_tangkapan_layar_tahap_08d.ps1 }"
pause
