@echo off
chcp 65001 >nul
setlocal ENABLEDELAYEDEXPANSION

rem default arguments
set "PYTHON_EXE=python"
set "WHEEL_DIR=wheels"
set "PLATFORM=win_amd64"

rem parse arguments
:parse_args
if "%~1"=="" goto :after_parse
if /I "%~1"=="--python" (
    set "PYTHON_EXE=%~2"
    shift & shift
    goto parse_args
)
if /I "%~1"=="--dir" (
    set "WHEEL_DIR=%~2"
    shift & shift
    goto parse_args
)
shift
goto parse_args

:after_parse

echo ========================================
echo Downloading all dependencies as wheels
echo ========================================
echo.

if not exist "%WHEEL_DIR%" mkdir "%WHEEL_DIR%"

echo =^> Checking Python version...
%PYTHON_EXE% --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python not found. Please install Python 3.12+ or specify path with --python
    exit /b 1
)

echo.
echo =^> Upgrading pip...
%PYTHON_EXE% -m pip install --upgrade pip --default-timeout=120 -i https://mirrors.aliyun.com/pypi/simple >nul 2>&1
if errorlevel 1 (
    echo WARNING: pip upgrade failed, continuing anyway...
)

echo.
echo =^> Installing wheel tool...
%PYTHON_EXE% -m pip install wheel --default-timeout=120 -i https://mirrors.aliyun.com/pypi/simple >nul 2>&1
if errorlevel 1 (
    echo ERROR: Failed to install wheel tool
    exit /b 1
)

echo.
echo =^> Downloading project dependencies...
echo Target directory: %WHEEL_DIR%
echo.

rem Create temporary requirements file for direct dependencies
set "TEMP_REQ=%TEMP%\pip_req_%RANDOM%.txt"
(
    echo mcp[cli]^>=1.21.0
    echo httpx^>=0.27.0
) > "%TEMP_REQ%"

rem Download direct dependencies as wheels (with dependencies)
%PYTHON_EXE% -m pip wheel --wheel-dir "%WHEEL_DIR%" -r "%TEMP_REQ%" -i https://mirrors.aliyun.com/pypi/simple >nul 2>&1
set "WHEEL_ERR=!errorlevel!"
del "%TEMP_REQ%" >nul 2>&1

if !WHEEL_ERR! neq 0 (
    echo ERROR: Failed to download some dependencies
    exit /b 1
)

echo.
echo =^> Downloading Windows-specific dependencies...
rem Download pywin32 for Windows platform support
%PYTHON_EXE% -m pip download pywin32>=310 --dest "%WHEEL_DIR%" --no-deps -i https://mirrors.aliyun.com/pypi/simple >nul 2>&1
if errorlevel 1 (
    echo WARNING: Failed to download pywin32 dependency
)

echo.
echo =^> Downloading project wheel...
if exist "dist\kd_search_mcp-0.1.0-py3-none-any.whl" (
    copy "dist\kd_search_mcp-0.1.0-py3-none-any.whl" "%WHEEL_DIR%\" >nul
    echo Copied project wheel to %WHEEL_DIR%
) else (
    echo WARNING: Project wheel not found in dist\ directory
    echo Please build the project first: python -m build
)

echo.
echo ========================================
echo Download complete!
echo ========================================
echo.
echo All wheels are saved in: %WHEEL_DIR%
echo.
echo To install offline, use:
echo   pip install --find-links "%WHEEL_DIR%" --no-index kd-search-mcp
echo.
echo Or use the updated run.bat with --offline flag
echo.

endlocal