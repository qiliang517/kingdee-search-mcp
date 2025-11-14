@echo off
chcp 65001 >nul
setlocal ENABLEDELAYEDEXPANSION

rem default arguments, can be overridden via CLI
set "PYTHON_EXE=python"
set "WHEEL_PATH=kd_search_mcp-0.1.0-py3-none-any.whl"
set "VENV_DIR=.venv"
set "TRANSPORT=stdio"
set "MIN_MAJOR=3"
set "MIN_MINOR=8"
set "LOG_FILE=run.log"
set "WHEEL_DIR=wheels"
set "OFFLINE_MODE=0"

if exist "%LOG_FILE%" del "%LOG_FILE%"

rem parse arguments
:parse_args
if "%~1"=="" goto :after_parse
if /I "%~1"=="--python" (
    set "PYTHON_EXE=%~2"
    shift & shift
    goto parse_args
)
if /I "%~1"=="--wheel" (
    set "WHEEL_PATH=%~2"
    shift & shift
    goto parse_args
)
if /I "%~1"=="--venv" (
    set "VENV_DIR=%~2"
    shift & shift
    goto parse_args
)
if /I "%~1"=="--sse" (
    set "TRANSPORT=sse"
    shift
    goto parse_args
)
if /I "%~1"=="--offline" (
    set "OFFLINE_MODE=1"
    shift
    goto parse_args
)
if /I "%~1"=="--wheel-dir" (
    set "WHEEL_DIR=%~2"
    shift & shift
    goto parse_args
)
echo 未知参数: %~1
exit /b 1

:after_parse

set "PS_COMMAND=powershell -NoProfile -ExecutionPolicy Bypass"

call :log "=> verifying Python version..."
%PS_COMMAND% -Command ^
    "$pv = & '%PYTHON_EXE%' -c \"import sys;print(sys.version_info.major, sys.version_info.minor)\";" ^
    "if(-not $pv){Write-Error 'Python executable not found'; exit 1};" ^
    "$major,$minor = $pv -split ' '; if([int]$major -lt %MIN_MAJOR% -or ([int]$major -eq %MIN_MAJOR% -and [int]$minor -lt %MIN_MINOR%)){Write-Error \"Python >= %MIN_MAJOR%.%MIN_MINOR% required, got $major.$minor\"; exit 1}" ^
    >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    call :log "ERROR: Python version check failed. See %LOG_FILE% for details."
    exit /b 1
)

if not exist "%VENV_DIR%" (
    call :log "=> creating virtual environment..."
    %PS_COMMAND% -Command ^
        "& '%PYTHON_EXE%' -m venv '%VENV_DIR%'" ^
        >> "%LOG_FILE%" 2>&1
    if errorlevel 1 (
        call :log "ERROR: virtual environment creation failed. See %LOG_FILE% for details."
        exit /b 1
    )
)

set "ACTIVATE=%VENV_DIR%\Scripts\activate.bat"
if not exist "%ACTIVATE%" (
    call :log "ERROR: virtual environment activation script missing: %ACTIVATE%"
    exit /b 1
)
call "%ACTIVATE%"

call :log "=> upgrading pip..."
python -m pip install --upgrade pip --default-timeout=120 -i https://mirrors.aliyun.com/pypi/simple >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    call :log "ERROR: pip upgrade failed. See %LOG_FILE% for details."
    exit /b 1
)

call :log "=> upgrading setuptools / wheel..."
python -m pip install --upgrade setuptools wheel --default-timeout=120 -i https://mirrors.aliyun.com/pypi/simple >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    call :log "ERROR: setuptools/wheel upgrade failed. See %LOG_FILE% for details."
    exit /b 1
)

call :log "=> installing kd-search-mcp package..."
if "%OFFLINE_MODE%"=="1" (
    if not exist "%WHEEL_DIR%" (
        call :log "ERROR: Offline mode requires wheels directory: %WHEEL_DIR%"
        call :log "Please ensure wheels directory exists or run without --offline flag"
        exit /b 1
    )
    call :log "Using offline mode: installing from %WHEEL_DIR%"
    rem Try to find wheel file in wheels directory
    set "OFFLINE_WHEEL=%WHEEL_DIR%\kd_search_mcp-0.1.0-py3-none-any.whl"
    if exist "!OFFLINE_WHEEL!" (
        call :log "Found wheel file: !OFFLINE_WHEEL!"
        rem Install using wheel file, pip will automatically resolve dependencies from wheels directory
        python -m pip install --find-links "%WHEEL_DIR%" --no-index "!OFFLINE_WHEEL!" >> "%LOG_FILE%" 2>&1
        if errorlevel 1 (
            call :log "ERROR: Failed to install from wheel file. See %LOG_FILE% for details."
            call :log "Make sure all dependencies are available in %WHEEL_DIR%"
            exit /b 1
        )
    ) else (
        call :log "Wheel file not found, trying to install by package name..."
        rem Use package name and let pip find it in wheels directory
        python -m pip install --find-links "%WHEEL_DIR%" --no-index kd-search-mcp >> "%LOG_FILE%" 2>&1
        if errorlevel 1 (
            call :log "ERROR: Offline installation failed. See %LOG_FILE% for details."
            call :log "Make sure kd_search_mcp-0.1.0-py3-none-any.whl exists in %WHEEL_DIR%"
            exit /b 1
        )
    )
) else (
    rem Online mode: check if wheel file exists locally first
    set "LOCAL_WHEEL_FOUND=0"
    
    rem Check current directory
    if exist "%WHEEL_PATH%" (
        call :log "Found wheel in current directory: %WHEEL_PATH%"
        python -m pip install "%WHEEL_PATH%" --default-timeout=120 -i https://mirrors.aliyun.com/pypi/simple >> "%LOG_FILE%" 2>&1
        set "LOCAL_WHEEL_FOUND=1"
    )
    
    rem Check dist directory
    if "!LOCAL_WHEEL_FOUND!"=="0" (
        if exist "dist\%WHEEL_PATH%" (
            call :log "Found wheel in dist directory: dist\%WHEEL_PATH%"
            python -m pip install "dist\%WHEEL_PATH%" --default-timeout=120 -i https://mirrors.aliyun.com/pypi/simple >> "%LOG_FILE%" 2>&1
            set "LOCAL_WHEEL_FOUND=1"
        )
    )
    
    rem If wheel file not found locally, try installing by package name
    if "!LOCAL_WHEEL_FOUND!"=="0" (
        call :log "Wheel file not found locally, installing from PyPI..."
        python -m pip install kd-search-mcp --default-timeout=120 -i https://mirrors.aliyun.com/pypi/simple >> "%LOG_FILE%" 2>&1
    )
    
    if errorlevel 1 (
        call :log "ERROR: package installation failed. See %LOG_FILE% for details."
        exit /b 1
    )
)

rem Verify that the package is installed correctly
call :log "=> verifying kd-search-mcp installation..."
python -c "import kd_search_mcp.main" >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    call :log "ERROR: kd-search-mcp package not installed correctly. See %LOG_FILE% for details."
    exit /b 1
)

call :log "=> starting MCP service..."
if /I "%TRANSPORT%"=="sse" (
    python -c "from kd_search_mcp.main import main; main()" >> "%LOG_FILE%" 2>&1
) else (
    python -c "from kd_search_mcp.main import main; main()" >> "%LOG_FILE%" 2>&1
)

endlocal
:log
set "msg=%~1"
if defined msg (
    echo(!msg!
    >> "%LOG_FILE%" echo(!msg!
) else (
    echo.
    >> "%LOG_FILE%" echo.
)
exit /b 0