#!/bin/bash

# 测试基础镜像编译环境的脚本

set -e

echo "=== 测试基础镜像编译环境 ==="

# 测试 CUDA 环境
echo "1. 测试 CUDA 环境..."
echo "CUDA_HOME: $CUDA_HOME"
echo "NVCC版本:"
nvcc --version 2>/dev/null || echo "⚠️  NVCC 不可用"
echo "CUDA库路径:"
ls -la $CUDA_HOME/lib64/ 2>/dev/null | head -5 || echo "⚠️  CUDA库路径不存在"

# 测试 Python 环境
echo ""
echo "2. 测试 Python 环境..."
python --version
which python
echo "Python路径: $(which python)"
echo "虚拟环境: $VIRTUAL_ENV"

# 测试 uv 包管理器
echo ""
echo "3. 测试 uv 包管理器..."
uv --version
which uv

# 测试已安装的核心包
echo ""
echo "4. 测试已安装的核心包..."
python -c "import numpy; print(f'NumPy: {numpy.__version__}')"
python -c "import yaml; print('PyYAML: 可用')"
python -c "import setuptools; print(f'Setuptools: {setuptools.__version__}')"
python -c "import wheel; print('Wheel: 可用')"
python -c "import cmake; print('CMake: 可用')" 2>/dev/null || echo "CMake Python包: 不可用"

# 测试编译工具链
echo ""
echo "5. 测试编译工具链..."
echo "GCC: $(gcc --version | head -1)"
echo "CMake: $(cmake --version | head -1)"
echo "Ninja: $(ninja --version)"
echo "ccache: $(ccache --version | head -1)"

# 测试编译环境变量
echo ""
echo "6. 测试编译环境变量..."
echo "TORCH_CUDA_ARCH_LIST: $TORCH_CUDA_ARCH_LIST"
echo "USE_CUDA: $USE_CUDA"
echo "USE_CUDNN: $USE_CUDNN"
echo "USE_MKLDNN: $USE_MKLDNN"
echo "CMAKE_PREFIX_PATH: $CMAKE_PREFIX_PATH"

# 测试输出目录
echo ""
echo "7. 测试输出目录..."
ls -la /output/ 2>/dev/null || echo "/output 目录不存在"

# 测试工具脚本
echo ""
echo "8. 测试工具脚本..."
ls -la /scripts/ 2>/dev/null || echo "/scripts 目录不存在"

echo ""
echo "✅ 基础镜像编译环境测试完成!"
echo "该环境已准备好用于编译 PyTorch 和 vLLM"
