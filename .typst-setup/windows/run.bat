@echo off
setlocal DisableDelayedExpansion
for %%I in ("%~dp0..\..") do set "TYPST_ROOT=%%~fI"
set "TYPST_ENV=%TYPST_ROOT%\.venv-typst"
set "TYPST_CONDA="
if defined CONDA_EXE if exist "%CONDA_EXE%" set "TYPST_CONDA=%CONDA_EXE%"
if not defined TYPST_CONDA for /f "delims=" %%I in ('where conda 2^>nul') do if not defined TYPST_CONDA set "TYPST_CONDA=%%I"
if not defined TYPST_CONDA for %%I in ("%USERPROFILE%\anaconda3" "%LOCALAPPDATA%\anaconda3" "%ProgramData%\anaconda3" "%USERPROFILE%\miniconda3" "%LOCALAPPDATA%\miniconda3" "%ProgramData%\miniconda3") do if exist "%%~I\condabin\conda.bat" if not defined TYPST_CONDA set "TYPST_CONDA=%%~I\condabin\conda.bat"
if not defined TYPST_CONDA (
    echo Anaconda was not found. Run this script from Anaconda Prompt, or set CONDA_EXE to its conda executable.
    exit /b 1
)
if /i "%~nx1"=="install.py" goto install
goto run

:install
if exist "%TYPST_ENV%\conda-meta\history" goto run
if exist "%TYPST_ENV%" (
    echo "%TYPST_ENV%" exists but is not a Conda environment. Rename it before running step01 again.
    exit /b 1
)
call "%TYPST_CONDA%" create --yes --prefix "%TYPST_ENV%" python=3.12 pip
if errorlevel 1 exit /b %errorlevel%

:run
if not exist "%TYPST_ENV%\conda-meta\history" (
    echo Run step01-install.bat first to create "%TYPST_ENV%".
    exit /b 1
)
if not exist "%TYPST_ENV%\python.exe" (
    echo Python is missing from "%TYPST_ENV%". Repair this Conda environment before continuing.
    exit /b 1
)
call "%TYPST_CONDA%" run --no-capture-output --prefix "%TYPST_ENV%" "%TYPST_ENV%\python.exe" %*
exit /b %errorlevel%
