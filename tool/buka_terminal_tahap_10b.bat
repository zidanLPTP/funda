@echo off
set "JAVA_HOME=C:\Program Files\Android\Android Studio\jbr"
set "PATH=C:\Users\M S I\flutter\bin;C:\AndroidSdk\platform-tools;C:\AndroidSdk\emulator;%JAVA_HOME%\bin;%PATH%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0jalankan_test_dan_tangkapan_layar_tahap_10b.ps1"
pause
