@echo off
setlocal

REM One-click local build/install for meshtaichi_patcher using uv on Windows.
REM Run from anywhere: this script switches to repo root automatically.
REM On failure, script will pause and print log location.

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%\.."
set "LOG_DIR=%CD%\logs"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>nul
set "LOG_FILE=%LOG_DIR%\install_with_uv.log"
set "STATUS_FILE=%LOG_DIR%\install_with_uv.status.txt"
set "UV_CACHE_DIR=%CD%\.uv-cache"
if not exist "%UV_CACHE_DIR%" mkdir "%UV_CACHE_DIR%" >nul 2>nul

echo ================================================== > "%LOG_FILE%"
echo meshtaichi_patcher uv install log >> "%LOG_FILE%"
echo start time: %DATE% %TIME% >> "%LOG_FILE%"
echo repo root : %CD% >> "%LOG_FILE%"
echo uv cache  : %UV_CACHE_DIR% >> "%LOG_FILE%"
echo ================================================== >> "%LOG_FILE%"
echo RUNNING %DATE% %TIME% > "%STATUS_FILE%"

echo [1/6] Checking required tools...
where uv >nul 2>nul
if errorlevel 1 (
  echo ERROR: 'uv' not found in PATH.
  echo Install uv first: https://docs.astral.sh/uv/
  goto :fail
)

where git >nul 2>nul
if errorlevel 1 (
  echo ERROR: 'git' not found in PATH.
  goto :fail
)

echo [2/6] Creating virtual environment (.venv)...
call :run "uv venv .venv"
if errorlevel 1 goto :fail

echo [3/6] Activating virtual environment...
call .venv\Scripts\activate.bat
if errorlevel 1 (
  echo ERROR: failed to activate .venv
  goto :fail
)

echo [4/6] Syncing git submodules...
call :run "git submodule update --init --recursive"
if errorlevel 1 goto :fail

echo [5/6] Installing build dependencies...
call :run "uv pip install -U pip setuptools wheel cmake ninja"
if errorlevel 1 goto :fail

echo [6/6] Building and installing package (editable)...
if defined CMAKE_ARGS (
  set "CMAKE_ARGS=%CMAKE_ARGS% -DCMAKE_POLICY_VERSION_MINIMUM=3.5"
) else (
  set "CMAKE_ARGS=-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
)
call :run "uv pip install -e . --no-build-isolation"
if errorlevel 1 goto :fail

echo Verifying Python binding...
echo ---------- >> "%LOG_FILE%"
echo STEP: python import verification >> "%LOG_FILE%"
echo TIME: %DATE% %TIME% >> "%LOG_FILE%"
echo ---------- >> "%LOG_FILE%"
python -c "import sys, meshtaichi_patcher_core as m; print('python =', sys.executable); print('module =', m.__file__); print('version =', getattr(m, '__version__', 'dev'))" >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
  echo ERROR: step failed - python import verification
  goto :fail
)

echo.
echo Done. Virtual env: %CD%\.venv
echo To use later:
echo   call .venv\Scripts\activate.bat
echo.
echo Log file: "%LOG_FILE%"
echo SUCCESS %DATE% %TIME% > "%STATUS_FILE%"
echo Status file: "%STATUS_FILE%"
pause
exit /b 0

:run
set "CMD=%~1"
echo ---------- >> "%LOG_FILE%"
echo STEP: %CMD% >> "%LOG_FILE%"
echo TIME: %DATE% %TIME% >> "%LOG_FILE%"
echo CMD : %CMD% >> "%LOG_FILE%"
echo ---------- >> "%LOG_FILE%"
echo Running: %CMD%
call %CMD% >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
  echo ERROR: step failed - %CMD%
  exit /b 1
)
exit /b 0

:fail
echo FAILED %DATE% %TIME% > "%STATUS_FILE%"
echo.
echo Installation failed. Check log:
echo   "%LOG_FILE%"
echo Status file:
echo   "%STATUS_FILE%"
echo.
echo Last 40 log lines:
powershell -NoProfile -Command "Get-Content -Path '%LOG_FILE%' -Tail 40"
echo.
pause
exit /b 1
