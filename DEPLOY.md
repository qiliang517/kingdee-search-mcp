# MCP 服务器部署指南

本指南介绍如何将金蝶开发者社区搜索 MCP 服务器部署到各种平台。

## 目录

1. [部署到 MCP 广场/市场](#部署到-mcp-广场市场)
2. [发布到 PyPI](#发布到-pypi)
3. [GitHub 发布](#github-发布)
4. [本地部署](#本地部署)

## 部署到 MCP 广场/市场

### 方式一：魔搭 MCP 广场（ModelScope）

魔搭提供了 MCP 广场，可以部署自定义 MCP 服务器。

#### 步骤：

1. **准备项目**
   - 确保项目结构完整
   - 确保 `requirements.txt` 包含所有依赖
   - 确保代码可以正常运行

2. **发布到 PyPI**（推荐）
   - 将项目打包并发布到 PyPI（见下方"发布到 PyPI"章节）
   - 在魔搭 MCP 广场创建服务时，可以直接引用 PyPI 包

3. **在魔搭创建 MCP 服务**
   - 登录魔搭平台
   - 进入 MCP 广场
   - 创建新的 MCP 服务
   - 填写服务信息：
     - 服务名称：`kingdee-search-server`
     - 描述：搜索金蝶开发者社区知识库的 MCP 服务器
     - 安装方式：选择 UVX 或直接引用 PyPI 包
   - 配置运行命令：
     ```bash
     python -m kingdee_search_server
     ```
   - 配置环境变量（如需要）

4. **测试和发布**
   - 在平台上测试服务
   - 确认无误后发布上线

### 方式二：官方 MCP 服务器列表

如果存在官方的 MCP 服务器市场（如 GitHub 上的 `modelcontextprotocol/servers`），可以：

1. **Fork 官方仓库**
   ```bash
   # 假设官方仓库是 modelcontextprotocol/servers
   git clone https://github.com/modelcontextprotocol/servers.git
   ```

2. **添加您的服务器**
   - 在 `servers/` 目录下创建新目录：`kingdee-search`
   - 复制项目文件到该目录
   - 创建 `README.md` 和配置文件

3. **提交 Pull Request**
   - 提交到您的 fork
   - 向官方仓库提交 Pull Request
   - 等待审核和合并

## 发布到 PyPI

将项目发布到 PyPI 可以让用户更容易安装和使用。

### 1. 创建必要的文件

#### `setup.py`

```python
from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

with open("requirements.txt", "r", encoding="utf-8") as fh:
    requirements = [line.strip() for line in fh if line.strip() and not line.startswith("#")]

setup(
    name="kingdee-search-mcp",
    version="1.0.0",
    author="Your Name",
    author_email="your.email@example.com",
    description="MCP Server for searching Kingdee Developer Community",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/yourusername/kingdee-search-mcp",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
    ],
    python_requires=">=3.8",
    install_requires=requirements,
    entry_points={
        "console_scripts": [
            "kingdee-search-server=kingdee_search_server:main",
        ],
    },
)
```

#### `src/__init__.py`

创建空文件或添加包信息。

#### `src/__main__.py`

```python
"""入口点，允许通过 python -m kingdee_search_server 运行"""
import asyncio
import sys
from kingdee_search_server import main

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        sys.exit(0)
```

### 2. 修改 `kingdee_search_server.py`

确保 `main` 函数可以被外部调用（已经存在）。

### 3. 构建和发布

```bash
# 安装构建工具
pip install build twine

# 构建包
python -m build

# 检查包
twine check dist/*

# 上传到 PyPI（测试）
twine upload --repository testpypi dist/*

# 上传到 PyPI（正式）
twine upload dist/*
```

### 4. 安装和使用

发布后，用户可以通过以下方式安装：

```bash
pip install kingdee-search-mcp
```

然后在 Claude Desktop 配置中使用：

```json
{
  "mcpServers": {
    "kingdee-search": {
      "command": "python",
      "args": ["-m", "kingdee_search_server"]
    }
  }
}
```

## GitHub 发布

### 1. 创建 GitHub 仓库

1. 在 GitHub 上创建新仓库
2. 初始化并推送代码：

```bash
git init
git add .
git commit -m "Initial commit: Kingdee Search MCP Server"
git branch -M main
git remote add origin https://github.com/yourusername/kingdee-search-mcp.git
git push -u origin main
```

### 2. 创建 Release

1. 在 GitHub 仓库页面，点击 "Releases"
2. 点击 "Create a new release"
3. 填写版本信息：
   - Tag: `v1.0.0`
   - Title: `v1.0.0 - Initial Release`
   - Description: 描述功能和更新
4. 发布 Release

### 3. 添加安装说明

在 README.md 中添加从 GitHub 安装的说明：

```markdown
## 从 GitHub 安装

```bash
pip install git+https://github.com/yourusername/kingdee-search-mcp.git
```
```

## 本地部署

### 方式一：直接运行

```bash
# 安装依赖
pip install -r requirements.txt

# 运行服务器
python src/kingdee_search_server.py
```

### 方式二：配置 Claude Desktop

编辑 Claude Desktop 配置文件（见 `INSTALL.md`），添加服务器配置。

### 方式三：使用 Docker（可选）

创建 `Dockerfile`：

```dockerfile
FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ ./src/

ENTRYPOINT ["python", "src/kingdee_search_server.py"]
```

构建和运行：

```bash
docker build -t kingdee-search-mcp .
docker run -it kingdee-search-mcp
```

## 部署检查清单

在部署前，请确保：

- [ ] 代码已测试，功能正常
- [ ] `requirements.txt` 包含所有依赖
- [ ] `README.md` 包含完整的使用说明
- [ ] 代码符合 MCP 协议规范
- [ ] 错误处理完善
- [ ] 日志输出合理
- [ ] 文档清晰完整

## 后续维护

- 定期更新依赖
- 修复 bug 并发布新版本
- 收集用户反馈
- 添加新功能

## 相关资源

- [MCP 官方文档](https://modelcontextprotocol.io/)
- [PyPI 发布指南](https://packaging.python.org/tutorials/packaging-projects/)
- [GitHub Actions 自动化发布](https://docs.github.com/en/actions/guides/publishing-python-packages-to-pypi)

