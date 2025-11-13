@echo off
chcp 65001 >nul
echo ========================================
echo 发布 kingdee-search-mcp 到 PyPI
echo ========================================
echo.

REM 检查是否安装了 build 和 twine
python -c "import build; import twine" 2>nul
if errorlevel 1 (
    echo [1/6] 安装构建工具...
    pip install --upgrade build twine
    if errorlevel 1 (
        echo 错误: 无法安装构建工具，请检查网络连接
        pause
        exit /b 1
    )
) else (
    echo [1/6] 构建工具已安装
)

echo.
echo [2/6] 清理旧的构建文件...
if exist build rmdir /s /q build
if exist dist rmdir /s /q dist
for /d %%d in (*.egg-info) do rmdir /s /q "%%d" 2>nul
echo 清理完成

echo.
echo [3/6] 构建包...
python -m build
if errorlevel 1 (
    echo 错误: 构建失败
    pause
    exit /b 1
)
echo 构建完成

echo.
echo [4/6] 检查包...
twine check dist/*
if errorlevel 1 (
    echo 警告: 包检查发现问题，请查看上面的输出
) else (
    echo 包检查通过
)

echo.
echo [5/6] 准备上传...
echo.
echo 请选择上传目标:
echo 1. TestPyPI (测试)
echo 2. PyPI (正式)
echo 3. 取消
echo.
set /p choice="请输入选择 (1/2/3): "

if "%choice%"=="1" (
    echo.
    echo 上传到 TestPyPI...
    echo 提示: 用户名请输入 __token__
    echo 提示: 密码请输入您的 TestPyPI API token
    twine upload --repository testpypi dist/*
) else if "%choice%"=="2" (
    echo.
    echo 上传到 PyPI...
    echo 提示: 用户名请输入 __token__
    echo 提示: 密码请输入您的 PyPI API token
    twine upload dist/*
) else (
    echo 已取消
    exit /b 0
)

if errorlevel 1 (
    echo.
    echo 错误: 上传失败
    pause
    exit /b 1
) else (
    echo.
    echo ========================================
    echo 发布成功！
    echo ========================================
    echo.
    if "%choice%"=="1" (
        echo 测试安装: pip install --index-url https://test.pypi.org/simple/ kingdee-search-mcp
    ) else (
        echo 安装: pip install kingdee-search-mcp
    )
)

echo.
pause

