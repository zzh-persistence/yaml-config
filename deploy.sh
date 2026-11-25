#!/usr/bin/env bash
# 独立仓库 + Pages 方案：一键推送并开启 Pages
# 前提：gh CLI 已登录（gh auth login），或 git 已配置 GitHub 凭据
set -euo pipefail

OWNER="zzh-persistence"
REPO="yaml-config"
DIR="$(cd "$(dirname "$0")" && pwd)"

cd "$DIR"

echo "[1/5] 检查 GitHub 登录状态"
if ! gh auth status >/dev/null 2>&1; then
  echo "未登录 GitHub。请先运行：gh auth login"
  exit 1
fi

echo "[2/5] 创建公开仓库（若已存在则跳过）"
gh repo create "$REPO" --public --description "Migrated subscription config mirror" --source=. --remote=origin --push 2>/dev/null \
  || git push -u origin HEAD:main

echo "[3/5] 开启 GitHub Pages（Deploy from a branch / main / root）"
gh api -X POST "repos/$OWNER/$REPO/pages" \
  -f source='{"branch":"main","path":"/"}' 2>/dev/null \
  || echo "Pages 可能已开启或需手动设置，请检查 Settings > Pages"

echo "[4/5] 等待 Pages 构建"
echo "请等待 1-2 分钟后验证。"

echo "[5/5] 完成。订阅地址："
echo "https://$OWNER.github.io/$REPO/0/0.json"
