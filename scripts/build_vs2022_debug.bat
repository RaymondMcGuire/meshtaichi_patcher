@echo off
setlocal

REM Visual Studio Debug build for meshtaichi_patcher_core (manual style).
REM Run this script from anywhere; it will switch to repo root.

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%\.."
set "LOG_DIR=%CD%\logs"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>nul
set "LOG_FILE=%LOG_DIR%\build_vs2022_debug.log"
set "STATUS_FILE=%LOG_DIR%\build_vs2022_debug.status.txt"

echo ================================================== > "%LOG_FILE%"
echo meshtaichi_patcher vs2022 debug build log >> "%LOG_FILE%"
echo start time: %DATE% %TIME% >> "%LOG_FILE%"
echo repo root : %CD% >> "%LOG_FILE%"
echo ================================================== >> "%LOG_FILE%"
echo RUNNING %DATE% %TIME% > "%STATUS_FILE%"

if not exist .venv\Scripts\python.exe (
  echo ERROR: .venv not found: .venv\Scripts\python.exe
  echo Create env first:
  echo   uv venv .venv
  echo   .venv\Scripts\activate.bat
  echo   uv pip install -U pip setuptools wheel cmake ninja
  pause
  exit /b 1
)

git submodule update --init --recursive
if errorlevel 1 (
  echo ERROR: git submodule update failed.
  echo FAILED %DATE% %TIME% > "%STATUS_FILE%"
  pause
  exit /b 1
) >> "%LOG_FILE%" 2>&1

if not exist build_vs_debug mkdir build_vs_debug
cd build_vs_debug

cmake .. -G "Visual Studio 17 2022" -A x64 ^
  -DCMAKE_BUILD_TYPE=Debug ^
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ^
  -DPYTHON_EXECUTABLE=../.venv/Scripts/python.exe ^
  -DCMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG=.. >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
  echo ERROR: CMake configure failed.
  echo FAILED %DATE% %TIME% > "%STATUS_FILE%"
  pause
  exit /b 1
)

cmake --build . --config Debug >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
  echo ERROR: Build failed.
  echo FAILED %DATE% %TIME% > "%STATUS_FILE%"
  pause
  exit /b 1
)

echo.
echo Build succeeded.
echo Solution: %CD%\meshtaichi_patcher_core.sln
echo Module output expected in repo root: ..\meshtaichi_patcher_core*.pyd
echo.
echo SUCCESS %DATE% %TIME% > "%STATUS_FILE%"
echo Log file: %LOG_FILE%
echo Status file: %STATUS_FILE%
pause
exit /b 0
