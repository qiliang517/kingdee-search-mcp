"""
入口点模块，允许通过 python -m kingdee_search_server 运行服务器
"""
import sys

# 导入主模块
try:
    from .kingdee_search_server import main_entry
except ImportError:
    # 如果作为脚本直接运行
    from kingdee_search_server import main_entry

if __name__ == "__main__":
    main_entry()

