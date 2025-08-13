# 镜像同步到阿里云

这个 workflow 提供了将常用的 Docker 镜像同步到阿里云镜像仓库的功能，解决国内拉取镜像速度慢的问题。

## 🚀 功能特性

### 1. 手动同步任意镜像
- 支持手动触发，同步任意 Docker Hub 镜像到阿里云
- 可自定义目标标签和命名空间
- 自动验证同步结果

### 2. 自动同步常用镜像
- 每周日凌晨自动同步常用基础镜像
- 包含 CUDA、Python、Ubuntu 等常用镜像
- 并行同步，提高效率

### 3. 镜像验证
- 自动验证镜像大小和完整性
- 提供同步后的镜像列表
- 支持镜像清单检查

## 📋 使用方法

### 手动同步镜像

1. 进入 GitHub Actions 页面
2. 选择 "Sync Images to Aliyun Registry" workflow
3. 点击 "Run workflow"
4. 填写参数：
   - **源镜像**: 例如 `nvidia/cuda:12.1.1-devel-ubuntu22.04`
   - **目标标签**: 例如 `12.1.1-devel-ubuntu22.04` (可留空)
   - **目标命名空间**: 默认 `yoce/cuda`

### 使用同步的镜像

```bash
# 原始拉取方式（可能很慢）
docker pull nvidia/cuda:12.1.1-devel-ubuntu22.04

# 使用阿里云镜像（国内速度快）
docker pull registry.cn-beijing.aliyuncs.com/yoce/cuda:12.1.1-devel-ubuntu22.04
```

## 🎯 预设的自动同步镜像

每周日会自动同步以下镜像：

| 源镜像 | 阿里云镜像 |
|--------|------------|
| `nvidia/cuda:12.1.1-devel-ubuntu22.04` | `registry.cn-beijing.aliyuncs.com/yoce/cuda:12.1.1-devel-ubuntu22.04` |
| `nvidia/cuda:12.1.1-runtime-ubuntu22.04` | `registry.cn-beijing.aliyuncs.com/yoce/cuda:12.1.1-runtime-ubuntu22.04` |
| `nvidia/cuda:12.1.1-base-ubuntu22.04` | `registry.cn-beijing.aliyuncs.com/yoce/cuda:12.1.1-base-ubuntu22.04` |
| `python:3.12-slim` | `registry.cn-beijing.aliyuncs.com/yoce/cuda:python-3.12-slim` |
| `python:3.11-slim` | `registry.cn-beijing.aliyuncs.com/yoce/cuda:python-3.11-slim` |
| `ubuntu:22.04` | `registry.cn-beijing.aliyuncs.com/yoce/cuda:ubuntu-22.04` |
| `ubuntu:20.04` | `registry.cn-beijing.aliyuncs.com/yoce/cuda:ubuntu-20.04` |

## 🔧 高级使用

### 同步自定义镜像

```bash
# 例如同步 PyTorch 官方镜像
# 源镜像: pytorch/pytorch:2.0.1-cuda11.7-cudnn8-devel
# 目标: registry.cn-beijing.aliyuncs.com/yoce/cuda:pytorch-2.0.1-cuda11.7-cudnn8-devel
```

在 workflow 中填写：
- 源镜像: `pytorch/pytorch:2.0.1-cuda11.7-cudnn8-devel`
- 目标标签: `pytorch-2.0.1-cuda11.7-cudnn8-devel`

### 批量同步

如果需要同步多个相关镜像，可以修改 `sync-images.yml` 中的 matrix 配置，添加更多镜像组合。

## ⚡ 优势

1. **速度提升**: 国内拉取阿里云镜像比 Docker Hub 快 5-10 倍
2. **稳定可靠**: 避免 Docker Hub 访问限制和网络问题
3. **自动化**: 定期同步，保持镜像更新
4. **验证机制**: 确保镜像同步的完整性
5. **灵活配置**: 支持自定义命名空间和标签

## 🛠️ 配置要求

确保在 GitHub Secrets 中配置了阿里云容器镜像服务的凭证：
- `ALIYUN_USERNAME`: 阿里云账号
- `ALIYUN_PASSWORD`: 阿里云容器镜像服务密码

## 📝 注意事项

1. 同步的镜像会占用阿里云镜像仓库空间
2. 建议定期清理不再使用的旧版本镜像
3. 大型镜像同步需要较长时间，请耐心等待
4. 确保有足够的网络带宽进行镜像传输
