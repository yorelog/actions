# Docker Image Sync to Aliyun Registry

🐳 一个用于将Docker镜像同步到阿里云镜像仓库的GitHub Actions工作流。

## 📖 概述

这个GitHub Action可以帮助你将任意Docker镜像从Docker Hub或其他镜像仓库同步到阿里云容器镜像服务（ACR），解决国内访问Docker Hub速度慢的问题。

## ✨ 特性

- 🚀 **一键同步**：通过手动触发轻松同步任意Docker镜像
- 💾 **磁盘优化**：智能清理系统空间，避免磁盘空间不足
- 🏷️ **灵活标记**：支持自定义目标标签和命名空间
- 🔍 **自动验证**：同步完成后自动验证镜像可用性
- 📊 **监控友好**：实时显示磁盘空间和Docker使用情况

## 🛠️ 使用方法

### 前置条件

1. 在GitHub仓库的Settings > Secrets中配置以下密钥：
   - `ALIYUN_USERNAME`: 阿里云容器镜像服务用户名
   - `ALIYUN_PASSWORD`: 阿里云容器镜像服务密码

### 手动触发同步

1. 进入GitHub仓库的 **Actions** 页面
2. 选择 **Sync Images to Aliyun Registry** 工作流
3. 点击 **Run workflow** 按钮
4. 填写以下参数：

| 参数 | 描述 | 示例 | 必填 |
|------|------|------|------|
| **源镜像** | 要同步的源镜像完整名称 | `nvidia/cuda:12.1.1-devel-ubuntu22.04` | ✅ |
| **目标标签** | 在阿里云中的标签名（留空使用源镜像标签） | `12.1.1-devel-ubuntu22.04` | ❌ |
| **目标命名空间** | 阿里云镜像仓库的命名空间 | `yoce/cuda` | ❌ |

### 使用示例

#### 示例 1：同步CUDA镜像
```
源镜像: nvidia/cuda:12.1.1-devel-ubuntu22.04
目标标签: （留空，自动使用 12.1.1-devel-ubuntu22.04）
目标命名空间: yoce/cuda
```
结果：`registry.cn-beijing.aliyuncs.com/yoce/cuda:12.1.1-devel-ubuntu22.04`

#### 示例 2：同步Python镜像
```
源镜像: python:3.11-slim
目标标签: python-3.11-slim
目标命名空间: yoce/base
```
结果：`registry.cn-beijing.aliyuncs.com/yoce/base:python-3.11-slim`

#### 示例 3：同步自定义镜像
```
源镜像: tensorflow/tensorflow:2.13.0-gpu
目标标签: tf-2.13.0-gpu
目标命名空间: yoce/ml
```
结果：`registry.cn-beijing.aliyuncs.com/yoce/ml:tf-2.13.0-gpu`

## 🔧 工作流程

1. **系统清理** - 清理APT缓存和Docker空间，确保有足够磁盘空间
2. **环境设置** - 配置Docker Buildx环境
3. **登录认证** - 登录到阿里云容器镜像服务
4. **参数解析** - 处理输入参数，生成目标镜像名称
5. **磁盘检查** - 监控磁盘空间使用情况
6. **镜像同步** - 拉取源镜像、重新标记、推送到阿里云
7. **清理验证** - 清理本地镜像并验证同步结果

## 🎯 设计优化

### 磁盘空间优化
- 同步前清理系统垃圾和Docker缓存
- 推送完成后立即删除本地镜像
- 实时监控磁盘使用情况
- 使用manifest检查而非重新下载进行验证

### 简化设计
- 移除了批量同步功能，专注单个镜像同步
- 移除了定时任务，避免不必要的资源占用
- 简化了验证流程，提高执行效率

## 📋 常见使用场景

| 场景 | 源镜像示例 | 用途 |
|------|------------|------|
| **深度学习** | `nvidia/cuda:*`, `tensorflow/tensorflow:*`, `pytorch/pytorch:*` | GPU加速的AI/ML工作负载 |
| **Web开发** | `node:*`, `nginx:*`, `redis:*` | 前端构建和后端服务 |
| **数据库** | `postgres:*`, `mysql:*`, `mongodb:*` | 数据存储服务 |
| **基础镜像** | `ubuntu:*`, `alpine:*`, `python:*` | 构建自定义镜像的基础 |

## ⚠️ 注意事项

1. **镜像大小**：大型镜像（如CUDA镜像）可能需要较长同步时间
2. **网络限制**：确保GitHub Actions runner能够访问源镜像仓库
3. **存储配额**：注意阿里云镜像仓库的存储配额限制
4. **镜像更新**：源镜像更新后需要手动重新同步

## 🚀 快速开始

1. Fork这个仓库
2. 配置阿里云密钥（ALIYUN_USERNAME, ALIYUN_PASSWORD）
3. 运行工作流同步你需要的镜像
4. 在你的项目中使用同步后的镜像：
   ```bash
   docker pull registry.cn-beijing.aliyuncs.com/yoce/cuda:12.1.1-devel-ubuntu22.04
   ```

## 📝 更新日志

- **v1.0.0** - 初始版本，支持手动触发镜像同步
- **v1.1.0** - 优化磁盘空间管理，提高同步稳定性
- **v1.2.0** - 简化工作流设计，专注核心功能

---

💡 **提示**：如果你经常使用特定的镜像，建议将其同步到阿里云后在你的Dockerfile或docker-compose.yml中使用阿里云地址，可以显著提高拉取速度。