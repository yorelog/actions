# 多阶段构建 - 基础构建镜像
FROM nvidia/cuda:12.1.1-devel-ubuntu22.04 AS base-builder

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}

# 设置CUDA架构列表 (支持 RTX 3090Ti, A100, A800, H20)
ENV TORCH_CUDA_ARCH_LIST="8.0;8.6;8.9"
ENV FORCE_CUDA=1

# 安装基础工具包和编译环境
RUN apt-get update && apt-get install -y \
    software-properties-common \
    build-essential \
    git \
    wget \
    curl \
    cmake \
    ninja-build \
    ccache \
    pkg-config \
    libnuma-dev \
    && rm -rf /var/lib/apt/lists/*

# 安装 uv - 快速的 Python 包管理器
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# 设置 uv 路径
ENV PATH="$HOME/.cargo/bin:$PATH"

# 使用 uv 安装和管理 Python 3.12
RUN uv python install 3.12 && \
    uv python pin 3.12

# 设置 Python 环境变量
ENV UV_PYTHON_PREFERENCE=only-managed
ENV UV_PROJECT_ENVIRONMENT=/opt/venv

# 创建并使用虚拟环境安装Python包
RUN uv venv /opt/venv && \
    uv pip install \
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
    wheel \
    mkl \
    mkl-include

# 激活虚拟环境
ENV PATH="/opt/venv/bin:$PATH"
ENV VIRTUAL_ENV="/opt/venv"

# 设置编译优化环境变量
ENV CMAKE_PREFIX_PATH="${CUDA_HOME}"
ENV CUDA_NVCC_EXECUTABLE="${CUDA_HOME}/bin/nvcc"
ENV CUDA_BIN_PATH="${CUDA_HOME}/bin"
ENV CUDA_INCLUDE_DIRS="${CUDA_HOME}/include"
ENV USE_CUDA=1
ENV USE_CUDNN=1
ENV USE_MKLDNN=1
ENV USE_OPENMP=1
ENV USE_LAPACK=1
ENV BUILD_SHARED_LIBS=ON

# 设置ccache
ENV CCACHE_DIR=/tmp/ccache
ENV USE_CCACHE=1
RUN ccache --max-size=5G

# 清理
RUN apt-get autoremove -y && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 生产构建阶段
FROM base-builder AS production

# 设置工作目录
WORKDIR /workspace

# 创建输出目录
RUN mkdir -p /output

# 复制构建脚本
COPY scripts/build_optimized.sh /scripts/build_optimized.sh
COPY scripts/verify_env.sh /scripts/verify_env.sh
RUN chmod +x /scripts/*.sh

# 设置默认命令
CMD ["/bin/bash"]
