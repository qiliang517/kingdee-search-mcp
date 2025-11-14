import pathlib

import setuptools

ROOT = pathlib.Path(__file__).parent
README = ROOT / "README.md"

with README.open("r", encoding="utf-8") as fh:
    long_description = fh.read()

setuptools.setup(
    name="kd-search-mcp",
    version="0.1.0",
    author="Your Name",
    author_email="your.email@example.com",
    description="一个基于 FastMCP 的金蝶开发者搜索工具示例。",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/yourusername/kd-search-mcp",
    packages=setuptools.find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires=">=3.8",
    install_requires=[
        "mcp[cli]>=1.21.0",
        "httpx>=0.27.0",
    ],
)

