#!/bin/bash

# 快速测试基础镜像功能

IMAGE_NAME="registry.cn-beijing.aliyuncs.com/yoce/cuda:cu121-build-prod"

echo "=== 测试基础镜像: $IMAGE_NAME ==="
echo ""

# 拉取最新的基础镜像
echo "拉取基础镜像..."
docker pull $IMAGE_NAME

echo ""
echo "运行基础镜像环境测试..."

# 运行容器测试基础镜像功能
docker run --rm -it \
  --name test-base-image \
  $IMAGE_NAME \
  /scripts/test_base_image.sh

echo ""
echo "✅ 基础镜像测试完成!"
