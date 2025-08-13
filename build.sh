#!/bin/bash

# CUDA 12.1.1 编译环境构建脚本
# 专为 RTX 3090Ti, A100, A800, H20 优化

set -e

echo "=== CUDA 12.1.1 专用编译环境构建脚本 ==="
echo "支持GPU: RTX 3090Ti, A100, A800, H20"
echo ""

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "错误: Docker未安装，请先安装Docker"
    exit 1
fi

# 检查NVIDIA Docker runtime
if ! docker info 2>/dev/null | grep -q nvidia; then
    echo "警告: 未检测到NVIDIA Docker runtime"
    echo "请安装nvidia-container-toolkit以支持GPU"
    echo ""
    echo "安装命令:"
    echo "  Ubuntu/Debian:"
    echo "    curl -fsSL https://nvidia.github.io/nvidia-container-runtime/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg"
    echo "    echo \"deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://nvidia.github.io/nvidia-container-runtime/ubuntu22.04/amd64 /\" | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list"
    echo "    sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit"
    echo "    sudo systemctl restart docker"
    echo ""
fi

# 检测GPU
echo "检测可用GPU..."
if command -v nvidia-smi &> /dev/null; then
    GPU_INFO=$(nvidia-smi --query-gpu=name,memory.total --format=csv,noheader,nounits 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$GPU_INFO" ]; then
        echo "检测到GPU:"
        echo "$GPU_INFO" | while read line; do
            echo "  - $line"
        done
        echo ""
        
        # 检查是否为支持的GPU
        SUPPORTED_GPU=false
        if echo "$GPU_INFO" | grep -qi "3090\|A100\|A800\|H20"; then
            SUPPORTED_GPU=true
            echo "✅ 检测到支持的GPU型号"
        else
            echo "⚠️  未检测到专门支持的GPU型号，但仍可使用"
            echo "   本镜像专为 RTX 3090Ti, A100, A800, H20 优化"
        fi
        echo ""
    else
        echo "⚠️  无法获取GPU信息，请确保NVIDIA驱动已正确安装"
        echo ""
    fi
else
    echo "⚠️  nvidia-smi未找到，请安装NVIDIA驱动"
    echo ""
fi

# 创建必要目录
mkdir -p output workspace scripts

# 构建镜像
echo "正在构建CUDA 12.1.1编译环境镜像..."
docker build -t cu121-builder:latest .

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 镜像构建成功!"
    echo ""
    echo "使用方法:"
    echo ""
    echo "1. 快速测试GPU支持:"
    echo "   docker run --gpus all --rm cu121-builder:latest nvidia-smi"
    echo ""
    echo "2. 启动交互式编译环境:"
    echo "   docker run --gpus all -it --rm -v \$(pwd)/output:/output cu121-builder:latest"
    echo ""
    echo "3. 使用GPU优化编译 (推荐):"
    echo "   # 查看可用版本"
    echo "   docker run --gpus all --rm cu121-builder:latest /scripts/list_versions.sh all"
    echo ""
    echo "   # 编译PyTorch主分支"
    echo "   docker run --gpus all --rm -v \$(pwd)/output:/output cu121-builder:latest /scripts/build_optimized.sh pytorch"
    echo ""
    echo "   # 编译PyTorch指定版本"
    echo "   docker run --gpus all --rm -v \$(pwd)/output:/output cu121-builder:latest /scripts/build_optimized.sh pytorch 2.1.0"
    echo ""
    echo "   # 编译vLLM指定版本"
    echo "   docker run --gpus all --rm -v \$(pwd)/output:/output cu121-builder:latest /scripts/build_optimized.sh vllm 0.2.4"
    echo ""
    echo "   # 同时编译指定版本"
    echo "   docker run --gpus all --rm -v \$(pwd)/output:/output cu121-builder:latest /scripts/build_optimized.sh all 2.1.0 0.2.4"
    echo ""
    echo "4. 使用Docker Compose:"
    echo "   docker-compose up -d"
    echo "   docker-compose exec cu121-builder bash"
    echo "   # 在容器内运行: /scripts/build_optimized.sh all"
    echo ""
    echo "编译完成的wheel文件将保存在 ./output/ 目录中"
    echo ""
else
    echo "❌ 镜像构建失败"
    exit 1
fi
