#!/bin/bash

# 测试 uv Python 环境脚本

set -e

echo "=== 测试 uv Python 环境 ==="
echo ""

# 检查 uv 版本
echo "uv 版本:"
uv --version
echo ""

# 检查 Python 版本
echo "Python 版本:"
python --version
python3 --version
echo ""

# 检查虚拟环境
echo "虚拟环境:"
echo "VIRTUAL_ENV: $VIRTUAL_ENV"
echo "PATH: $PATH"
echo ""

# 检查 uv 管理的 Python
echo "uv Python 信息:"
uv python list
echo ""

# 检查已安装的包
echo "已安装的包:"
uv pip list
echo ""

# 测试 Python 包导入
echo "测试 Python 包导入:"
python -c "
import sys
print(f'Python 路径: {sys.executable}')
print(f'Python 版本: {sys.version}')

packages = ['numpy', 'packaging', 'setuptools']
for pkg in packages:
    try:
        __import__(pkg)
        print(f'✅ {pkg} 导入成功')
    except ImportError as e:
        print(f'❌ {pkg} 导入失败: {e}')
"

echo ""
echo "✅ uv Python 环境测试完成!"
