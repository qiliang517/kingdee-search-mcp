# kd-search-mcp

基于 FastMCP 的金蝶开发者站点搜索工具。使用 `/kd` 命令触发搜索，将返回接口原始数据及标题链接列表，便于在 MCP 客户端中浏览。

## 快速开始

```bash
uv pip install -e .
uv run mcp run kd_search_mcp.main:main
```

在 MCP 客户端输入 `/kd 关键词` 即可发起查询。
