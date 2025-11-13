#!/bin/bash

echo "========================================"
echo "发布 kingdee-search-mcp 到 PyPI"
echo "========================================"
echo

# 检查是否安装了 build 和 twine
if ! python3 -c "import build; import twine" 2>/dev/null; then
    echo "[1/6] 安装构建工具..."
    pip3 install --upgrade build twine
    if [ $? -ne 0 ]; then
        echo "错误: 无法安装构建工具，请检查网络连接"
        exit 1
    fi
else
    echo "[1/6] 构建工具已安装"
fi

echo
echo "[2/6] 清理旧的构建文件..."
rm -rf build dist *.egg-info
echo "清理完成"

echo
echo "[3/6] 构建包..."
python3 -m build
if [ $? -ne 0 ]; then
    echo "错误: 构建失败"
    exit 1
fi
echo "构建完成"

echo
echo "[4/6] 检查包..."
twine check dist/*
if [ $? -ne 0 ]; then
    echo "警告: 包检查发现问题，请查看上面的输出"
else
    echo "包检查通过"
fi

echo
echo "[5/6] 准备上传..."
echo
echo "请选择上传目标:"
echo "1. TestPyPI (测试)"
echo "2. PyPI (正式)"
echo "3. 取消"
echo
read -p "请输入选择 (1/2/3): " choice

if [ "$choice" == "1" ]; then
    echo
    echo "上传到 TestPyPI..."
    echo "提示: 用户名请输入 __token__"
    echo "提示: 密码请输入您的 TestPyPI API token"
    twine upload --repository testpypi dist/*
elif [ "$choice" == "2" ]; then
    echo
    echo "上传到 PyPI..."
    echo "提示: 用户名请输入 __token__"
    echo "提示: 密码请输入您的 PyPI API token"
    twine upload dist/*
else
    echo "已取消"
    exit 0
fi

if [ $? -ne 0 ]; then
    echo
    echo "错误: 上传失败"
    exit 1
else
    echo
    echo "========================================"
    echo "发布成功！"
    echo "========================================"
    echo
    if [ "$choice" == "1" ]; then
        echo "测试安装: pip install --index-url https://test.pypi.org/simple/ kingdee-search-mcp"
    else
        echo "安装: pip install kingdee-search-mcp"
    fi
fi

