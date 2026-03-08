#!/bin/bash
# OpenClaw Skills 安装器（中文）
# 包装 install.mjs — 负责检查 Node.js 环境和依赖安装。

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 检查 Node.js
if ! command -v node > /dev/null 2>&1; then
    echo "错误: 未找到 Node.js，请先安装。"
    echo "下载地址: https://nodejs.org（推荐 v18 及以上版本）"
    exit 1
fi

# 依赖未安装时自动安装
if [ ! -d "$SCRIPT_DIR/node_modules" ]; then
    echo "正在安装依赖..."
    (cd "$SCRIPT_DIR" && npm install --silent)
fi

# 启动统一安装器（中文模式）
INSTALLER_LANG=zh exec node "$SCRIPT_DIR/install.mjs" "$@"
