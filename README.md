# 金蝶开发者社区搜索 MCP Server

这是一个 Model Context Protocol (MCP) 服务器，用于搜索金蝶开发者社区的知识库。

## 功能特性

- 🔍 根据关键字搜索金蝶开发者社区知识库
- 📊 以表格形式展示搜索结果
- 📈 显示统计信息（活动数、SDK数、资源数等）
- 🔗 提供知识库链接
- 📄 显示高亮摘要内容

## 安装

1. 确保已安装 Python 3.8 或更高版本

2. 安装依赖：
```bash
pip install -r requirements.txt
```

## 使用方法

### 作为 MCP Server 运行

1. 启动服务器：
```bash
python src/kingdee_search_server.py
```

2. 服务器将通过 stdio 与 MCP 客户端通信

### 工具说明

#### `search_kingdee_developer`

搜索金蝶开发者社区的知识库。

**参数：**
- `keyword` (必需): 搜索关键字，例如："自定义API"、"Java插件"等
- `pageNo` (可选): 页码，从1开始，默认为1
- `pageSize` (可选): 每页返回的结果数量，默认为20

**示例：**
```json
{
  "keyword": "自定义API",
  "pageNo": 1,
  "pageSize": 20
}
```

**返回：**
- 格式化的表格，包含：
  - 统计信息（活动数、SDK数、资源数、开发者数、OpenAPI数）
  - 搜索结果列表（标题、浏览量、ID、摘要、链接）

## API 说明

服务器调用以下API：
```
https://dev.kingdee.com/prod-api/kd/ecos/node/search?type=developer&keyword={keyword}&pageNo={pageNo}&pageSize={pageSize}
```

## 项目结构

```
mcp-server/
├── src/
│   └── kingdee_search_server.py  # MCP服务器主程序
├── requirements.txt              # Python依赖
└── README.md                    # 本文件
```

## 开发

### 依赖项

- `mcp`: Model Context Protocol SDK
- `httpx`: 异步HTTP客户端
- `typing-extensions`: 类型扩展支持

### 测试

可以通过MCP客户端工具（如 Claude Desktop）连接到此服务器进行测试。

## 部署

### 发布到 PyPI

1. 安装构建工具：
```bash
pip install build twine
```

2. 构建包：
```bash
python -m build
```

3. 上传到 PyPI：
```bash
twine upload dist/*
```

### 部署到 MCP 广场

详细的部署指南请参考 [DEPLOY.md](DEPLOY.md)，包括：
- 部署到魔搭 MCP 广场
- 发布到 PyPI
- GitHub 发布
- 本地部署

## 许可证

本项目为金蝶开发者工具的一部分。

