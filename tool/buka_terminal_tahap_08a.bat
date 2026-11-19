@echo off
title Integration Test Tahap 8A - Funda
echo ======================================================================
echo FUNDA - INTEGRATION TEST TAHAP 8A PADA EMULATOR PIXEL 8
echo ======================================================================
echo JAVA_HOME diatur ke Java 21 OpenJDK Android Studio...
set "JAVA_HOME=C:\Program Files\Android\Android Studio\jbr"
set "PATH=%LOCALAPPDATA%\Android\Sdk\platform-tools;C:\AndroidSdk\platform-tools;%PATH%"
cd /d "D:\Proyek Coding\Flutter\Funda"

echo.
echo Memulai eksekusi tes pada emulator-5554...
echo Log akan tampil langsung di bawah ini:
echo.

powershell -NoExit -ExecutionPolicy Bypass -Command "& { $env:JAVA_HOME = 'C:\Program Files\Android\Android Studio\jbr'; .\tool\jalankan_test_dan_tangkapan_layar_tahap_08a.ps1 }"
pause
