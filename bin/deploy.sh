#!/bin/bash
# 发布博客：提交并推送源码，由 GitHub Actions 自动构建并部署到 GitHub Pages
# 流程: git push origin main -> Actions 构建 Hexo -> 发布到 GitHub Pages
# 注意: 本地无需 hexo generate / hexo deploy，一切在 Actions 上完成
set -e

cd "$(git rev-parse --show-toplevel)"

# 步骤1: 提交未提交的更改
if git status --porcelain | grep -q .; then
    echo "📝 检测到未提交的更改，正在自动提交..."
    git add .
    git commit -m "更新博客内容 - $(date '+%Y-%m-%d %H:%M:%S')"
else
    echo "✅ 没有未提交的更改"
fi

# 步骤2: 推送，触发 GitHub Actions
echo "📤 推送到 origin/main..."
git push origin main

echo ""
echo "🎉 发布完成！"
echo "  📊 部署进度: https://github.com/hongmuyu/muyblog/actions"
echo "  🌐 网站地址: https://zouwenxiang.cn"
echo "  ⏱️  Actions 构建约需 1-2 分钟"
