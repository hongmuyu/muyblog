#!/bin/bash
# 一键部署脚本 - 支持双仓库推送
# 1. 推送源代码到 git@github.com:hongmuyu/muyblog.git
# 2. 部署静态文件到 git@github.com:hongmuyu/ashynesses.github.io.git

set -e  # 遇到错误立即退出

echo "🚀 开始双仓库部署流程"
echo "====================="
echo ""

# 步骤1: 检查并提交源代码更改
echo "📝 步骤1: 检查源代码更改..."
if git status --porcelain | grep -q .; then
    echo "🔍 检测到未提交的更改，正在自动提交..."

    # 添加所有更改（排除 node_modules 和 public 目录）
    git add .

    # 创建提交信息
    COMMIT_MSG="更新博客内容 - $(date '+%Y-%m-%d %H:%M:%S')"
    if git commit -m "$COMMIT_MSG"; then
        echo "✅ 代码更改已提交: $COMMIT_MSG"
    else
        echo "⚠️  提交失败（可能是空提交或无更改）"
    fi
else
    echo "✅ 没有未提交的更改"
fi

# 步骤2: 推送到源代码仓库
echo ""
echo "📤 步骤2: 推送到源代码仓库 (git@github.com:hongmuyu/muyblog.git)..."
if git push origin main; then
    echo "✅ 源代码已推送到 muyblog.git"
else
    echo "❌ 源代码推送失败，请检查网络连接和GitHub权限"
    echo "   错误信息:"
    git push origin main 2>&1 | tail -5
    exit 1
fi

# 步骤3: 生成静态文件
echo ""
echo "🔄 步骤3: 清理和生成静态文件..."
hexo clean
hexo generate

echo "🔍 检查生成的文件..."
if [ ! -f "public/index.html" ]; then
    echo "❌ 错误：生成失败，找不到 index.html"
    exit 1
fi

# 步骤4: 部署到 GitHub Pages
echo ""
echo "🚀 步骤4: 部署到 GitHub Pages (git@github.com:hongmuyu/ashynesses.github.io.git)..."
hexo deploy

echo ""
echo "🎉 部署完成！"
echo "============"
echo ""
echo "📊 部署摘要:"
echo "  ✅ 源代码已推送到: git@github.com:hongmuyu/muyblog.git"
echo "  ✅ 静态文件已部署到: git@github.com:hongmuyu/ashynesses.github.io.git"
echo ""
echo "🌐 访问地址: https://zouwenxiang.cn"
echo ""
echo "📚 相关链接:"
echo "  - 源代码仓库: https://github.com/hongmuyu/muyblog"
echo "  - GitHub Pages: https://github.com/hongmuyu/ashynesses.github.io"
echo "  - 博客网站: https://zouwenxiang.cn"
echo ""
echo "💡 提示:"
echo "  - 页面更新可能需要1-2分钟生效"
echo "  - 清除浏览器缓存查看最新版本"
echo "  - 如需跳过源代码推送，使用: hexo deploy""