#!/bin/bash

# GPU特定的编译优化脚本
# 支持: RTX 3090Ti, A100, A800, H20

set -e

# 检测GPU型号并设置优化参数
detect_gpu_and_optimize() {
    echo "检测GPU型号..."
    
    # 获取GPU信息
    GPU_INFO=$(nvidia-smi --query-gpu=name --format=csv,noheader,nounits | head -1)
    echo "检测到GPU: $GPU_INFO"
    
    # 根据GPU型号设置编译参数
    case "$GPU_INFO" in
        *"3090"*|*"3090 Ti"*)
            echo "为RTX 3090Ti优化编译参数..."
            export TORCH_CUDA_ARCH_LIST="8.6"
            export CUDA_ARCH_LIST="8.6"
            export MAX_JOBS=8
            ;;
        *"A100"*)
            echo "为A100优化编译参数..."
            export TORCH_CUDA_ARCH_LIST="8.0"
            export CUDA_ARCH_LIST="8.0"
            export MAX_JOBS=16
            ;;
        *"A800"*)
            echo "为A800优化编译参数..."
            export TORCH_CUDA_ARCH_LIST="8.0"
            export CUDA_ARCH_LIST="8.0"
            export MAX_JOBS=16
            ;;
        *"H20"*)
            echo "为H20优化编译参数..."
            export TORCH_CUDA_ARCH_LIST="8.9"
            export CUDA_ARCH_LIST="8.9"
            export MAX_JOBS=20
            ;;
        *)
            echo "未识别的GPU型号，使用默认参数..."
            export TORCH_CUDA_ARCH_LIST="8.0;8.6;8.9"
            export CUDA_ARCH_LIST="8.0;8.6;8.9"
            export MAX_JOBS=8
            ;;
    esac
    
    echo "CUDA架构: $CUDA_ARCH_LIST"
    echo "最大并行作业数: $MAX_JOBS"
}

# 优化的PyTorch编译
build_pytorch_optimized() {
    local pytorch_version=${1:-"main"}
    echo "=== 开始优化编译PyTorch (版本: $pytorch_version) ==="
    
    detect_gpu_and_optimize
    
    # 检查PyTorch源码目录
    if [ ! -d "/opt/pytorch" ]; then
        echo "克隆PyTorch源码..."
        git clone --recursive https://github.com/pytorch/pytorch.git /opt/pytorch
    fi
    
    cd /opt/pytorch
    
    # 切换到指定版本
    if [ "$pytorch_version" != "main" ]; then
        echo "切换到PyTorch版本: $pytorch_version"
        git fetch --all --tags
        if git tag | grep -q "^v$pytorch_version$"; then
            git checkout "v$pytorch_version"
        elif git tag | grep -q "^$pytorch_version$"; then
            git checkout "$pytorch_version"
        elif git branch -r | grep -q "origin/$pytorch_version"; then
            git checkout "$pytorch_version"
        else
            echo "警告: 版本 $pytorch_version 未找到，使用默认分支"
        fi
        # 更新子模块
        git submodule update --init --recursive
    else
        echo "使用主分支 (main)"
        git checkout main
        git pull
        git submodule update --init --recursive
    fi
    
    # 清理之前的构建
    python3 setup.py clean --all
    rm -rf build dist
    
    # 设置编译环境
    export USE_CUDA=1
    export USE_CUDNN=1
    export USE_MKLDNN=1
    export USE_OPENMP=1
    export USE_LAPACK=1
    export BUILD_TEST=0
    export USE_FBGEMM=1
    export USE_KINETO=1
    export USE_NNPACK=0
    export USE_QNNPACK=0
    export USE_DISTRIBUTED=1
    export USE_TENSORPIPE=1
    export USE_GLOO=1
    export USE_MPI=0
    export BUILD_BINARY=1
    
    # 优化编译标志
    export CXXFLAGS="-O3 -march=native"
    export CFLAGS="-O3 -march=native"
    
    echo "开始编译PyTorch $pytorch_version..."
    python3 setup.py bdist_wheel
    
    # 复制到输出目录
    if [ -d "/output" ]; then
        cp dist/*.whl /output/
        echo "PyTorch wheel文件已复制到 /output/"
    fi
    
    echo "✅ PyTorch $pytorch_version 编译完成!"
    echo "Wheel文件: $(find dist -name '*.whl')"
}

# 优化的vLLM编译
build_vllm_optimized() {
    local vllm_version=${1:-"main"}
    echo "=== 开始优化编译vLLM (版本: $vllm_version) ==="
    
    detect_gpu_and_optimize
    
    # 克隆或更新vLLM
    if [ ! -d "/opt/vllm" ]; then
        echo "克隆vLLM源码..."
        git clone https://github.com/vllm-project/vllm.git /opt/vllm
    fi
    
    cd /opt/vllm
    
    # 切换到指定版本
    if [ "$vllm_version" != "main" ]; then
        echo "切换到vLLM版本: $vllm_version"
        git fetch --all --tags
        if git tag | grep -q "^v$vllm_version$"; then
            git checkout "v$vllm_version"
        elif git tag | grep -q "^$vllm_version$"; then
            git checkout "$vllm_version"
        elif git branch -r | grep -q "origin/$vllm_version"; then
            git checkout "$vllm_version"
        else
            echo "警告: 版本 $vllm_version 未找到，使用默认分支"
        fi
    else
        echo "使用主分支 (main)"
        git checkout main
        git pull
    fi
    
    # 清理之前的构建
    rm -rf build dist *.egg-info
    
    # 安装依赖
    echo "安装vLLM依赖..."
    python3 -m pip install -r requirements.txt
    
    # 设置vLLM编译环境
    export VLLM_INSTALL_PUNICA_KERNELS=1
    export VLLM_ENABLE_CUDA_GRAPHS=1
    
    echo "开始编译vLLM $vllm_version..."
    python3 setup.py bdist_wheel
    
    # 复制到输出目录
    if [ -d "/output" ]; then
        cp dist/*.whl /output/
        echo "vLLM wheel文件已复制到 /output/"
    fi
    
    echo "✅ vLLM $vllm_version 编译完成!"
    echo "Wheel文件: $(find dist -name '*.whl')"
}

# 主函数
main() {
    case "$1" in
        "pytorch")
            build_pytorch_optimized "$2"
            ;;
        "vllm")
            build_vllm_optimized "$2"
            ;;
        "all")
            pytorch_version="$2"
            vllm_version="$3"
            build_pytorch_optimized "$pytorch_version"
            echo ""
            build_vllm_optimized "$vllm_version"
            ;;
        *)
            echo "用法: $0 {pytorch|vllm|all} [版本号] [vLLM版本号(仅限all)]"
            echo ""
            echo "示例:"
            echo "  $0 pytorch                    # 编译PyTorch主分支"
            echo "  $0 pytorch 2.1.0             # 编译PyTorch 2.1.0版本"
            echo "  $0 vllm                       # 编译vLLM主分支"
            echo "  $0 vllm 0.2.4                 # 编译vLLM 0.2.4版本"
            echo "  $0 all                        # 编译全部(主分支)"
            echo "  $0 all 2.1.0 0.2.4           # 编译PyTorch 2.1.0和vLLM 0.2.4"
            echo ""
            echo "支持的版本格式:"
            echo "  - main/master (默认主分支)"
            echo "  - 标签版本: 2.1.0, v2.1.0"
            echo "  - 分支名称: release/2.1"
            echo ""
            echo "获取可用版本:"
            echo "  PyTorch: https://github.com/pytorch/pytorch/tags"
            echo "  vLLM: https://github.com/vllm-project/vllm/tags"
            exit 1
            ;;
    esac
}

# 如果直接运行脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
