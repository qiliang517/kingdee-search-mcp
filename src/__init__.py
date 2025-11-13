"""
Kingdee Search MCP Server

A Model Context Protocol (MCP) server for searching Kingdee Developer Community knowledge base.
"""

__version__ = "1.0.0"
__author__ = "Kingdee Developer"

from .kingdee_search_server import search_kingdee, format_table

__all__ = ["search_kingdee", "format_table"]

