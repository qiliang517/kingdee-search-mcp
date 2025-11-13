"""
Setup script for Kingdee Search MCP Server
"""
from setuptools import setup, find_packages
from pathlib import Path

# 读取 README
readme_file = Path(__file__).parent / "README.md"
long_description = readme_file.read_text(encoding="utf-8") if readme_file.exists() else ""

# 读取 requirements
requirements_file = Path(__file__).parent / "requirements.txt"
requirements = []
if requirements_file.exists():
    with open(requirements_file, "r", encoding="utf-8") as fh:
        requirements = [
            line.strip() 
            for line in fh 
            if line.strip() and not line.startswith("#")
        ]

setup(
    name="kingdee-search-mcp",
    version="1.0.0",
    author="Kingdee Developer",
    author_email="liang.qi@epichust.com",
    description="MCP Server for searching Kingdee Developer Community knowledge base",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/qiliang517/kingdee-search-mcp",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Programming Language :: Python :: 3.12",
    ],
    python_requires=">=3.8",
    install_requires=requirements,
    entry_points={
        "console_scripts": [
            "kingdee-search-server=kingdee_search_server:main_entry",
        ],
    },
    keywords="mcp, kingdee, search, developer, community",
    project_urls={
        "Bug Reports": "https://github.com/qiliang517/kingdee-search-mcp/issues",
        "Source": "https://github.com/qiliang517/kingdee-search-mcp",
        "Documentation": "https://github.com/qiliang517/kingdee-search-mcp#readme",
    },
)

