# PyPI 发布指南

本指南将帮助您将 `kingdee-search-mcp` 发布到 PyPI。

## 发布前准备

### 1. 检查 setup.py 中的信息

在发布前，请确保 `setup.py` 中的以下信息正确：

- **name**: `kingdee-search-mcp` (包名，必须唯一)
- **version**: `1.0.0` (版本号)
- **author**: 您的名字或组织名
- **author_email**: 您的邮箱
- **url**: GitHub 仓库地址（如果已创建）

### 2. 创建 PyPI 账户

1. 访问 [PyPI](https://pypi.org/) 注册账户
2. 访问 [TestPyPI](https://test.pypi.org/) 注册测试账户（用于测试发布）

### 3. 创建 API Token

1. 登录 PyPI 后，进入 [账户设置](https://pypi.org/manage/account/)
2. 滚动到 "API tokens" 部分
3. 点击 "Add API token"
4. 设置作用域为 "Entire account" 或 "Only this project"
5. 复制生成的 token（格式：`pypi-...`）

## 发布步骤

### 步骤 1: 安装构建工具

```bash
pip install --upgrade build twine
```

如果网络有问题，可以使用国内镜像：

```bash
pip install --upgrade build twine -i https://pypi.tuna.tsinghua.edu.cn/simple
```

### 步骤 2: 清理旧的构建文件

```bash
# Windows
rmdir /s /q build dist *.egg-info 2>nul

# Linux/macOS
rm -rf build dist *.egg-info
```

### 步骤 3: 构建包

```bash
python -m build
```

这将创建：
- `dist/kingdee-search-mcp-1.0.0.tar.gz` (源码包)
- `dist/kingdee_search_mcp-1.0.0-py3-none-any.whl` (wheel 包)

### 步骤 4: 检查包

```bash
twine check dist/*
```

检查包是否有问题。

### 步骤 5: 上传到 TestPyPI（推荐先测试）

```bash
twine upload --repository testpypi dist/*
```

系统会提示输入：
- Username: `__token__`
- Password: 您的 API token（以 `pypi-` 开头）

### 步骤 6: 测试安装

```bash
pip install --index-url https://test.pypi.org/simple/ kingdee-search-mcp
```

### 步骤 7: 上传到正式 PyPI

测试成功后，上传到正式 PyPI：

```bash
twine upload dist/*
```

同样需要输入：
- Username: `__token__`
- Password: 您的 API token

## 发布后验证

1. 访问 https://pypi.org/project/kingdee-search-mcp/ 查看您的包
2. 测试安装：
   ```bash
   pip install kingdee-search-mcp
   ```
3. 测试运行：
   ```bash
   python -m kingdee_search_server
   ```

## 更新版本

发布新版本时：

1. 更新 `setup.py` 中的 `version`
2. 更新 `src/__init__.py` 中的 `__version__`
3. 重新构建和上传：
   ```bash
   python -m build
   twine upload dist/*
   ```

## 常见问题

### 问题：包名已存在

**解决方案**：修改 `setup.py` 中的 `name` 字段，使用更独特的名称，例如：
- `kingdee-search-mcp-server`
- `kingdee-dev-search-mcp`
- `yourname-kingdee-search-mcp`

### 问题：上传失败 - 403 Forbidden

**解决方案**：
- 检查 API token 是否正确
- 确保用户名使用 `__token__`
- 检查 token 的作用域是否正确

### 问题：上传失败 - 包名冲突

**解决方案**：
- 如果之前上传过相同版本，需要删除或升级版本号
- PyPI 不允许覆盖已发布的版本

## 使用 .pypirc 配置文件（可选）

创建 `~/.pypirc` 文件（Windows: `%USERPROFILE%\.pypirc`）：

```ini
[distutils]
index-servers =
    pypi
    testpypi

[pypi]
username = __token__
password = pypi-your-api-token-here

[testpypi]
repository = https://test.pypi.org/legacy/
username = __token__
password = pypi-your-test-token-here
```

然后可以直接使用：
```bash
twine upload --repository testpypi dist/*
twine upload dist/*
```

**注意**：请妥善保管 API token，不要提交到 Git 仓库！

