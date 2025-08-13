# GitHub Actions 工作流使用指南

本仓库包含三个主要的GitHub Actions工作流，用于自动构建PyTorch和vLLM的CUDA 12.1版本。

## 📋 工作流概览

### 1. `build-pytorch.yml` - PyTorch独立构建
- 专门构建PyTorch 2.8.0
- 支持多GPU架构优化
- 自动测试和发布

### 2. `build-vllm.yml` - vLLM独立构建  
- 专门构建vLLM 0.10.0
- 依赖PyTorch预安装
- 包含完整测试验证

### 3. `build-combined.yml` - 组合构建 (推荐)
- 同时构建PyTorch和vLLM
- 智能依赖管理
- 一键安装脚本生成

## 🚀 快速开始

### 手动触发构建

1. **进入Actions页面**
   ```
   https://github.com/yorelog/cu121/actions
   ```

2. **选择工作流**
   - `Build PyTorch 2.8.0 + vLLM 0.10.0 for CUDA 12.1` (推荐)
   - `Build PyTorch 2.8.0 for CUDA 12.1`
   - `Build vLLM 0.10.0 for CUDA 12.1`

3. **点击 "Run workflow"**

4. **配置参数** (可选)
   - PyTorch版本: `2.8.0` (默认)
   - vLLM版本: `0.10.0` (默认)
   - CUDA架构: `8.0;8.6;8.9` (默认)

### 自动触发条件

工作流会在以下情况自动运行：

- **推送标签时**:
  ```bash
  git tag pytorch-2.8.0
  git push origin pytorch-2.8.0
  
  git tag vllm-0.10.0
  git push origin vllm-0.10.0
  
  git tag release-v1.0.0
  git push origin release-v1.0.0
  ```

- **定时构建**:
  - PyTorch: 每周日 UTC 04:00
  - vLLM: 每周日 UTC 06:00

## ⚙️ 配置要求

### Runner要求

**重要**: 这些工作流需要支持GPU的self-hosted runner！

```yaml
runs-on: self-hosted
# 或者指定GPU标签
# runs-on: [self-hosted, gpu]
```

### 设置Self-hosted Runner

1. **安装GitHub Runner**
   ```bash
   # 下载并配置runner
   mkdir actions-runner && cd actions-runner
   curl -o actions-runner-linux-x64-2.311.0.tar.gz -L \
     https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz
   tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz
   
   # 配置runner (需要GitHub token)
   ./config.sh --url https://github.com/yorelog/cu121 --token YOUR_TOKEN
   ```

2. **安装NVIDIA Docker支持**
   ```bash
   # 安装nvidia-container-toolkit
   curl -fsSL https://nvidia.github.io/nvidia-container-runtime/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
   echo "deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://nvidia.github.io/nvidia-container-runtime/ubuntu22.04/amd64 /" | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
   sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
   sudo systemctl restart docker
   ```

3. **启动Runner**
   ```bash
   ./run.sh
   # 或者作为服务运行
   sudo ./svc.sh install
   sudo ./svc.sh start
   ```

### 权限设置

确保仓库有以下权限：

1. **Settings → Actions → General**
   - 启用 "Allow all actions and reusable workflows"

2. **Settings → Actions → General → Workflow permissions**
   - 选择 "Read and write permissions"
   - 启用 "Allow GitHub Actions to create and approve pull requests"

## 📦 构建产物

### Artifacts (构建过程产物)

每次构建会生成以下artifacts：

- `pytorch-2.8.0-cu121-A100` - A100优化版本
- `pytorch-2.8.0-cu121-RTX3090Ti` - RTX 3090Ti优化版本  
- `pytorch-2.8.0-cu121-H20` - H20优化版本
- `vllm-0.10.0-cu121-[GPU]` - 对应GPU的vLLM版本
- 构建信息文件

### Releases (正式发布)

成功构建后会自动创建Release，包含：

- ✅ 所有GPU架构的wheel文件
- ✅ 自动安装脚本 (`install.sh`)
- ✅ 详细的安装说明
- ✅ 使用示例代码
- ✅ 构建信息和系统要求

## 🔧 自定义构建

### 修改版本

编辑workflow文件中的默认值：

```yaml
inputs:
  pytorch_version:
    default: '2.8.0'  # 改为所需版本
  vllm_version:
    default: '0.10.0'  # 改为所需版本
```

### 添加新GPU架构

修改CUDA架构列表：

```yaml
env:
  CUDA_ARCH_LIST: "8.0;8.6;8.9;9.0"  # 添加新架构
```

### 自定义构建参数

在workflow中添加环境变量：

```yaml
- name: Build with custom settings
  run: |
    docker run --gpus all --rm \
      -e MAX_JOBS=16 \
      -e PYTORCH_BUILD_VERSION=custom \
      -e PYTORCH_BUILD_NUMBER=1 \
      cu121-builder:latest \
      /scripts/build_optimized.sh pytorch 2.8.0
```

## 📊 监控构建

### 查看构建状态

1. **Actions页面**: 查看实时构建日志
2. **Releases页面**: 下载构建产物
3. **Artifacts**: 临时构建文件(30天保留)

### 构建时间估算

| 组件 | A100 | RTX 3090Ti | H20 |
|------|------|------------|-----|
| PyTorch | 45-60分钟 | 60-90分钟 | 40-55分钟 |
| vLLM | 15-25分钟 | 20-30分钟 | 15-20分钟 |
| 总计 | ~75分钟 | ~110分钟 | ~65分钟 |

### 故障排除

常见问题及解决方案：

1. **GPU不可用**
   ```
   docker: Error response from daemon: could not select device driver "" with capabilities: [[gpu]]
   ```
   解决：安装nvidia-container-toolkit并重启Docker

2. **内存不足**
   ```
   c++: fatal error: Killed signal terminated program cc1plus
   ```
   解决：增加系统内存或限制并行作业数

3. **权限错误**
   ```
   Permission denied while trying to connect to Docker daemon
   ```
   解决：将runner用户添加到docker组

4. **网络超时**
   ```
   fatal: unable to access 'https://github.com/pytorch/pytorch.git/'
   ```
   解决：检查网络连接和GitHub访问

## 🔐 安全注意事项

1. **Secrets管理**: 确保GITHUB_TOKEN有适当权限
2. **Runner安全**: Self-hosted runner应在安全环境中运行
3. **依赖验证**: 定期更新Docker基础镜像
4. **访问控制**: 限制可以触发workflow的用户

## 📞 支持

如果遇到问题：

1. 检查[Issues](https://github.com/yorelog/cu121/issues)中的已知问题
2. 查看workflow运行日志
3. 提交新的issue并包含详细错误信息
4. 联系维护者: [@yorelog](https://github.com/yorelog)
