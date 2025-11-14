param(
    [string]$PythonExe = "python",
    [string]$WheelPath = ".\kd_search_mcp-0.1.0-py3-none-any.whl",
    [string]$VenvDir = ".\.venv",
    [switch]$UseSse
)

$minMajor = 3
$minMinor = 8

Write-Host "=> 检查 Python 版本..." -ForegroundColor Cyan
$pythonVersion = & $PythonExe -c "import sys;print(sys.version_info.major, sys.version_info.minor)"
if (-not $pythonVersion) {
    Write-Error "未找到 Python，可通过参数 -PythonExe 指定路径。"
    exit 1
}
$major, $minor = $pythonVersion -split " "
if ([int]$major -lt $minMajor -or ([int]$major -eq $minMajor -and [int]$minor -lt $minMinor)) {
    Write-Error "Python 版本需要 >= $minMajor.$minMinor，当前为 $major.$minor。"
    exit 1
}

Write-Host "=> 创建虚拟环境..." -ForegroundColor Cyan
if (-not (Test-Path $VenvDir)) {
    & $PythonExe -m venv $VenvDir
}
$activateScript = Join-Path $VenvDir "Scripts\Activate.ps1"
if (-not (Test-Path $activateScript)) {
    Write-Error "虚拟环境未正确创建：$activateScript 缺失。"
    exit 1
}
. $activateScript

Write-Host "=> 升级 pip / setuptools / wheel..." -ForegroundColor Cyan
pip install --upgrade pip setuptools wheel | Out-Null

Write-Host "=> 安装 kd-search-mcp 包..." -ForegroundColor Cyan
pip install $WheelPath | Out-Null

Write-Host "=> 启动 MCP 服务..." -ForegroundColor Cyan
if ($UseSse) {
    mcp run kd_search_mcp.main:main --transport sse
} else {
    mcp run kd_search_mcp.main:main
}

