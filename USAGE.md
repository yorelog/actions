# CUDA 12.1.1 编译环境使用指南

本镜像专为以下GPU型号优化编译PyTorch和vLLM，使用Python 3.12作为开发环境：

## 支持的GPU型号

| GPU型号 | 计算能力 | 架构 | 优化说明 |
|---------|----------|------|----------|
| RTX 3090Ti | 8.6 | Ampere | 消费级高端显卡，24GB显存 |
| A100 | 8.0 | Ampere | 数据中心级显卡，40GB/80GB显存 |
| A800 | 8.0 | Ampere | A100的中国特供版本 |
| H20 | 8.9 | Hopper | 新一代数据中心显卡 |

## 环境特性

- **CUDA版本**: 12.1.1
- **Python版本**: 3.12
- **操作系统**: Ubuntu 22.04 LTS
- **优化架构**: 仅支持8.0、8.6、8.9计算能力

## 快速开始

### 1. 构建镜像

```bash
# 克隆仓库
git clone https://github.com/yorelog/cu121.git
cd cu121

# 构建镜像
./build.sh
```

### 2. 验证GPU支持

```bash
# 检查GPU是否可用
docker run --gpus all --rm cu121-builder:latest nvidia-smi

# 检查CUDA版本
docker run --gpus all --rm cu121-builder:latest nvcc --version
```

### 3. 编译PyTorch

```bash
# 创建输出目录
mkdir -p output

# 查看可用版本
docker run --gpus all --rm cu121-builder:latest /scripts/list_versions.sh pytorch

# 编译PyTorch主分支 (需要较长时间，建议使用后台运行)
docker run --gpus all --rm \
  -v $(pwd)/output:/output \
  -v $(pwd)/workspace:/workspace \
  cu121-builder:latest /scripts/build_optimized.sh pytorch

# 编译指定版本的PyTorch (例如 2.1.0)
docker run --gpus all --rm \
  -v $(pwd)/output:/output \
  -v $(pwd)/workspace:/workspace \
  cu121-builder:latest /scripts/build_optimized.sh pytorch 2.1.0

# 编译后的wheel文件将保存在output目录中
```

### 4. 编译vLLM

```bash
# 查看可用版本
docker run --gpus all --rm cu121-builder:latest /scripts/list_versions.sh vllm

# 编译vLLM主分支
docker run --gpus all --rm \
  -v $(pwd)/output:/output \
  -v $(pwd)/workspace:/workspace \
  cu121-builder:latest /scripts/build_optimized.sh vllm

# 编译指定版本的vLLM (例如 0.2.4)
docker run --gpus all --rm \
  -v $(pwd)/output:/output \
  -v $(pwd)/workspace:/workspace \
  cu121-builder:latest /scripts/build_optimized.sh vllm 0.2.4
```

### 5. 同时编译PyTorch和vLLM

```bash
# 编译主分支
docker run --gpus all --rm \
  -v $(pwd)/output:/output \
  -v $(pwd)/workspace:/workspace \
  cu121-builder:latest /scripts/build_optimized.sh all

# 编译指定版本 (PyTorch 2.1.0 + vLLM 0.2.4)
docker run --gpus all --rm \
  -v $(pwd)/output:/output \
  -v $(pwd)/workspace:/workspace \
  cu121-builder:latest /scripts/build_optimized.sh all 2.1.0 0.2.4
```

### 5. 交互式开发

```bash
# 启动交互式容器
docker run --gpus all -it --rm \
  -v $(pwd)/output:/output \
  -v $(pwd)/workspace:/workspace \
  cu121-builder:latest bash

# 在容器内可以手动执行编译命令
# 查看可用版本: /scripts/list_versions.sh all
# 编译PyTorch: /scripts/build_optimized.sh pytorch 2.1.0
# 编译vLLM: /scripts/build_optimized.sh vllm 0.2.4
```

## 版本管理

### 查看可用版本

```bash
# 查看所有可用版本
docker run --gpus all --rm cu121-builder:latest /scripts/list_versions.sh all

# 仅查看PyTorch版本
docker run --gpus all --rm cu121-builder:latest /scripts/list_versions.sh pytorch

# 仅查看vLLM版本
docker run --gpus all --rm cu121-builder:latest /scripts/list_versions.sh vllm

# 查看使用示例
docker run --gpus all --rm cu121-builder:latest /scripts/list_versions.sh examples
```

### 支持的版本格式

- **主分支**: `main`, `master`
- **标签版本**: `2.1.0`, `v2.1.0`, `0.2.4`
- **分支名称**: `release/2.1`, `release/0.2`

### 常用版本示例

**PyTorch 推荐版本:**
- `2.1.0` - 稳定版本，支持最新CUDA特性
- `2.0.1` - LTS版本
- `main` - 最新开发版本

**vLLM 推荐版本:**
- `0.2.4` - 稳定版本
- `0.2.2` - 兼容性较好的版本
- `main` - 最新开发版本

## 使用Docker Compose

```bash
# 启动服务
docker-compose up -d

# 进入容器
docker-compose exec cu121-builder bash

# 在容器内编译
/scripts/build_pytorch.sh
/scripts/build_vllm.sh

# 停止服务
docker-compose down
```

## 编译优化说明

### CUDA架构优化
- 仅编译8.0、8.6、8.9计算能力的代码
- 显著减少编译时间和二进制文件大小
- 针对目标GPU提供最佳性能

### 编译加速
- 使用ccache缓存编译结果
- 启用ninja构建系统
- 多核并行编译

### 内存优化
- 编译时禁用测试构建
- 优化链接器设置
- 清理中间文件

## 性能基准

在A100 80GB上的典型编译时间：
- PyTorch: 45-60分钟
- vLLM: 15-25分钟

## 故障排除

### 内存不足
如果编译时遇到内存不足，可以限制并行作业数：
```bash
export MAX_JOBS=4
```

### CUDA版本不匹配
确保主机的NVIDIA驱动版本 >= 525.60.13

### 权限问题
```bash
# 确保输出目录有写权限
chmod 777 output
```

## 自定义编译

### 修改PyTorch编译选项
编辑`/scripts/build_pytorch.sh`，添加所需的编译标志。

### 添加新的依赖包
在Dockerfile中添加新的`pip install`命令。

## 技术支持

- 问题反馈：[GitHub Issues](https://github.com/yorelog/cu121/issues)
- 讨论区：[GitHub Discussions](https://github.com/yorelog/cu121/discussions)
