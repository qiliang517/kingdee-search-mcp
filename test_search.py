#!/usr/bin/env python3
"""
测试脚本：直接测试搜索功能，不通过MCP协议
"""

import asyncio
import sys
import os

# 添加src目录到路径
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from kingdee_search_server import search_kingdee, format_table


async def test_search():
    """测试搜索功能"""
    print("=" * 80)
    print("金蝶开发者社区搜索测试")
    print("=" * 80)
    print()
    
    # 测试关键字
    keyword = "自定义API"
    if len(sys.argv) > 1:
        keyword = sys.argv[1]
    
    print(f"搜索关键字: {keyword}")
    print()
    
    # 执行搜索
    result = await search_kingdee(keyword, page_no=1, page_size=20)
    
    # 显示结果
    if result.get("code") == 200:
        print(format_table(result))
    else:
        print(f"搜索失败: {result.get('msg', '未知错误')}")
        print(f"完整响应: {result}")


if __name__ == "__main__":
    asyncio.run(test_search())

