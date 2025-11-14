"""基本测试占位，确保包可导入。"""

import importlib


def test_package_import() -> None:
    module = importlib.import_module("kd_search_mcp")
    assert hasattr(module, "main")

