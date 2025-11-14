@echo off
chcp 65001 >nul
setlocal ENABLEDELAYEDEXPANSION

echo ========================================
echo Creating complete offline package
echo ========================================
echo.

set "PYTHON_EXE=python"
set "PACKAGE_NAME=kd-search-mcp-offline"
set "VERSION=0.1.0"
set "OUTPUT_DIR=package"

rem parse arguments
:parse_args
if "%~1"=="" goto after_parse
if /I "%~1"=="--python" (
    set "PYTHON_EXE=%~2"
    shift & shift
    goto parse_args
)
if /I "%~1"=="--output" (
    set "OUTPUT_DIR=%~2"
    shift & shift
    goto parse_args
)
shift
goto parse_args

:after_parse

echo Step 1: Building project wheel...
if not exist "dist" mkdir "dist"
%PYTHON_EXE% -m pip install --upgrade build --default-timeout=120 -i https://mirrors.aliyun.com/pypi/simple >nul 2>&1
%PYTHON_EXE% -m build
if errorlevel 1 (
    echo ERROR: Failed to build project
    exit /b 1
)
echo ✓ Project wheel built
echo.

echo Step 2: Downloading all dependencies...
call download_dependencies.bat --python "%PYTHON_EXE%"
if errorlevel 1 (
    echo ERROR: Failed to download dependencies
    exit /b 1
)
echo ✓ Dependencies downloaded
echo.

echo Step 3: Creating package directory...
if exist "%OUTPUT_DIR%" rmdir /s /q "%OUTPUT_DIR%"
mkdir "%OUTPUT_DIR%"
mkdir "%OUTPUT_DIR%\wheels"
echo ✓ Package directory created
echo.

echo Step 4: Copying files...
copy "dist\kd_search_mcp-0.1.0-py3-none-any.whl" "%OUTPUT_DIR%\wheels\" >nul
xcopy /E /I /Y "wheels\*" "%OUTPUT_DIR%\wheels\" >nul
copy "run.bat" "%OUTPUT_DIR%\" >nul
copy "README.md" "%OUTPUT_DIR%\" >nul
echo ✓ Files copied
echo.

echo Step 5: Creating installation script...
(
    echo @echo off
    echo chcp 65001 ^>nul
    echo echo ========================================
    echo echo Installing kd-search-mcp offline
    echo echo ========================================
    echo echo.
    echo echo This package contains all dependencies.
    echo echo No internet connection required.
    echo echo.
    echo set "PYTHON_EXE=python"
    echo if not "%%1"=="" set "PYTHON_EXE=%%1"
    echo.
    echo echo Creating virtual environment...
    echo "%%PYTHON_EXE%%" -m venv .venv
    echo if errorlevel 1 ^(
    echo     echo ERROR: Failed to create virtual environment
    echo     exit /b 1
    echo ^)
    echo.
    echo echo Activating virtual environment...
    echo call .venv\Scripts\activate.bat
    echo.
    echo echo Installing from local wheels...
    echo python -m pip install --upgrade pip --find-links "wheels" --no-index --quiet
    echo python -m pip install --find-links "wheels" --no-index kd-search-mcp
    echo if errorlevel 1 ^(
    echo     echo ERROR: Installation failed
    echo     exit /b 1
    echo ^)
    echo.
    echo echo ========================================
    echo echo Installation complete!
    echo echo ========================================
    echo echo.
    echo echo To start the MCP service, run:
    echo echo   .venv\Scripts\activate
    echo echo   mcp run kd_search_mcp.main:main
    echo.
) > "%OUTPUT_DIR%\install.bat"
echo ✓ Installation script created
echo.

echo Step 6: Creating README...
(
    echo # kd-search-mcp Offline Package
    echo.
    echo This is a complete offline installation package containing all dependencies.
    echo.
    echo ## Installation
    echo.
    echo 1. Extract this package to your desired location
    echo 2. Run `install.bat` ^(or `install.bat "C:\Python312\python.exe"` to specify Python path^)
    echo 3. Activate the virtual environment: `.venv\Scripts\activate`
    echo 4. Start the service: `mcp run kd_search_mcp.main:main`
    echo.
    echo ## Contents
    echo.
    echo - `wheels/` - All Python package wheels ^(including dependencies^)
    echo - `install.bat` - Offline installation script
    echo - `run.bat` - Service startup script ^(use with --offline flag^)
    echo.
) > "%OUTPUT_DIR%\PACKAGE_README.md"
echo ✓ Package README created
echo.

echo ========================================
echo Package created successfully!
echo ========================================
echo.
echo Package location: %OUTPUT_DIR%
echo.
echo To distribute, zip the entire "%OUTPUT_DIR%" folder.
echo.
echo To install on target machine:
echo   1. Extract the zip file
echo   2. Run install.bat
echo.

endlocal

