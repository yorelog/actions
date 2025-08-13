#!/bin/bash

# 快速验证CUDA 12.1.1 + Python 3.12环境

set -e

# 确保uv在PATH中
export PATH="$HOME/.cargo/bin:$PATH"

echo "=== CUDA 12.1.1 + Python 3.12 环境验证 ==="
echo ""

# 检查uv
echo "检查uv包管理器..."
if command -v uv &> /dev/null; then
    uv --version
    echo "✅ uv已安装"
else
    echo "❌ uv未安装"
fi
echo ""

# 检查Python版本
echo "检查Python版本..."
python3 --version
echo ""

# 检查CUDA版本
echo "检查CUDA版本..."
nvcc --version | grep "release"
echo ""

# 检查GPU
echo "检查GPU信息..."
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader,nounits
else
    echo "nvidia-smi 不可用"
fi
echo ""

# 检查Python包
echo "检查关键Python包..."
python3 -c "
import sys
print(f'Python版本: {sys.version}')

packages = ['numpy', 'torch', 'cuda']
for pkg in packages:
    try:
        __import__(pkg)
        print(f'✅ {pkg} 已安装')
    except ImportError:
        print(f'❌ {pkg} 未安装')

# 检查CUDA支持
try:
    import torch
    if torch.cuda.is_available():
        print(f'✅ PyTorch CUDA支持: {torch.version.cuda}')
        print(f'✅ 检测到 {torch.cuda.device_count()} 个GPU')
        for i in range(torch.cuda.device_count()):
            props = torch.cuda.get_device_properties(i)
            print(f'   GPU {i}: {props.name} ({props.major}.{props.minor})')
    else:
        print('❌ PyTorch CUDA不可用')
except ImportError:
    print('❌ PyTorch未安装')
"

echo ""
echo "环境验证完成!"
