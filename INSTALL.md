# 安装和配置指南

## 前置要求

- Python 3.8 或更高版本
- pip 包管理器

## 安装步骤

### 1. 安装依赖

在 `mcp-server` 目录下运行：

```bash
pip install -r requirements.txt
```

### 2. 测试安装

运行测试脚本验证功能：

```bash
python test_search.py "自定义API"
```

或者直接运行服务器：

```bash
python src/kingdee_search_server.py
```

## 配置 Claude Desktop

### Windows

1. 打开 Claude Desktop 配置文件，通常位于：
   ```
   %APPDATA%\Claude\claude_desktop_config.json
   ```

2. 编辑配置文件，添加以下内容：

```json
{
  "mcpServers": {
    "kingdee-search": {
      "command": "python",
      "args": [
        "D:/epichust/kingdee/环境准备/kingdee-developer-tools-for-idea-2.3.1-GA/kingdee-developer-tools-for-idea/mcp-server/src/kingdee_search_server.py"
      ],
      "env": {
        "PYTHONPATH": "D:/epichust/kingdee/环境准备/kingdee-developer-tools-for-idea-2.3.1-GA/kingdee-developer-tools-for-idea/mcp-server"
      }
    }
  }
}
```

**注意**：请将路径替换为您的实际项目路径。

### macOS / Linux

1. 打开 Claude Desktop 配置文件：
   ```bash
   ~/Library/Application Support/Claude/claude_desktop_config.json  # macOS
   # 或
   ~/.config/Claude/claude_desktop_config.json  # Linux
   ```

2. 编辑配置文件：

```json
{
  "mcpServers": {
    "kingdee-search": {
      "command": "python3",
      "args": [
        "/path/to/your/project/mcp-server/src/kingdee_search_server.py"
      ],
      "env": {
        "PYTHONPATH": "/path/to/your/project/mcp-server"
      }
    }
  }
}
```

### 3. 重启 Claude Desktop

配置完成后，重启 Claude Desktop 以使配置生效。

## 使用方法

在 Claude Desktop 中，您可以直接使用自然语言请求搜索：

- "搜索金蝶开发者社区中关于'自定义API'的内容"
- "帮我找一下Java插件相关的文档"
- "搜索pageSize为10，pageNo为1的'自定义组件'相关内容"

Claude 会自动调用 MCP server 的工具来执行搜索并返回格式化的表格结果。

## 故障排除

### 问题：找不到 Python

**解决方案**：
- 确保 Python 已正确安装并在 PATH 中
- 在配置中使用完整路径，例如：`"C:\\Python39\\python.exe"`

### 问题：模块导入错误

**解决方案**：
- 确保已安装所有依赖：`pip install -r requirements.txt`
- 检查 PYTHONPATH 环境变量是否正确设置

### 问题：服务器无法启动

**解决方案**：
- 检查 Python 版本：`python --version`（需要 3.8+）
- 查看错误日志，通常在 Claude Desktop 的日志文件中
- 尝试直接运行服务器：`python src/kingdee_search_server.py`

### 问题：API 请求失败

**解决方案**：
- 检查网络连接
- 验证 API URL 是否可访问
- 检查防火墙设置

## 开发模式

如果您想修改代码，可以：

1. 直接编辑 `src/kingdee_search_server.py`
2. 使用测试脚本验证：`python test_search.py "关键字"`
3. 重启 Claude Desktop 以加载新代码

