#!/bin/bash
# Giscus 评论系统配置脚本

set -e

echo "🔧 Giscus 评论系统配置工具"
echo "==========================="
echo ""

# 检查当前目录
if [ ! -f "_config.yml" ]; then
    echo "❌ 错误：请在博客根目录运行此脚本"
    echo "    当前目录: $(pwd)"
    exit 1
fi

# 检查必要的文件
CONFIG_FILE="source/_data/body-end.swig"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ 错误：找不到配置文件 $CONFIG_FILE"
    exit 1
fi

echo "📖 请先完成以下准备工作："
echo ""
echo "1. ✅ 确保 GitHub 仓库已启用 Discussions"
echo "   访问：https://github.com/hongmuyu/ashynesses.github.io/settings"
echo ""
echo "2. ✅ 安装 Giscus GitHub App"
echo "   访问：https://github.com/apps/giscus"
echo ""
echo "3. ✅ 访问 https://giscus.app 获取配置信息"
echo ""
echo "按 Enter 键继续..."
read

echo ""
echo "📝 请输入 Giscus 配置信息"
echo "--------------------------"

# 获取仓库信息
echo "🔗 GitHub 仓库（格式：用户名/仓库名）"
echo "  例如：hongmuyu/ashynesses.github.io"
read -p "  仓库: " REPO
if [ -z "$REPO" ]; then
    REPO="hongmuyu/ashynesses.github.io"
    echo "  使用默认仓库: $REPO"
fi

# 获取仓库ID
echo ""
echo "🔑 仓库ID（从 giscus.app 获取）"
read -p "  仓库ID: " REPO_ID
if [ -z "$REPO_ID" ]; then
    echo "⚠️  警告：仓库ID不能为空"
    echo "  请访问 https://giscus.app 获取"
    exit 1
fi

# 获取分类信息
echo ""
echo "📂 讨论分类（建议：Announcements）"
read -p "  分类名称: " CATEGORY
if [ -z "$CATEGORY" ]; then
    CATEGORY="Announcements"
    echo "  使用默认分类: $CATEGORY"
fi

# 获取分类ID
echo ""
echo "🔑 分类ID（从 giscus.app 获取）"
read -p "  分类ID: " CATEGORY_ID
if [ -z "$CATEGORY_ID" ]; then
    echo "⚠️  警告：分类ID不能为空"
    echo "  请访问 https://giscus.app 获取"
    exit 1
fi

# 其他配置选项
echo ""
echo "⚙️  高级配置（可选）"
echo "  按 Enter 键使用默认值"
read -p "  主题 [preferred_color_scheme]: " THEME
read -p "  语言 [zh-CN]: " LANG
read -p "  评论框位置 [bottom]: " POSITION

THEME=${THEME:-preferred_color_scheme}
LANG=${LANG:-zh-CN}
POSITION=${POSITION:-bottom}

# 显示配置摘要
echo ""
echo "📋 配置摘要"
echo "  ──────────"
echo "  仓库: $REPO"
echo "  仓库ID: $REPO_ID"
echo "  分类: $CATEGORY"
echo "  分类ID: $CATEGORY_ID"
echo "  主题: $THEME"
echo "  语言: $LANG"
echo "  位置: $POSITION"
echo ""

echo "⚠️  确认更新配置文件吗？"
echo "  输入 y 确认，其他任意键取消: "
read CONFIRM

if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "取消配置"
    exit 0
fi

# 备份原文件
BACKUP_FILE="${CONFIG_FILE}.backup.$(date +%Y%m%d%H%M%S)"
cp "$CONFIG_FILE" "$BACKUP_FILE"
echo "✅ 已备份原文件: $BACKUP_FILE"

# 创建新的配置文件内容
NEW_CONTENT='<script src="https://giscus.app/client.js"
        data-repo="'"$REPO"'"
        data-repo-id="'"$REPO_ID"'"
        data-category="'"$CATEGORY"'"
        data-category-id="'"$CATEGORY_ID"'"
        data-mapping="pathname"
        data-strict="0"
        data-reactions-enabled="1"
        data-emit-metadata="0"
        data-input-position="'"$POSITION"'"
        data-theme="'"$THEME"'"
        data-lang="'"$LANG"'"
        crossorigin="anonymous"
        async>
</script>

<style>
.giscus, .giscus-frame {
  width: 100%;
  border: none;
  margin-top: 2rem;
  border-radius: 8px;
}
</style>

{# 快捷键支持：Ctrl+K 或 / 键触发搜索 #}
<script>
document.addEventListener(\"keydown\", function(e) {
  // Ctrl + K 或 / 键触发搜索
  if ((e.ctrlKey && e.key === \"k\") || e.key === \"/\") {
    e.preventDefault();
    const searchBtn = document.querySelector(\".search-popup-btn\");
    if (searchBtn) searchBtn.click();
  }
});
</script>

{# 平滑滚动支持 #}
<style>
html {
  scroll-behavior: smooth;
}

@media (prefers-reduced-motion: reduce) {
  html {
    scroll-behavior: auto;
  }
}
</style>'

# 更新配置文件
echo "$NEW_CONTENT" > "$CONFIG_FILE"

if [ $? -eq 0 ]; then
    echo "✅ 配置文件已更新: $CONFIG_FILE"
else
    echo "❌ 配置文件更新失败"
    # 恢复备份
    mv "$BACKUP_FILE" "$CONFIG_FILE"
    echo "已恢复备份文件"
    exit 1
fi

echo ""
echo "🚀 配置完成！"
echo ""
echo "下一步操作："
echo "1. 📖 重新生成博客"
echo "   hexo clean && hexo generate"
echo ""
echo "2. 🧪 本地测试"
echo "   hexo server"
echo "   访问: http://localhost:4000"
echo ""
echo "3. 🌐 部署到线上"
echo "   ./bin/deploy.sh"
echo ""
echo "📚 详细文档："
echo "   cat docs/giscus-config-guide.md"

# 检查是否需要启用文章评论
echo ""
echo "📝 检查文章模板中的评论设置..."
if grep -q "comments:" scaffolds/post.md; then
    echo "✅ 文章模板已包含 comments 字段"
else
    echo "⚠️  文章模板缺少 comments 字段"
    echo "  建议在 scaffolds/post.md 中添加："
    echo "  comments: true"
fi

echo ""
echo "🎉 Giscus 配置完成！"