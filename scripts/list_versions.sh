#!/bin/bash

# 获取PyTorch和vLLM可用版本列表

set -e

echo "=== 获取PyTorch和vLLM可用版本 ==="
echo ""

# 获取PyTorch版本
get_pytorch_versions() {
    echo "PyTorch 可用版本 (最近10个):"
    echo "-----------------------------"
    
    # 如果本地有PyTorch仓库，从本地获取
    if [ -d "/opt/pytorch" ]; then
        cd /opt/pytorch
        git fetch --tags >/dev/null 2>&1 || true
        echo "最新标签版本:"
        git tag | grep -E '^v?[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -10
        echo ""
        echo "主要分支:"
        git branch -r | grep -E '(main|master|release)' | sed 's/origin\///' | head -5
    else
        echo "本地PyTorch源码不存在，请先运行构建脚本或手动克隆"
        echo "可访问 https://github.com/pytorch/pytorch/tags 查看所有版本"
    fi
    echo ""
}

# 获取vLLM版本
get_vllm_versions() {
    echo "vLLM 可用版本 (最近10个):"
    echo "-------------------------"
    
    # 如果本地有vLLM仓库，从本地获取
    if [ -d "/opt/vllm" ]; then
        cd /opt/vllm
        git fetch --tags >/dev/null 2>&1 || true
        echo "最新标签版本:"
        git tag | grep -E '^v?[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -10
        echo ""
        echo "主要分支:"
        git branch -r | grep -E '(main|master|release)' | sed 's/origin\///' | head -5
    else
        echo "本地vLLM源码不存在，请先运行构建脚本或手动克隆"
        echo "可访问 https://github.com/vllm-project/vllm/tags 查看所有版本"
    fi
    echo ""
}

# 显示使用示例
show_examples() {
    echo "使用示例:"
    echo "---------"
    echo "# 编译最新稳定版本"
    echo "/scripts/build_optimized.sh pytorch 2.1.0"
    echo "/scripts/build_optimized.sh vllm 0.2.4"
    echo ""
    echo "# 编译主分支"
    echo "/scripts/build_optimized.sh pytorch main"
    echo "/scripts/build_optimized.sh vllm main"
    echo ""
    echo "# 同时编译指定版本"
    echo "/scripts/build_optimized.sh all 2.1.0 0.2.4"
    echo ""
    echo "# 预先克隆源码仓库"
    echo "git clone --recursive https://github.com/pytorch/pytorch.git /opt/pytorch"
    echo "git clone https://github.com/vllm-project/vllm.git /opt/vllm"
    echo ""
}

# 主逻辑
case "$1" in
    "pytorch")
        get_pytorch_versions
        ;;
    "vllm")
        get_vllm_versions
        ;;
    "all"|"")
        get_pytorch_versions
        get_vllm_versions
        show_examples
        ;;
    "examples")
        show_examples
        ;;
    *)
        echo "用法: $0 {pytorch|vllm|all|examples}"
        echo ""
        echo "  pytorch   - 显示PyTorch可用版本"
        echo "  vllm      - 显示vLLM可用版本"
        echo "  all       - 显示所有版本和使用示例"
        echo "  examples  - 仅显示使用示例"
        exit 1
        ;;
esac
