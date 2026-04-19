#!/bin/bash
# 自动化创建文章脚本
# 用法: ./bin/new-post.sh "文章标题" [标签1 标签2 ...]

# 参数检查
if [ $# -eq 0 ]; then
    echo "错误：请提供文章标题"
    echo "用法: $0 \"文章标题\" [标签1 标签2 ...]"
    exit 1
fi

TITLE="$1"
SLUG=$(echo "$TITLE" | iconv -t ascii//TRANSLIT | sed -r 's/[^a-zA-Z0-9]+/-/g' | sed -r 's/^-+\|-+$//g' | tr A-Z a-z)
DATE=$(date +"%Y-%m-%d %H:%M:%S")

# 生成标签部分
TAGS=""
if [ $# -gt 1 ]; then
    shift
    TAGS="tags:"
    for TAG in "$@"; do
        TAGS="$TAGS\n  - $TAG"
    done
else
    TAGS="tags: []"
fi

# 创建文章
echo "创建文章: $TITLE"
hexo new post "$TITLE"

# 获取最新创建的文件
POST_FILE=$(ls -t source/_posts/*.md | head -1)

if [ ! -f "$POST_FILE" ]; then
    echo "错误：找不到创建的文章文件"
    exit 1
fi

# 更新Front Matter
sed -i "1,/^---$/ {
    /date:/c\date: $DATE
    /tags:/c\\$TAGS
}" "$POST_FILE"

# 添加分类和更多Front Matter字段
sed -i "/^tags:/a\\
categories:\\
  - 技术\\
toc: true\\
mathjax: false\\
comments: true\\
sticky: 0" "$POST_FILE"

echo "✅ 文章创建成功: $POST_FILE"
echo "📝 标题: $TITLE"
echo "🔗 固定链接: /$(date +%Y/%m/%d)/$SLUG/"
echo "🏷️  标签: $TAGS"
echo ""
echo "提示："
echo "1. 编辑文件: $POST_FILE"
echo "2. 本地预览: hexo server"
echo "3. 部署发布: hexo clean && hexo generate && hexo deploy"
echo ""
echo "💡 提示：使用增强版脚本获得更多功能:"
echo "   ./bin/new-post-enhanced.sh \"文章标题\" --tags \"标签\" --categories \"分类\" --open"
echo "   ./bin/write-flow.sh (完整写作流程)"