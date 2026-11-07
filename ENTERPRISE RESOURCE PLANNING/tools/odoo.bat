@echo off
rem Windows launcher. Double-click for the menu, or run: tools\odoo setup
rem Needs nothing installed: on the first run it downloads a private Python into tools\runtime.
setlocal
title Odoo 19 - ERP practicals
set "TOOLS=%~dp0"
set "RUNTIME=%TOOLS%runtime"
set "PY=%RUNTIME%\python\python.exe"
cd /d "%TOOLS%.."
if exist "%PY%" goto run

set "URL=https://github.com/astral-sh/python-build-standalone/releases/download/20261026/cpython-3.12.16+20261026-x86_64-pc-windows-msvc-install_only.tar.gz"
set "SHA=590dfcbe3a34c07301e6332e13e2188b98655cd072b08afa45a7998dc4c22bc5"
set "SYS=%SystemRoot%\System32"
set "ARCHIVE=%RUNTIME%\python-download.tar.gz"
set "UNPACK=%RUNTIME%\python-unpack"

echo.
echo First run: downloading Python 3.12 into the tools folder.
echo It stays in that folder. Nothing is installed on this computer.
echo.
if not exist "%RUNTIME%" mkdir "%RUNTIME%"
if not exist "%SYS%\curl.exe" goto old_windows
if not exist "%SYS%\tar.exe" goto old_windows

"%SYS%\curl.exe" -fL --retry 3 --progress-bar -o "%ARCHIVE%" "%URL%"
if errorlevel 1 goto no_download

"%SYS%\certutil.exe" -hashfile "%ARCHIVE%" SHA256 | "%SYS%\findstr.exe" /i /x "%SHA%" >nul
if errorlevel 1 goto bad_checksum

if exist "%UNPACK%" rmdir /s /q "%UNPACK%"
mkdir "%UNPACK%"
"%SYS%\tar.exe" -xzf "%ARCHIVE%" -C "%UNPACK%"
if errorlevel 1 goto no_unpack
move "%UNPACK%\python" "%RUNTIME%\python" >nul
if errorlevel 1 goto no_unpack
rmdir /s /q "%UNPACK%"
del "%ARCHIVE%"

:run
"%PY%" -I "%TOOLS%setup_odoo.py" %*
exit /b %errorlevel%

:old_windows
echo This needs Windows 10 version 1803 or newer, which include curl and tar.
goto failed

:no_download
echo Python could not be downloaded. Check your internet connection and try again.
goto failed

:bad_checksum
echo The download did not match its expected checksum, so it was not used.
del "%ARCHIVE%"
goto failed

:no_unpack
echo Python could not be unpacked. Delete tools\runtime and try again.
goto failed

:failed
if "%~1"=="" pause
exit /b 1
