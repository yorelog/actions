# 使用 uv 包管理器

本项目使用 [uv](https://github.com/astral-sh/uv) 作为 Python 包管理器，它比传统的 pip 更快、更可靠。

## 什么是 uv？

uv 是用 Rust 编写的极快的 Python 包解析器和安装器，作为 pip 和 pip-tools 的替代品。

### 主要优势

- **速度**: 比 pip 快 10-100 倍
- **可靠性**: 更好的依赖解析
- **兼容性**: 与 pip 完全兼容
- **安全性**: 内置包验证

## 在容器中的使用

### 基本命令

```bash
# 安装包
uv pip install package_name

# 安装到系统环境（容器中推荐）
uv pip install --system package_name

# 从requirements.txt安装
uv pip install --system -r requirements.txt

# 升级包
uv pip install --system --upgrade package_name

# 列出已安装的包
uv pip list

# 卸载包
uv pip uninstall package_name
```

### 编译环境特定用法

在我们的 CUDA 编译环境中，uv 被用于：

1. **基础包安装**: 在 Dockerfile 中安装科学计算包
2. **依赖管理**: 在构建脚本中安装项目依赖
3. **版本控制**: 确保包版本的一致性

### 环境变量

```bash
# 确保 uv 在 PATH 中
export PATH="$HOME/.cargo/bin:$PATH"
```

## 与 pip 的对比

| 功能 | pip | uv |
|------|-----|-----|
| 安装速度 | 标准 | 10-100x 更快 |
| 依赖解析 | 基础 | 高级，更准确 |
| 并行下载 | 有限 | 完全并行 |
| 缓存 | 基础 | 智能缓存 |
| 错误处理 | 标准 | 更详细的错误信息 |

## 迁移指南

如果你有现有的 pip 命令，可以简单地替换：

```bash
# 原来的 pip 命令
pip install torch torchvision

# 使用 uv 的等效命令
uv pip install --system torch torchvision
```

## 故障排除

### 常见问题

1. **uv 命令未找到**
   ```bash
   export PATH="$HOME/.cargo/bin:$PATH"
   ```

2. **权限问题**
   - 在容器中使用 `--system` 标志
   - 在本地使用虚拟环境

3. **缓存问题**
   ```bash
   uv cache clean
   ```

### 获取帮助

```bash
# 查看帮助
uv --help
uv pip --help

# 查看版本
uv --version
```

## 性能基准

在我们的测试中，uv 在安装 PyTorch 和 vLLM 依赖时表现出显著的性能提升：

- NumPy + SciPy + PyTorch 依赖: 从 ~5分钟 降至 ~30秒
- vLLM 完整依赖: 从 ~10分钟 降至 ~2分钟

## 更多信息

- [uv 官方文档](https://github.com/astral-sh/uv)
- [uv vs pip 性能对比](https://github.com/astral-sh/uv#benchmarks)
- [uv 安装指南](https://github.com/astral-sh/uv#installation)
