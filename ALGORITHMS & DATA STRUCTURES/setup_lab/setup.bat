@echo off
rem ============================================================================
rem  Algorithms and Data Structures: lab setup for Windows 10 and 11
rem
rem  Double-click this file, or run it from PowerShell or Command Prompt:
rem    setup.bat                     install what is missing; create %USERPROFILE%\UTP-ADS
rem    setup.bat "D:\Uni\UTP-ADS"    the same, with a project folder of your choice
rem    setup.bat --check             report what is installed; change nothing
rem    setup.bat --no-install        install no software; set up the Path and project only
rem    setup.bat --no-open           do not open VS Code at the end
rem    setup.bat --yes               do not ask before installing
rem
rem  It installs only what is missing, and asks before it starts:
rem    MSYS2 with its UCRT64 GCC compiler and GDB debugger, in C:\msys64
rem    Visual Studio Code, and Microsoft's C/C++ extension for it
rem  It adds C:\msys64\ucrt64\bin to your user Path, copies the VS Code settings
rem  from the vscode folder into the project, and builds check_setup.cpp to
rem  prove that everything works. Run it again whenever you like: whatever is
rem  already in place is left as it is.
rem ============================================================================
setlocal EnableExtensions DisableDelayedExpansion
title Algorithms and Data Structures - lab setup

set "HERE=%~dp0"
set "PROJECT=%USERPROFILE%\UTP-ADS"
set "MODE=setup"
set "INSTALL=1"
set "OPEN=1"
set "ASK=1"
set "HOLD=0"
set "RC=0"
set "PATH_CHANGED=0"
if "%~1"=="" set "HOLD=1"
if not defined MSYS2_ROOT set "MSYS2_ROOT=C:\msys64"
set "UCRT_BIN=%MSYS2_ROOT%\ucrt64\bin"
set "POWERSHELL=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"

:args
if "%~1"=="" goto args_done
set "ARG=%~1"
if /i "%ARG%"=="--check" set "MODE=check" & goto next_arg
if /i "%ARG%"=="--no-install" set "INSTALL=0" & goto next_arg
if /i "%ARG%"=="--no-open" set "OPEN=0" & goto next_arg
if /i "%ARG%"=="--yes" set "ASK=0" & goto next_arg
if /i "%ARG%"=="--help" goto usage
if /i "%ARG%"=="-h" goto usage
if /i "%ARG%"=="/?" goto usage
if "%ARG:~0,1%"=="-" goto bad_option
set "PROJECT=%~f1"
:next_arg
shift
goto args
:args_done

echo.
echo  Algorithms and Data Structures - lab setup
echo  ------------------------------------------
if not exist "%HERE%vscode\tasks.json" goto missing_files
if not exist "%HERE%check_setup.cpp" goto missing_files

call :detect
echo.
echo  Found on this computer
call :row "C++ compiler" "%GPP_TEXT%"
call :row "Debugger" "%GDB_TEXT%"
call :row "VS Code" "%CODE_TEXT%"
call :row "C/C++ extension" "%EXT_TEXT%"
call :row "Project folder" "%PROJECT%"
if "%MODE%"=="check" goto verify

rem ---------------------------------------------------------------- the plan
set "NEED_MSYS2=0"
set "NEED_GCC=0"
set "NEED_CODE=0"
set "NEED_EXT=0"
if not defined GPP set "NEED_GCC=1"
if not defined GPP if not exist "%MSYS2_ROOT%\usr\bin\bash.exe" set "NEED_MSYS2=1"
if not defined GDB if exist "%UCRT_BIN%\g++.exe" set "NEED_GCC=1"
if not defined CODE set "NEED_CODE=1"
if "%CPPTOOLS%"=="0" set "NEED_EXT=1"
set /a NEEDS=NEED_MSYS2+NEED_GCC+NEED_CODE+NEED_EXT
if %NEEDS%==0 goto step_compiler
if "%INSTALL%"=="0" goto plan_skipped

echo.
echo  To finish, this script will install:
if "%NEED_MSYS2%"=="1" call :say "    - MSYS2, in %MSYS2_ROOT% (with winget)"
if "%NEED_GCC%"=="1" echo    - the GCC compiler and GDB debugger from MSYS2 (a few hundred MB, with pacman)
if "%NEED_CODE%"=="1" echo    - Visual Studio Code (with winget)
if "%NEED_EXT%"=="1" echo    - Microsoft's C/C++ extension for VS Code
if "%NEED_GCC%"=="1" call :say "  and add %UCRT_BIN% to your user Path."
if "%NEED_MSYS2%"=="1" echo  Windows may ask for permission to install MSYS2.
if "%ASK%"=="0" goto step_compiler
echo.
echo  Press any key to start, or close this window to cancel.
pause >nul
goto step_compiler

:plan_skipped
echo.
echo  --no-install: nothing will be installed.

rem ------------------------------------------------- 1. compiler and debugger
:step_compiler
echo.
echo  [1/4] Compiler and debugger
if "%INSTALL%"=="0" goto compiler_done
if "%NEED_GCC%"=="0" goto compiler_done
if "%NEED_MSYS2%"=="0" goto install_gcc
if /i not "%MSYS2_ROOT%"=="C:\msys64" goto msys2_custom_root
where winget.exe >nul 2>&1 || goto no_winget_msys2
winget install --id MSYS2.MSYS2 --exact --source winget --accept-package-agreements --accept-source-agreements
if not exist "%MSYS2_ROOT%\usr\bin\bash.exe" goto msys2_failed

:install_gcc
set "MSYS_BASH=%MSYS2_ROOT%\usr\bin\bash.exe"
rem The first login sets MSYS2 up; two updates bring pacman and its packages up to date.
"%MSYS_BASH%" -lc " "
"%MSYS_BASH%" -lc "pacman --noconfirm -Syuu"
"%MSYS_BASH%" -lc "pacman --noconfirm -Syuu"
"%MSYS_BASH%" -lc "pacman --noconfirm --needed -S mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-gdb"
if errorlevel 1 goto pacman_failed
if not exist "%UCRT_BIN%\g++.exe" goto pacman_failed
call :detect

:compiler_done
call :say "       %GPP_TEXT%"
call :say "       debugger: %GDB_TEXT%"

rem ------------------------------------------------------------------ 2. Path
echo.
echo  [2/4] Path
if not defined GPP (echo        skipped: there is no compiler yet & goto step_code)
if /i not "%BIN_DIR%"=="%UCRT_BIN%" (call :say "       %BIN_DIR% is already on your Path" & goto step_code)
set "UTP_ADD=%UCRT_BIN%"
"%POWERSHELL%" -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $d=([string]$env:UTP_ADD).TrimEnd('\'); $k='HKCU:\Environment'; $raw=[string](Get-Item $k).GetValue('Path','','DoNotExpandEnvironmentNames'); $parts=@($raw -split ';' | Where-Object { $_ -ne '' }); $all=@($parts) + @([string][Environment]::GetEnvironmentVariable('Path','Machine') -split ';'); if ($all | Where-Object { [Environment]::ExpandEnvironmentVariables($_).TrimEnd('\') -ieq $d }) { '       already on your Path: ' + $d; exit 0 }; Set-ItemProperty -Path $k -Name Path -Value ((@($parts) + $d) -join ';') -Type ExpandString; [Environment]::SetEnvironmentVariable('UTP_ADS_PATH_REFRESH','1','User'); [Environment]::SetEnvironmentVariable('UTP_ADS_PATH_REFRESH',$null,'User'); '       added to your user Path: ' + $d; exit 10"
if errorlevel 10 set "PATH_CHANGED=1" & goto path_session
if errorlevel 1 call :say "       Could not change your Path. Add %UCRT_BIN% to it yourself (see Chapter 1)."
:path_session
set "PATH=%UCRT_BIN%;%PATH%"

rem --------------------------------------------------- 3. VS Code and extension
:step_code
echo.
echo  [3/4] VS Code
if "%INSTALL%"=="0" goto code_done
if defined CODE goto install_ext
where winget.exe >nul 2>&1 || goto no_winget_code
winget install --id Microsoft.VisualStudioCode --exact --source winget --scope user --accept-package-agreements --accept-source-agreements
call :detect
if not defined CODE goto code_failed
:install_ext
if "%CPPTOOLS%"=="1" goto code_done
call "%CODE%" --install-extension ms-vscode.cpptools
call :detect
:code_done
call :say "       %CODE_LINE%"

rem --------------------------------------------------------- 4. project folder
:step_project
echo.
echo  [4/4] Project folder
if not exist "%PROJECT%\" mkdir "%PROJECT%" 2>nul
if not exist "%PROJECT%\" goto project_failed
for %%N in (01 02 03 04 05 06 07 08 09 10 11) do if not exist "%PROJECT%\Lab%%N\" mkdir "%PROJECT%\Lab%%N"
set "UTP_SRC=%HERE%vscode"
set "UTP_DST=%PROJECT%\.vscode"
set "UTP_BIN=%BIN_DIR%"
rem Copy the settings and point them at this computer's compiler folder. A setting
rem file you changed is kept beside the new one, with .bak added to its name.
"%POWERSHELL%" -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $bin=([string]$env:UTP_BIN).TrimEnd('\'); $dst=$env:UTP_DST; New-Item -ItemType Directory -Force -Path $dst | Out-Null; foreach ($f in Get-ChildItem -LiteralPath $env:UTP_SRC -Filter *.json) { $t=[IO.File]::ReadAllText($f.FullName); if ($bin) { $t=$t.Replace('C:\\msys64\\ucrt64\\bin', $bin.Replace('\','\\')).Replace('C:/msys64/ucrt64/bin', $bin.Replace('\','/')) }; $out=Join-Path $dst $f.Name; if (Test-Path -LiteralPath $out) { if ([IO.File]::ReadAllText($out) -ceq $t) { continue }; Copy-Item -LiteralPath $out -Destination ($out + '.bak') -Force; '       kept your previous ' + $f.Name + ' as ' + $f.Name + '.bak' }; [IO.File]::WriteAllText($out, $t) }"
if errorlevel 1 goto project_failed
if not exist "%PROJECT%\README.md" copy /y "%HERE%project\README.md" "%PROJECT%\README.md" >nul
if not exist "%PROJECT%\.gitignore" copy /y "%HERE%project\gitignore" "%PROJECT%\.gitignore" >nul
call :say "       %PROJECT%"
echo        Lab01 to Lab11, .vscode settings, README.md and .gitignore

rem ------------------------------------------------------------- the check
:verify
echo.
if not defined GPP goto no_compiler
echo  Check: building and running check_setup.cpp
set "PATH=%BIN_DIR%;%PATH%"
set "CHECK_DIR=%TEMP%\utp-ads-check"
if not exist "%CHECK_DIR%\" mkdir "%CHECK_DIR%"
"%GPP%" -std=c++17 -Wall -Wextra -pedantic "%HERE%check_setup.cpp" -o "%CHECK_DIR%\check_setup.exe"
if errorlevel 1 goto check_failed
"%CHECK_DIR%\check_setup.exe"
if errorlevel 1 goto check_failed
if "%MODE%"=="check" goto finish
if not defined CODE goto ready
if "%OPEN%"=="1" call "%CODE%" "%PROJECT%"

:ready
echo.
echo  Ready. In VS Code, open a .cpp file in your project folder, then press
echo  Ctrl+Shift+B to build and run it, or F5 to run it in the debugger.
if "%PATH_CHANGED%"=="1" echo  If VS Code was open before this setup, close all of its windows first.
if not defined CODE echo  Install VS Code from https://code.visualstudio.com, then run this script again.
goto finish

rem ------------------------------------------------------------ subroutines
:detect
set "GPP="
set "GDB="
set "CODE="
set "CPPTOOLS=0"
set "GPP_VER="
set "CODE_VER="
set "BIN_DIR="
if exist "%UCRT_BIN%\g++.exe" set "GPP=%UCRT_BIN%\g++.exe"
if not defined GPP for /f "delims=" %%G in ('where g++.exe 2^>nul') do if not defined GPP set "GPP=%%G"
if exist "%UCRT_BIN%\gdb.exe" set "GDB=%UCRT_BIN%\gdb.exe"
if not defined GDB for /f "delims=" %%G in ('where gdb.exe 2^>nul') do if not defined GDB set "GDB=%%G"
for /f "delims=" %%G in ('where code.cmd 2^>nul') do if not defined CODE set "CODE=%%G"
if not defined CODE if exist "%LOCALAPPDATA%\Programs\Microsoft VS Code\bin\code.cmd" set "CODE=%LOCALAPPDATA%\Programs\Microsoft VS Code\bin\code.cmd"
if not defined CODE if exist "%ProgramFiles%\Microsoft VS Code\bin\code.cmd" set "CODE=%ProgramFiles%\Microsoft VS Code\bin\code.cmd"
set "GPP_TEXT=not found"
set "GDB_TEXT=not found"
set "CODE_TEXT=not found"
set "EXT_TEXT=not installed"
set "CODE_LINE=VS Code not found"
if not defined GPP goto detect_gdb
for %%D in ("%GPP%") do set "BIN_DIR=%%~dpD"
set "BIN_DIR=%BIN_DIR:~0,-1%"
for /f "delims=" %%V in ('call "%%GPP%%" -dumpfullversion 2^>nul') do set "GPP_VER=%%V"
set "GPP_TEXT=g++ %GPP_VER%   %GPP%"
:detect_gdb
if defined GDB set "GDB_TEXT=%GDB%"
if not defined CODE goto :eof
for /f "delims=" %%V in ('call "%%CODE%%" --version 2^>nul') do if not defined CODE_VER set "CODE_VER=%%V"
set "CODE_TEXT=%CODE_VER%"
call "%CODE%" --list-extensions 2>nul | findstr /i /x /c:"ms-vscode.cpptools" >nul
if not errorlevel 1 set "CPPTOOLS=1"
if "%CPPTOOLS%"=="1" set "EXT_TEXT=installed"
if "%CPPTOOLS%"=="1" set "CODE_LINE=VS Code %CODE_VER% with the C/C++ extension"
if "%CPPTOOLS%"=="0" set "CODE_LINE=VS Code %CODE_VER%, without the C/C++ extension"
goto :eof

rem Print a label and a value that may hold special characters such as &.
:row
set "ROW_LABEL=%~1                    "
set "ROW_VALUE=%~2"
setlocal EnableDelayedExpansion
echo(   !ROW_LABEL:~0,19!!ROW_VALUE!
endlocal
goto :eof

rem Print one line that may hold special characters.
:say
set "SAY_TEXT=%~1"
setlocal EnableDelayedExpansion
echo(!SAY_TEXT!
endlocal
goto :eof

rem ---------------------------------------------------------------- endings
:usage
echo.
echo  Usage: setup.bat [folder] [--check] [--no-install] [--no-open] [--yes]
echo.
echo    folder         where to create your lab project (default: %%USERPROFILE%%\UTP-ADS)
echo    --check        report what is installed and build the test program; change nothing
echo    --no-install   install no software; set up the Path and the project folder only
echo    --no-open      do not open VS Code at the end
echo    --yes          do not ask before installing
exit /b 0

:bad_option
call :say " Unknown option: %ARG%"
echo  Run setup.bat --help to see the options.
set "RC=2"
goto finish

:missing_files
echo.
echo  This script needs the files next to it: check_setup.cpp and the vscode folder.
echo  Run it from inside the setup_lab folder of the course, not from a copy of the
echo  .bat file alone.
set "RC=1"
goto finish

:msys2_custom_root
call :say "       MSYS2_ROOT is set to %MSYS2_ROOT%, but MSYS2 is not installed there."
echo        Install MSYS2 into that folder from https://www.msys2.org, then run this script again.
set "RC=1"
goto finish

:no_winget_msys2
echo        winget, the Windows Package Manager, is not available on this computer.
echo        Install MSYS2 from https://www.msys2.org into C:\msys64, then run this
echo        script again: it installs GCC and GDB for you.
set "RC=1"
goto finish

:msys2_failed
echo        MSYS2 did not install. Install it from https://www.msys2.org into C:\msys64,
echo        then run this script again.
set "RC=1"
goto finish

:pacman_failed
echo        pacman could not install GCC and GDB. Check your internet connection and run
echo        this script again. If it fails twice, open "MSYS2 UCRT64" from the Start menu
echo        and run: pacman -S mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-gdb
set "RC=1"
goto finish

:no_winget_code
echo        winget is not available, so VS Code was not installed. Install it from
echo        https://code.visualstudio.com (tick "Add to PATH"), then run this script again.
goto step_project

:code_failed
echo        VS Code did not install. Install it from https://code.visualstudio.com
echo        (tick "Add to PATH"), then run this script again.
goto step_project

:project_failed
call :say "       Could not create or update %PROJECT%"
echo        Choose a folder you can write to, for example: setup.bat "%%USERPROFILE%%\UTP-ADS"
set "RC=1"
goto finish

:no_compiler
echo  No C++ compiler was found, so nothing could be built. Run setup.bat without
echo  --check or --no-install to install one.
set "RC=1"
goto finish

:check_failed
echo.
echo  The test program did not build or run. Read the messages above, then see
echo  "If something goes wrong" in setup_lab\README.md.
set "RC=1"
goto finish

:finish
if "%HOLD%"=="1" (echo. & echo  Press any key to close this window. & pause >nul)
endlocal & exit /b %RC%
