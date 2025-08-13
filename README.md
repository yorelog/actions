# cu121

本仓库用于发布针对 CUDA 12.1 构建的主流 AI/ML 库（如 PyTorch、vLLM 等）的预编译二进制文件（binaries）、wheel 包以及安装脚本，旨在方便开发者和研究者在最新的 GPU 上快速使用深度学习框架。

**本项目专为如下 GPU 设计和优化：**
- NVIDIA A100
- NVIDIA A800
- NVIDIA H20
- 以及其他支持 CUDA 12.1 的现代数据中心级显卡

## 已收录项目

- **PyTorch**（CUDA 12.1 构建）
- **vLLM**
- 计划支持更多 AI/ML 库

## Releases

请前往 [Releases](https://github.com/yorelog/cu121/releases) 页面获取最新的二进制文件与安装说明。

## 使用方法

以安装 PyTorch 为例：

```bash
pip install https://github.com/yorelog/cu121/releases/download/{version}/torch-{version}-cu121.whl
```

请将 `{version}` 替换为所需的版本号。

## 贡献

欢迎提交 issue 或 pull request，包括：
- 新库构建请求
- 构建脚本
- Bug 反馈或建议

## License

请根据实际需要指定本仓库的许可证（如 MIT、Apache 2.0 等）。

---

由 [yorelog](https://github.com/yorelog) 维护。
