# 版本支持功能总结

## 新增功能

✅ **支持指定PyTorch和vLLM版本编译**
- 可以编译任何标签版本、分支或主分支
- 自动处理Git仓库的版本切换
- 支持同时指定两个库的不同版本

## 新增脚本

### 1. `/scripts/build_optimized.sh` (已增强)
- **新增版本参数支持**
- **用法**:
  ```bash
  /scripts/build_optimized.sh pytorch [版本号]
  /scripts/build_optimized.sh vllm [版本号]
  /scripts/build_optimized.sh all [PyTorch版本] [vLLM版本]
  ```

### 2. `/scripts/list_versions.sh` (新增)
- **查看可用版本列表**
- **用法**:
  ```bash
  /scripts/list_versions.sh all        # 显示所有版本
  /scripts/list_versions.sh pytorch    # 仅显示PyTorch版本
  /scripts/list_versions.sh vllm       # 仅显示vLLM版本
  /scripts/list_versions.sh examples   # 显示使用示例
  ```

## 使用示例

### 基本编译
```bash
# 编译最新主分支
docker run --gpus all --rm -v $(pwd)/output:/output cu121-builder:latest \
  /scripts/build_optimized.sh pytorch

# 编译指定版本
docker run --gpus all --rm -v $(pwd)/output:/output cu121-builder:latest \
  /scripts/build_optimized.sh pytorch 2.1.0
```

### 高级用法
```bash
# 同时编译不同版本
docker run --gpus all --rm -v $(pwd)/output:/output cu121-builder:latest \
  /scripts/build_optimized.sh all 2.1.0 0.2.4

# 查看可用版本
docker run --gpus all --rm cu121-builder:latest \
  /scripts/list_versions.sh all
```

### Docker Compose方式
```bash
# 启动容器
docker-compose up -d

# 进入容器
docker-compose exec cu121-builder bash

# 在容器内编译
/scripts/list_versions.sh all
/scripts/build_optimized.sh pytorch 2.1.0
/scripts/build_optimized.sh vllm 0.2.4
```

## 版本格式支持

| 格式 | 示例 | 说明 |
|------|------|------|
| 主分支 | `main`, `master` | 最新开发版本 |
| 标签版本 | `2.1.0`, `v2.1.0` | 正式发布版本 |
| 分支名称 | `release/2.1` | 发布分支 |

## 智能版本处理

脚本会自动：
1. 检测版本格式（标签/分支）
2. 切换到指定版本
3. 更新子模块（PyTorch）
4. 处理版本未找到的情况

## GPU优化维持

版本支持功能不影响原有的GPU优化：
- 自动检测GPU型号
- 设置对应的CUDA架构
- 优化并行编译参数
- 保持编译加速特性

## 兼容性

- 向后兼容原有的无版本参数调用
- 支持所有目标GPU (3090Ti, A100, A800, H20)
- 保持Python 3.12和CUDA 12.1.1环境
