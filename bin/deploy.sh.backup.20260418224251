#!/bin/bash
# 一键部署脚本

set -e  # 遇到错误立即退出

echo "🔄 清理旧文件..."
hexo clean

echo "📝 生成静态文件..."
hexo generate

echo "🔍 检查生成的文件..."
if [ ! -f "public/index.html" ]; then
    echo "错误：生成失败，找不到 index.html"
    exit 1
fi

echo "🚀 部署到GitHub..."
hexo deploy

echo ""
echo "✅ 发布完成！"
echo "🌐 访问地址: https://zouwenxiang.cn"
echo ""
echo "提示："
echo "- 页面更新可能需要1-2分钟"
echo "- 清除浏览器缓存查看最新版本"
echo "- 查看GitHub Actions状态: https://github.com/ashynesses/ashynesses.github.io/actions"