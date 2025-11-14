@echo off
chcp 65001 >nul
setlocal ENABLEDELAYEDEXPANSION

echo ========================================
echo Building offline package for kd-search-mcp
echo ========================================
echo.

rem Default arguments
set "PYTHON_EXE=python"

rem Parse arguments
:parse_args
if "%~1"=="" goto :after_parse
if /I "%~1"=="--python" (
    set "PYTHON_EXE=%~2"
    shift & shift
    goto parse_args
)
echo Unknown argument: %~1
exit /b 1

:after_parse

echo =^> Checking Python version...
%PYTHON_EXE% --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python not found. Please install Python 3.8+ or specify path with --python
    exit /b 1
)

rem Create directories
if not exist "dist" mkdir "dist"
if not exist "package" mkdir "package"
if not exist "package\wheels" mkdir "package\wheels"

rem Build the project wheel
echo =^> Building project wheel...
echo Using Python executable: %PYTHON_EXE%
%PYTHON_EXE% -m pip install --upgrade build --default-timeout=120 -i https://mirrors.aliyun.com/pypi/simple > package\build_prep.log 2>&1
if errorlevel 1 (
    echo WARNING: Failed to upgrade build tool. Continuing anyway...
)

%PYTHON_EXE% -m build > package\build.log 2>&1
if errorlevel 1 (
    echo ERROR: Failed to build project wheel. See package\build.log for details.
    exit /b 1
)

echo =^> Copying project wheel...
if exist "dist\kd_search_mcp-0.1.0-py3-none-any.whl" (
    copy "dist\kd_search_mcp-0.1.0-py3-none-any.whl" "package\wheels\" >nul
    echo Successfully copied project wheel to package\wheels\
) else (
    echo ERROR: Project wheel not found in dist\ directory
    exit /b 1
)

rem Download dependencies
echo =^> Downloading dependencies as wheels...
call download_dependencies.bat --python "%PYTHON_EXE%" --dir "package\wheels" > package\download.log 2>&1
if errorlevel 1 (
    echo WARNING: Some issues occurred while downloading dependencies. See package\download.log for details.
)

echo =^> Verifying wheel files...
set "WHEEL_COUNT=0"
for %%A in ("package\wheels\*.whl") do set /a "WHEEL_COUNT+=1"
if !WHEEL_COUNT! lss 5 (
    echo WARNING: Only !WHEEL_COUNT! wheels found. This may be insufficient for offline installation.
    echo Check package\wheels directory to ensure all dependencies were downloaded.
) else (
    echo Found !WHEEL_COUNT! wheel files in package\wheels directory.
)

rem Create install script
echo =^> Creating install script...
(
echo @echo off
echo chcp 65001 ^>nul
echo setlocal ENABLEDELAYEDEXPANSION
echo.
echo set "PYTHON_EXE=python"
echo.
echo rem Parse arguments
echo :parse_args
echo if "%%~1"=="" goto :after_parse
echo if /I "%%~1"=="--python" ^(
echo     set "PYTHON_EXE=%%~2"
echo     shift ^& shift
echo     goto parse_args
echo ^)
echo echo Unknown argument: %%~1
echo exit /b 1
echo.
echo :after_parse
echo.
echo echo Installing kd-search-mcp from local packages...
echo.
echo if not exist "%%~dp0wheels" ^(
echo     echo ERROR: wheels directory not found. Make sure you extracted the full package.
echo     pause
echo     exit /b 1
echo ^)
echo.
echo set "VENV_DIR=.venv"
echo.
echo echo Creating virtual environment...
echo %%PYTHON_EXE%% -m venv "%%VENV_DIR%%"
echo if errorlevel 1 ^(
echo     echo ERROR: Failed to create virtual environment
echo     pause
echo     exit /b 1
echo ^)
echo.
echo echo Activating virtual environment...
echo call "%%VENV_DIR%%\Scripts\activate.bat"
echo if errorlevel 1 ^(
echo     echo ERROR: Failed to activate virtual environment
echo     pause
echo     exit /b 1
echo ^)
echo.
echo echo Upgrading pip...
echo python -m pip install --upgrade pip --default-timeout=120 -i https://mirrors.aliyun.com/pypi/simple ^> install.log 2^>^&1
echo if errorlevel 1 ^(
echo     echo WARNING: Failed to upgrade pip. Continuing anyway...
echo ^)
echo.
echo echo Installing packages from local wheels...
echo pip install --find-links "%%~dp0wheels" --no-index --no-warn-script-location kd-search-mcp ^> install.log 2^>^&1
echo if errorlevel 1 ^(
echo     echo Trying alternative installation method...
echo     pip install --find-links "%%~dp0wheels" --no-index --no-warn-script-location --force-reinstall kd-search-mcp ^> install.log 2^>^&1
echo ^)
echo if errorlevel 1 ^(
echo     echo ERROR: Failed to install packages
echo     echo See install.log for details
echo     pause
echo     exit /b 1
echo ^)
echo.
echo echo Installation complete. You can now run the application with:
echo echo   %%VENV_DIR%%\Scripts\mcp.exe run kd_search_mcp.main:main
echo.
echo echo Alternatively, you can use the run.bat script provided in this package.
echo echo The run.bat script will automatically check and install the package if needed.
echo echo To use it with MCP client, configure your client to use the command:
echo echo   mcp run kd_search_mcp.main:main
echo pause
echo.
echo endlocal
echo exit /b 0
) > "package\install.bat"

echo =^> Creating package README...
(
echo # kd-search-mcp Offline Package
echo.
echo This package contains all necessary files to install kd-search-mcp in an offline environment.
echo.
echo ## Contents
echo - `wheels/` - Directory containing all required wheel files
echo - `install.bat` - Script to install the application
echo - `run.bat` - Script to run the application
echo - `build.log` - Log file from project build
echo - `download.log` - Log file from dependency download
echo.
echo ## Prerequisites
echo - Python 3.8 or higher installed on the target machine
echo.
echo ## Installation
echo 1. Extract this package to a directory
echo 2. Run `install.bat`
echo 3. The installer will create a virtual environment and install all dependencies
echo.
echo ## Usage
echo After installation, you can run the application in two ways:
echo.
echo 1. Using the run.bat script:
echo    Double-click run.bat or execute it from the command line
echo    The script will automatically check and install the package if needed
echo.
echo 2. Manually with the command:
echo    .venv\Scripts\mcp.exe run kd_search_mcp.main:main
echo.
echo In your MCP client, configure it to use the command:
echo    mcp run kd_search_mcp.main:main
echo.
echo Note: Make sure the virtual environment is activated when using the manual method.
echo.
echo ## Advanced Options
echo If you need to specify a specific Python interpreter for installation, use:
echo.
echo     install.bat --python C:\path\to\python.exe
echo.
echo ## Troubleshooting
echo If you encounter any issues during installation:
echo - Check the `install.log` file in this directory for detailed error messages
echo - Ensure all files were extracted correctly
echo - Verify Python 3.8+ is installed on the system
echo - Make sure you have sufficient disk space and permissions
echo.
) > "package\PACKAGE_README.md"

echo =^> Creating run script...
(
echo @echo off
echo chcp 65001 ^>nul
echo setlocal
echo.
echo echo Starting kd-search-mcp application...
echo.
echo if not exist ".venv" ^(
echo     echo ERROR: Virtual environment not found. Please run install.bat first.
echo     pause
echo     exit /b 1
echo ^)
echo.
echo echo Activating virtual environment...
echo call ".venv\Scripts\activate.bat"
echo if errorlevel 1 ^(
echo     echo ERROR: Failed to activate virtual environment
echo     pause
echo     exit /b 1
echo ^)
echo.
echo echo Checking if kd-search-mcp is installed...
echo python -c "import kd_search_mcp.main" ^>nul 2^>^&1
echo if errorlevel 1 ^(
echo     echo Installing kd-search-mcp package...
echo     pip install --find-links "%%~dp0wheels" --no-index --no-warn-script-location kd-search-mcp
echo     if errorlevel 1 ^(
echo         echo ERROR: Failed to install kd-search-mcp package
echo         pause
echo         exit /b 1
echo     ^)
echo ^)
echo.
echo echo Verifying all dependencies are installed...
echo python -c "import rpds" ^>nul 2^>^&1
echo if errorlevel 1 ^(
echo     echo Installing missing dependencies from wheels directory...
echo     pip install --find-links "%%~dp0wheels" --no-index --no-warn-script-location --force-reinstall kd-search-mcp
echo     if errorlevel 1 ^(
echo         echo ERROR: Failed to install all dependencies
echo         pause
echo         exit /b 1
echo     ^)
echo ^)

echo rem Install any missing dependencies individually
echo for %%%%i in ("%%~dp0wheels\*.whl") do ^(
echo     pip install "%%%%i" --no-index --force-reinstall ^>nul 2^>^&1
echo ^)
echo.
echo echo Running kd-search-mcp...
echo python -c "from kd_search_mcp.main import main; main()"
echo.
echo endlocal
echo exit /b 0
) > "package\run.bat"

echo.
echo ========================================
echo Offline package created successfully!
echo ========================================
echo.
echo Package location: package/
echo Total wheels: !WHEEL_COUNT!
echo.
echo To deploy on an offline machine:
echo 1. Copy the entire package folder to the target machine
echo 2. Run package\install.bat on the target machine
echo.
echo Tips:
echo - Use --python [path] parameter if you need to specify a specific Python interpreter
echo - Check the log files in package/ directory for any warnings or errors
echo.
pause
endlocal
exit /b 0