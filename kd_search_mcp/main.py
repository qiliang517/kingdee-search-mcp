# -*- coding: utf-8 -*-
"""kd-search-mcp 服务入口。"""

from typing import Any, Dict, Iterable, List

import httpx
from mcp.server.fastmcp import FastMCP

BASE_URL = "https://dev.kingdee.com/prod-api/kd/ecos/node/search"

# 创建 FastMCP 实例时传递配置
mcp = FastMCP("Demo", host="0.0.0.0", port=8000)


def _format_results(results: Iterable[Dict[str, Any]]) -> str:
    lines: List[str] = []
    for item in results:
        title = item.get("title") or ""
        url = item.get("entityUrl") or ""
        if not title and not url:
            continue
        lines.append(f"- [{title}]({url})")
    return "\n".join(lines)


@mcp.tool()
def search_developer(command: str, page_no: int = 1, page_size: int = 20) -> Dict[str, Any]:
    """当输入以 /kd 开头时调用金蝶开发者搜索接口，并返回接口原始数据及格式化列表。"""
    if not command.startswith("/kd"):
        raise ValueError("输入必须以 /kd 开头")
    keyword = command[len("/kd") :].strip()
    if not keyword:
        raise ValueError("请输入查询关键词")
    params = {
        "type": "developer",
        "keyword": keyword,
        "pageNo": page_no,
        "pageSize": page_size,
    }
    with httpx.Client(timeout=10.0) as client:
        response = client.get(BASE_URL, params=params)
        response.raise_for_status()
        payload = response.json()
    data = payload.get("data", {})
    results = data.get("searchResult") or []
    formatted = _format_results(results)
    return {
        "msg": payload.get("msg"),
        "code": payload.get("code"),
        "data": data,
        "formatted": formatted,
    }


# 为了兼容命令行运行
def main() -> None:
    """启动 MCP 服务器。"""
    mcp.run(transport="sse")


if __name__ == "__main__":
    main()