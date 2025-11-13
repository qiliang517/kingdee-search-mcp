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
python -m kingdee_search_server
```
或
```bash
python src/kingdee_search_server.py
```

2. 服务器通过 stdio 与 MCP 客户端通信

### 工具说明

#### `search_kingdee_developer`

搜索金蝶开发者社区的知识库。

- 参数：
  - `keyword` (必需): 搜索关键字，例如："自定义API"、"Java插件"等
  - `pageNo` (可选): 页码，从1开始，默认为1
  - `pageSize` (可选): 每页返回的结果数量，默认为20

- 示例：
```json
{
  "keyword": "自定义API",
  "pageNo": 1,
  "pageSize": 20
}
```

- 返回：
  - 统计信息（活动数、SDK数、资源数、开发者数、OpenAPI数）
  - 搜索结果列表（标题、浏览量、ID、摘要、链接）

## MCP 服务配置（机器可读）

以下 JSON 片段用于 MCP 广场/注册表自动解析：

```json
{
  "name": "kingdee-search-server",
  "type": "stdio",
  "description": "搜索金蝶开发者社区知识库的 MCP 服务器",
  "command": "python",
  "args": ["-m", "kingdee_search_server"],
  "env": {},
  "repository": "https://github.com/qiliang517/kingdee-search-mcp",
  "license": "MIT",
  "tools": [
    {
      "name": "search_kingdee_developer",
      "description": "根据关键字搜索金蝶开发者社区知识库，返回格式化表格。",
      "inputSchema": {
        "type": "object",
        "properties": {
          "keyword": {
            "type": "string",
            "description": "搜索关键字，例如：'自定义API'、'Java插件'等"
          },
          "pageNo": {
            "type": "integer",
            "description": "页码，从1开始，默认为1",
            "default": 1
          },
          "pageSize": {
            "type": "integer",
            "description": "每页返回的结果数量，默认为20",
            "default": 20
          }
        },
        "required": ["keyword"]
      }
    }
  ]
}
```

## API 说明

服务器调用以下 API：
```
https://dev.kingdee.com/prod-api/kd/ecos/node/search?type=developer&keyword={keyword}&pageNo={pageNo}&pageSize={pageSize}
```

## 项目结构

```
mcp-server/
├── src/
│   └── kingdee_search_server.py  # MCP 服务器主程序
├── requirements.txt              # Python 依赖
├── README.md                     # 本文件
└── 其他发布与部署文件
```

## 部署

### 发布到 PyPI（简要）
```bash
pip install build twine
python -m build
twine upload dist/*
```

### 部署到 MCP 广场
请参考 `DEPLOY.md` 获取完整步骤（魔搭 MCP 广场、PyPI、GitHub、本地部署）。

## 许可证

MIT
