#!/usr/bin/env python3
"""
金蝶开发者社区搜索 MCP Server
提供搜索金蝶开发者社区知识库的功能
"""

import json
import urllib.parse
import sys
from typing import Any, Sequence
import httpx

# 可选导入 MCP 相关模块（用于 MCP 服务器功能）
try:
    from mcp.server import Server
    from mcp.server.stdio import stdio_server
    from mcp.types import Tool, TextContent
    MCP_AVAILABLE = True
except ImportError:
    MCP_AVAILABLE = False
    # 定义占位符类，用于类型提示
    Server = None
    stdio_server = None
    Tool = None
    TextContent = None

# 创建MCP服务器实例（仅在 MCP 可用时）
if MCP_AVAILABLE:
    app = Server("kingdee-search-server")
else:
    app = None

# API基础URL模板
BASE_URL = "https://dev.kingdee.com/prod-api/kd/ecos/node/search?type=developer&keyword={keyword}&pageNo={pageNo}&pageSize={pageSize}"

# 默认分页参数
DEFAULT_PAGE_NO = 1
DEFAULT_PAGE_SIZE = 20


def format_table(data: dict) -> str:
    """
    将搜索结果格式化为表格形式
    
    Args:
        data: API返回的JSON数据
        
    Returns:
        格式化后的表格字符串
    """
    if not data or "data" not in data:
        return "未找到数据"
    
    result_data = data["data"]
    search_results = result_data.get("searchResult", [])
    
    if not search_results:
        return "未找到搜索结果"
    
    # 构建表格
    lines = []
    
    # 添加统计信息
    lines.append("=" * 80)
    lines.append("搜索结果统计")
    lines.append("=" * 80)
    lines.append(f"活动数量: {result_data.get('activityCount', 0)}")
    lines.append(f"SDK数量: {result_data.get('sdkCount', 0)}")
    lines.append(f"资源数量: {result_data.get('resourceCount', 0)}")
    lines.append(f"开发者数量: {result_data.get('developerCount', 0)}")
    lines.append(f"OpenAPI数量: {result_data.get('openapiCount', 0)}")
    lines.append(f"知识库结果数: {len(search_results)}")
    lines.append("")
    
    # 添加表格标题
    lines.append("=" * 80)
    lines.append("知识库搜索结果")
    lines.append("=" * 80)
    lines.append("")
    
    # 表头
    header = f"{'序号':<6} {'标题':<40} {'浏览量':<10} {'ID':<20}"
    lines.append(header)
    lines.append("-" * 80)
    
    # 表格内容
    for idx, item in enumerate(search_results, 1):
        title = item.get("title", "无标题")
        # 截断过长的标题
        if len(title) > 38:
            title = title[:35] + "..."
        
        pageviews = item.get("pageviews", 0)
        knowledge_id = item.get("knowledgeId") or item.get("id") or "未知"
        # 确保 knowledge_id 是字符串
        if knowledge_id is None:
            knowledge_id = "未知"
        else:
            knowledge_id = str(knowledge_id)
        
        # 截断过长的ID
        if len(knowledge_id) > 18:
            knowledge_id = knowledge_id[:15] + "..."
        
        row = f"{idx:<6} {title:<40} {pageviews:<10} {knowledge_id:<20}"
        lines.append(row)
        
        # 添加高亮内容（如果有）
        highlight = item.get("highlight", {})
        if highlight:
            highlight_content = highlight.get("content", "")
            if highlight_content:
                # 清理HTML标签并截断
                import re
                clean_content = re.sub(r'<[^>]+>', '', highlight_content)
                if len(clean_content) > 70:
                    clean_content = clean_content[:67] + "..."
                lines.append(f"      摘要: {clean_content}")
        
        # 添加链接
        entity_url = item.get("entityUrl", "")
        if entity_url:
            lines.append(f"      链接: {entity_url}")
        
        lines.append("-" * 80)
    
    return "\n".join(lines)


async def search_kingdee(keyword: str, page_no: int = DEFAULT_PAGE_NO, page_size: int = DEFAULT_PAGE_SIZE) -> dict:
    """
    搜索金蝶开发者社区
    
    Args:
        keyword: 搜索关键字
        page_no: 页码，默认为1
        page_size: 每页大小，默认为20
        
    Returns:
        API返回的JSON数据
    """
    # URL编码关键字
    encoded_keyword = urllib.parse.quote(keyword)
    
    # 构建完整URL
    url = BASE_URL.format(
        keyword=encoded_keyword,
        pageNo=page_no,
        pageSize=page_size
    )
    
    # 发送HTTP请求
    async with httpx.AsyncClient(timeout=30.0) as client:
        try:
            response = await client.get(
                url,
                headers={
                    "User-Agent": "MCP-Kingdee-Search-Server/1.0",
                    "Accept": "application/json"
                }
            )
            response.raise_for_status()
            return response.json()
        except httpx.HTTPError as e:
            return {
                "code": -1,
                "msg": f"请求失败: {str(e)}",
                "data": {}
            }
        except json.JSONDecodeError as e:
            return {
                "code": -1,
                "msg": f"JSON解析失败: {str(e)}",
                "data": {}
            }


# MCP 服务器相关函数（仅在 MCP 可用时定义）
if MCP_AVAILABLE:
    @app.list_tools()
    async def list_tools() -> list[Tool]:
        """
        列出可用的工具
        """
        return [
            Tool(
                name="search_kingdee_developer",
                description="搜索金蝶开发者社区的知识库。根据关键字搜索相关文档、API、SDK等资源。",
                inputSchema={
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
            )
        ]


    @app.call_tool()
    async def call_tool(name: str, arguments: dict[str, Any] | None) -> Sequence[TextContent]:
        """
        处理工具调用
        """
        if name == "search_kingdee_developer":
            keyword = arguments.get("keyword", "") if arguments else ""
            if not keyword:
                return [
                    TextContent(
                        type="text",
                        text="错误: 必须提供搜索关键字"
                    )
                ]
            
            page_no = arguments.get("pageNo", DEFAULT_PAGE_NO) if arguments else DEFAULT_PAGE_NO
            page_size = arguments.get("pageSize", DEFAULT_PAGE_SIZE) if arguments else DEFAULT_PAGE_SIZE
            
            # 调用搜索API
            result = await search_kingdee(keyword, page_no, page_size)
            
            # 格式化输出
            if result.get("code") == 200:
                table_output = format_table(result)
                return [
                    TextContent(
                        type="text",
                        text=table_output
                    )
                ]
            else:
                error_msg = result.get("msg", "未知错误")
                return [
                    TextContent(
                        type="text",
                        text=f"搜索失败: {error_msg}\n原始响应: {json.dumps(result, ensure_ascii=False, indent=2)}"
                    )
                ]
        else:
            return [
                TextContent(
                    type="text",
                    text=f"未知工具: {name}"
                )
            ]


    async def _main_async():
        """
        主函数：启动MCP服务器
        """
        # 使用stdio传输
        async with stdio_server() as streams:
            await app.run(
                streams[0], 
                streams[1],
                app.create_initialization_options()
            )


def main_entry():
    """
    入口函数，用于 console_scripts 和 __main__.py
    """
    if not MCP_AVAILABLE:
        print("错误: MCP 模块未安装，无法启动 MCP 服务器")
        print("请运行: pip install -r requirements.txt")
        sys.exit(1)
    import asyncio
    try:
        asyncio.run(_main_async())
    except KeyboardInterrupt:
        sys.exit(0)


if __name__ == "__main__":
    main_entry()

