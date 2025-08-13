# CUDA 12.1.1 生产构建环境

专为 PyTorch 和 vLLM 编译优化的 CUDA 12.1.1 生产环境。

## 支持的 GPU

- RTX 3090Ti (Compute Capability 8.6)
- A100 (Compute Capability 8.0) 
- A800 (Compute Capability 8.0)
- H20 (Compute Capability 8.9)

## 核心特性

- 🚀 **CUDA 12.1.1**: 最新CUDA版本支持
- 🐍 **Python 3.12**: 使用uv管理的最新Python环境
- ⚡ **多阶段构建**: 优化的Docker构建流程
- 🎯 **GPU优化**: 针对特定GPU架构优化编译
- 📦 **自动化构建**: GitHub Actions自动构建和推送

## 使用方法

### 拉取基础镜像

```bash
docker pull registry.cn-beijing.aliyuncs.com/yoce/cuda:cu121-build-prod
```

### 编译 PyTorch

```bash
docker run --gpus all --rm \
  -v $(pwd)/output:/output \
  registry.cn-beijing.aliyuncs.com/yoce/cuda:cu121-build-prod \
  /scripts/build_optimized.sh pytorch 2.8.0
```

### 编译 vLLM

```bash
docker run --gpus all --rm \
  -v $(pwd)/output:/output \
  registry.cn-beijing.aliyuncs.com/yoce/cuda:cu121-build-prod \
  /scripts/build_optimized.sh vllm 0.10.0
```

## GitHub Actions

通过 GitHub Actions 自动构建：

1. **构建基础镜像**: 推送代码时自动构建并推送到阿里云镜像仓库
2. **构建 PyTorch**: 手动触发指定版本的 PyTorch 编译
3. **构建 vLLM**: 手动触发指定版本的 vLLM 编译

## 环境要求

- Docker with GPU support
- NVIDIA Driver >= 470
- 自托管 GitHub Runner (用于GPU构建)

## 阿里云镜像仓库

- 基础构建镜像: `registry.cn-beijing.aliyuncs.com/yoce/cuda:cu121-build`
- 生产镜像: `registry.cn-beijing.aliyuncs.com/yoce/cuda:cu121-build-prod`

## License

MIT License