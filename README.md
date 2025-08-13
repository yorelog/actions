````markdown
# cu121

本仓库用于发布针对 CUDA 12.1 构建的主流 AI/ML 库（如 PyTorch、vLLM 等）的预编译二进制文件（binaries）、wheel 包以及安装脚本，旨在方便开发者和研究者在最新的 GPU 上快速使用深度学习框架。

**本项目专为如下 GPU 设计和优化：**
- NVIDIA RTX 3090Ti (计算能力 8.6)
- NVIDIA A100 (计算能力 8.0)
- NVIDIA A800 (计算能力 8.0)
- NVIDIA H20 (计算能力 8.9)

## 核心特性

- 🚀 **CUDA 12.1.1 优化**: 专为最新CUDA版本优化
- 🐍 **Python 3.12**: 使用最新Python版本获得最佳性能
- ⚡ **uv 包管理器**: 比传统pip快10-100倍的包安装
- 🎯 **GPU特定优化**: 支持RTX 3090Ti、A100、A800、H20
- 🔧 **版本控制**: 支持指定PyTorch和vLLM版本编译
- 🏗️ **GitHub Actions**: 自动化CI/CD构建流程
- 📦 **输出优化**: 自动复制编译产物到指定目录

## 已收录项目

- **PyTorch**（CUDA 12.1 + Python 3.12 构建）
- **vLLM**（针对目标GPU优化）
- 计划支持更多 AI/ML 库

## Releases

请前往 [Releases](https://github.com/yorelog/cu121/releases) 页面获取最新的二进制文件与安装说明。

## 使用方法

### 本地构建

以安装 PyTorch 为例：

```bash
# 克隆仓库
git clone https://github.com/yorelog/cu121.git
cd cu121

# 构建环境
./build.sh

# 编译指定版本
docker run --gpus all --rm -v $(pwd)/output:/output cu121-builder:latest \
  /scripts/build_optimized.sh pytorch 2.8.0
```

### GitHub Actions自动构建

我们提供完整的GitHub Actions工作流来自动构建PyTorch和vLLM：

1. **前往Actions页面**: [GitHub Actions](../../actions)
2. **选择工作流**: `Build PyTorch 2.8.0 + vLLM 0.10.0 for CUDA 12.1`
3. **点击Run workflow**并配置参数
4. **等待构建完成**，在Releases页面下载

详细说明请参考: [GitHub Actions使用指南](GITHUB_ACTIONS.md)

### 预编译下载

请前往 [Releases](https://github.com/yorelog/cu121/releases) 页面获取最新的二进制文件与安装说明。

快速安装：
```bash
# 下载最新release的install.sh脚本
chmod +x install.sh
./install.sh
```

## 文档

- [UV包管理器使用指南](UV_USAGE.md) - 了解如何使用uv来管理Python包
- [使用说明](USAGE.md) - 详细的使用指南
- [GitHub Actions工作流](GITHUB_ACTIONS.md) - CI/CD配置说明

## 贡献

欢迎提交 issue 或 pull request，包括：
- 新库构建请求
- 构建脚本
- Bug 反馈或建议

## License

请根据实际需要指定本仓库的许可证（如 MIT、Apache 2.0 等）。

---

由 [yorelog](https://github.com/yorelog) 维护。
