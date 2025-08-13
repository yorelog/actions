# CUDA 12.1.1 基础镜像用于编译 PyTo# 安装Python 3.1# 安装Python 3.12和相关工具
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y \
    python3.12 \
    python3.12-dev \
    python3.12-venv \
    && rm -rf /var/lib/apt/lists/*

# 安装 uv - 快速的 Python 包管理器
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc && \
    export PATH="$HOME/.cargo/bin:$PATH"

# 设置Python 3.12为默认Python
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 2 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.12 2-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y \
    python3.12 \
    python3.12-dev \
    python3.12-venv \
    && rm -rf /var/lib/apt/lists/*

# 安装 uv - 快速的 Python 包管理器
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc && \
    export PATH="$HOME/.cargo/bin:$PATH"

# 设置Python 3.12为默认Python
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 2 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.12 2M nvidia/cuda:12.1.1-devel-ubuntu22.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}
# 针对 3090Ti(8.6), A100/A800(8.0), H20(8.9) 优化的CUDA架构
ENV CUDA_ARCH_LIST="8.0;8.6;8.9"
ENV TORCH_CUDA_ARCH_LIST="8.0;8.6;8.9"
ENV FORCE_CUDA=1

# 更新系统并安装基础依赖
RUN apt-get update && apt-get install -y \
    software-properties-common \
    wget \
    curl \
    git \
    build-essential \
    cmake \
    ninja-build \
    ccache \
    pkg-config \
    libnuma-dev \
    && rm -rf /var/lib/apt/lists/*

# 安装Python 3.12和相关工具
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y \
    python3.12 \
    python3.12-dev \
    python3.12-venv \
    && rm -rf /var/lib/apt/lists/*

# 安装 uv - 快速的 Python 包管理器
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc

# 设置Python 3.12为默认Python和PATH
ENV PATH="$HOME/.cargo/bin:$PATH"
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 2 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.12 2

# 安装编译所需的Python包
RUN $HOME/.cargo/bin/uv pip install --system \
    numpy \
    pyyaml \
    setuptools \
    cmake \
    cffi \
    typing_extensions \
    future \
    six \
    requests \
    packaging \
    wheel
    packaging \
    pillow

# 安装PyTorch编译依赖
RUN python3 -m pip install \
    astunparse \
    expecttest \
    hypothesis \
    psutil \
    sympy \
    filelock \
    networkx \
    jinja2 \
    fsspec

# 安装vLLM编译依赖
RUN python3 -m pip install \
    ray \
    transformers \
    tokenizers \
    fastapi \
    uvicorn \
    pydantic \
    xformers

# 安装构建工具
RUN python3 -m pip install \
    cython \
    pybind11 \
    scikit-build \
    auditwheel

# 创建工作目录
WORKDIR /workspace

# 设置ccache以加速编译
RUN mkdir -p /root/.ccache && \
    echo "max_size = 10G" > /root/.ccache/ccache.conf && \
    echo "compression = true" >> /root/.ccache/ccache.conf

# 设置编译环境变量
ENV CCACHE_DIR=/root/.ccache
ENV CC="ccache gcc"
ENV CXX="ccache g++"

# 克隆PyTorch源码（可选，在运行时可以重新克隆特定版本）
RUN git clone --recursive https://github.com/pytorch/pytorch.git /opt/pytorch

# 设置PyTorch编译选项
ENV USE_CUDA=1
ENV USE_CUDNN=1
ENV USE_MKLDNN=1
ENV USE_OPENMP=1
ENV USE_LAPACK=1
ENV BUILD_TEST=0
ENV USE_FBGEMM=1
ENV USE_KINETO=1
ENV USE_NNPACK=0
ENV USE_QNNPACK=0
ENV USE_DISTRIBUTED=1
ENV USE_TENSORPIPE=1
ENV USE_GLOO=1
ENV USE_MPI=0

# 创建编译脚本目录
RUN mkdir -p /scripts

# 复制优化构建脚本
COPY scripts/build_optimized.sh /scripts/
COPY scripts/verify_env.sh /scripts/
COPY scripts/list_versions.sh /scripts/

# 创建PyTorch编译脚本
RUN cat > /scripts/build_pytorch.sh << 'EOF'
#!/bin/bash
set -e

echo "开始编译 PyTorch..."

cd /opt/pytorch

# 清理之前的构建
python3 setup.py clean

# 安装PyTorch
python3 setup.py bdist_wheel

# 复制到输出目录
if [ -d "/output" ]; then
    cp dist/*.whl /output/
    echo "PyTorch wheel文件已复制到 /output/"
fi

echo "PyTorch 编译完成!"
echo "Wheel文件位置: $(find dist -name '*.whl')"
EOF

# 创建vLLM编译脚本
RUN cat > /scripts/build_vllm.sh << 'EOF'
#!/bin/bash
set -e

echo "开始编译 vLLM..."

# 克隆vLLM源码
if [ ! -d "/opt/vllm" ]; then
    git clone https://github.com/vllm-project/vllm.git /opt/vllm
fi

cd /opt/vllm

# 安装依赖
python3 -m pip install -r requirements.txt

# 编译安装
python3 setup.py bdist_wheel

# 复制到输出目录
if [ -d "/output" ]; then
    cp dist/*.whl /output/
    echo "vLLM wheel文件已复制到 /output/"
fi

echo "vLLM 编译完成!"
echo "Wheel文件位置: $(find dist -name '*.whl')"
EOF

# 设置脚本可执行权限
RUN chmod +x /scripts/*.sh

# 创建输出目录
RUN mkdir -p /output

# 设置默认工作目录
WORKDIR /workspace

# 添加入口脚本
RUN cat > /scripts/entrypoint.sh << 'EOF'
#!/bin/bash

echo "CUDA 12.1.1 编译环境已就绪"
echo "专为以下GPU优化: RTX 3090Ti, A100, A800, H20"
echo "CUDA版本: $(nvcc --version | grep release)"
echo "Python版本: $(python3 --version)"
echo ""
echo "检测到的GPU:"
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader,nounits 2>/dev/null || echo "未检测到GPU或驱动未安装"
echo ""
echo "可用的脚本:"
echo "  - /scripts/verify_env.sh         : 验证环境配置"
echo "  - /scripts/list_versions.sh      : 查看可用版本"
echo "  - /scripts/build_pytorch.sh      : 编译PyTorch"
echo "  - /scripts/build_vllm.sh         : 编译vLLM"
echo "  - /scripts/build_optimized.sh    : GPU优化编译脚本"
echo ""
echo "快速验证环境:"
echo "  /scripts/verify_env.sh"
echo ""
echo "查看可用版本:"
echo "  /scripts/list_versions.sh all"
echo ""
echo "优化编译用法 (支持版本指定):"
echo "  /scripts/build_optimized.sh pytorch           # 编译PyTorch主分支"
echo "  /scripts/build_optimized.sh pytorch 2.1.0     # 编译PyTorch 2.1.0"
echo "  /scripts/build_optimized.sh vllm 0.2.4        # 编译vLLM 0.2.4"
echo "  /scripts/build_optimized.sh all 2.1.0 0.2.4   # 编译指定版本"
echo ""
echo "标准编译用法:"
echo "  docker run --gpus all -v /path/to/output:/output your-image /scripts/build_pytorch.sh"
echo ""

exec "$@"
EOF

RUN chmod +x /scripts/entrypoint.sh

ENTRYPOINT ["/scripts/entrypoint.sh"]
CMD ["/bin/bash"]
