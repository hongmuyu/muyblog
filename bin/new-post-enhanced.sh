#!/bin/bash
# 增强版文章创建脚本
# 支持更多选项和自动化功能

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 默认配置
DEFAULT_TAGS="随笔"
DEFAULT_CATEGORIES="未分类"
DEFAULT_TOC=true
DEFAULT_COMMENTS=true
DEFAULT_MATHJAX=false
DEFAULT_STICKY=0
EDITOR="code"  # VS Code，可以修改为其他编辑器

# 显示帮助信息
show_help() {
    cat << EOF
增强版文章创建脚本

用法: $0 [选项] "文章标题"

选项:
  -h, --help                   显示此帮助信息
  -t, --tags "标签1,标签2"     设置文章标签（逗号分隔）
  -c, --categories "分类1,分类2" 设置文章分类（逗号分隔）
  -s, --slug "自定义链接"       自定义文章固定链接
  --no-toc                     禁用目录
  --no-comments                禁用评论
  --mathjax                    启用MathJax数学公式
  --sticky N                   置顶级别 (0-10)
  --draft                      创建为草稿
  --editor EDITOR              指定编辑器 (默认: code)
  --open                       创建后打开编辑器
  --preview                    创建后启动本地预览
  --template                   使用模板文件

示例:
  $0 "我的新文章"
  $0 "React教程" --tags "前端,React,JavaScript" --categories "技术,前端"
  $0 "数学公式测试" --mathjax --sticky 5
  $0 "重要通知" --no-comments --sticky 10 --open --preview

高级功能:
  - 自动生成文章资源文件夹 (post_asset_folder: true)
  - 智能生成固定链接
  - 自动添加Front Matter字段
  - 可选启动本地服务器和打开编辑器
EOF
}

# 解析参数
TITLE=""
TAGS="$DEFAULT_TAGS"
CATEGORIES="$DEFAULT_CATEGORIES"
SLUG=""
TOC="$DEFAULT_TOC"
COMMENTS="$DEFAULT_COMMENTS"
MATHJAX="$DEFAULT_MATHJAX"
STICKY="$DEFAULT_STICKY"
IS_DRAFT=false
OPEN_EDITOR=false
START_PREVIEW=false
USE_TEMPLATE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -t|--tags)
            TAGS="$2"
            shift 2
            ;;
        -c|--categories)
            CATEGORIES="$2"
            shift 2
            ;;
        -s|--slug)
            SLUG="$2"
            shift 2
            ;;
        --no-toc)
            TOC=false
            shift
            ;;
        --no-comments)
            COMMENTS=false
            shift
            ;;
        --mathjax)
            MATHJAX=true
            shift
            ;;
        --sticky)
            STICKY="$2"
            shift 2
            ;;
        --draft)
            IS_DRAFT=true
            shift
            ;;
        --editor)
            EDITOR="$2"
            shift 2
            ;;
        --open)
            OPEN_EDITOR=true
            shift
            ;;
        --preview)
            START_PREVIEW=true
            shift
            ;;
        --template)
            USE_TEMPLATE=true
            shift
            ;;
        *)
            # 第一个非选项参数视为标题
            if [ -z "$TITLE" ]; then
                TITLE="$1"
                shift
            else
                echo -e "${RED}错误: 未知参数: $1${NC}"
                show_help
                exit 1
            fi
            ;;
    esac
done

# 检查标题
if [ -z "$TITLE" ]; then
    echo -e "${RED}错误: 请提供文章标题${NC}"
    show_help
    exit 1
fi

# 显示标题
echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           增强版文章创建工具                    ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# 生成固定链接
if [ -z "$SLUG" ]; then
    # 智能生成slug：移除特殊字符，转换为小写，用连字符连接
    SLUG=$(echo "$TITLE" | \
        iconv -t ascii//TRANSLIT 2>/dev/null || echo "$TITLE" | \
        tr '[:upper:]' '[:lower:]' | \
        sed -e 's/[^a-zA-Z0-9]/-/g' -e 's/-\+/-/g' -e 's/^-\|-$//g')
fi

DATE=$(date +"%Y-%m-%d %H:%M:%S")
DATE_ONLY=$(date +"%Y-%m-%d")

# 解析标签和分类（逗号分隔）
parse_list() {
    local list="$1"
    echo "$list" | tr ',' '\n' | sed 's/^ *//;s/ *$//' | grep -v '^$'
}

TAGS_LIST=$(parse_list "$TAGS")
CATEGORIES_LIST=$(parse_list "$CATEGORIES")

# 创建标签和分类的YAML格式
format_yaml_list() {
    local list="$1"
    if [ -z "$list" ]; then
        echo "[]"
    else
        echo "$list" | sed 's/^/  - /'
    fi
}

TAGS_YAML=$(format_yaml_list "$TAGS_LIST")
CATEGORIES_YAML=$(format_yaml_list "$CATEGORIES_LIST")

# 确定文章类型
POST_TYPE="post"
if [ "$IS_DRAFT" = true ]; then
    POST_TYPE="draft"
fi

echo -e "${GREEN}[1/5] 创建${POST_TYPE}: ${TITLE}${NC}"
echo -e "  📅 日期: $DATE"
echo -e "  🔗 固定链接: $SLUG"
echo -e "  🏷️  标签: $(echo "$TAGS_LIST" | tr '\n' ', ' | sed 's/,$//')"
echo -e "  📁 分类: $(echo "$CATEGORIES_LIST" | tr '\n' ', ' | sed 's/,$//')"

# 创建文章
echo -e "${GREEN}[2/5] 执行Hexo创建命令...${NC}"
if [ "$IS_DRAFT" = true ]; then
    hexo new draft "$TITLE"
else
    hexo new post "$TITLE"
fi

# 获取最新创建的文件
if [ "$IS_DRAFT" = true ]; then
    POST_FILE=$(ls -t source/_drafts/*.md 2>/dev/null | head -1)
else
    POST_FILE=$(ls -t source/_posts/*.md 2>/dev/null | head -1)
fi

if [ ! -f "$POST_FILE" ]; then
    echo -e "${RED}错误: 找不到创建的文章文件${NC}"
    exit 1
fi

echo -e "  📄 文件: $POST_FILE"

# 创建完整的Front Matter
echo -e "${GREEN}[3/5] 更新Front Matter...${NC}"

# 备份原始文件
cp "$POST_FILE" "$POST_FILE.bak"

# 生成新的Front Matter内容
cat > "$POST_FILE" << EOF
---
title: $TITLE
date: $DATE
updated: $DATE
tags:
$TAGS_YAML
categories:
$CATEGORIES_YAML
permalink: :year/:month/:day/:slug/
slug: $SLUG
toc: $TOC
comments: $COMMENTS
mathjax: $MATHJAX
sticky: $STICKY
---

<!-- more -->

## 引言

在这里写下文章的开头...

## 正文

文章正文内容...

## 总结

总结全文要点...

EOF

# 如果使用模板，应用模板
if [ "$USE_TEMPLATE" = true ] && [ -f "scaffolds/post.md" ]; then
    echo -e "  📋 应用模板..."
    # 保留Front Matter，替换内容
    TEMPLATE_CONTENT=$(tail -n +$(($(grep -n "^---$" scaffolds/post.md | tail -1 | cut -d: -f1) + 1)) scaffolds/post.md)
    sed -i "/^<!-- more -->/,\$d" "$POST_FILE"
    echo "$TEMPLATE_CONTENT" >> "$POST_FILE"
fi

# 创建文章资源文件夹（如果配置启用）
if [ -d "${POST_FILE%.md}" ]; then
    echo -e "  📁 文章资源文件夹已创建"
fi

echo -e "${GREEN}[4/5] 文章创建完成!${NC}"

# 显示文章信息
echo ""
echo -e "${CYAN}══════════════════════════════════════════════════${NC}"
echo -e "${CYAN}文章信息${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════${NC}"
echo -e "标题:      $TITLE"
echo -e "文件:      $POST_FILE"
echo -e "类型:      ${POST_TYPE}"
echo -e "日期:      $DATE_ONLY"
echo -e "固定链接:  /$DATE_ONLY/$SLUG/"
echo -e "标签:      $(echo "$TAGS_LIST" | tr '\n' ', ')"
echo -e "分类:      $(echo "$CATEGORIES_LIST" | tr '\n' ', ')"
echo -e "目录:      $TOC"
echo -e "评论:      $COMMENTS"
echo -e "数学公式:  $MATHJAX"
echo -e "置顶:      $STICKY"
echo -e "${CYAN}══════════════════════════════════════════════════${NC}"

# 打开编辑器
if [ "$OPEN_EDITOR" = true ]; then
    echo -e "${GREEN}[5/5] 打开编辑器...${NC}"
    if command -v "$EDITOR" &> /dev/null; then
        "$EDITOR" "$POST_FILE"
        echo -e "  ✨ 已在 $EDITOR 中打开文章"
    else
        echo -e "${YELLOW}警告: 编辑器 '$EDITOR' 未找到，请手动打开文件${NC}"
        echo -e "  文件路径: $POST_FILE"
    fi
else
    echo -e "${GREEN}[5/5] 完成!${NC}"
fi

# 启动本地预览
if [ "$START_PREVIEW" = true ]; then
    echo ""
    echo -e "${YELLOW}启动本地预览服务器...${NC}"
    echo -e "访问: http://localhost:4000"
    echo -e "停止服务器: Ctrl+C"
    echo ""

    # 在后台启动服务器
    if [ "$IS_DRAFT" = true ]; then
        hexo server --draft &
    else
        hexo server &
    fi

    SERVER_PID=$!
    echo -e "服务器PID: $SERVER_PID"

    # 提示用户如何停止
    echo -e "\n要停止服务器，运行: kill $SERVER_PID"
fi

# 显示后续步骤
echo ""
echo -e "${MAGENTA}后续步骤:${NC}"
echo "1. 编辑文章: $POST_FILE"
if [ "$IS_DRAFT" = false ]; then
    echo "2. 本地预览: hexo server"
    echo "3. 生成静态文件: hexo generate"
    echo "4. 部署: hexo deploy"
else
    echo "2. 预览草稿: hexo server --draft"
    echo "3. 发布草稿: hexo publish $POST_FILE"
fi
echo "5. 一键部署: ./bin/deploy.sh"

# 生成快捷命令
echo ""
echo -e "${YELLOW}快捷命令:${NC}"
echo "编辑:    $EDITOR '$POST_FILE'"
if [ "$IS_DRAFT" = true ]; then
    echo "预览:    hexo server --draft"
else
    echo "预览:    hexo server"
fi
echo "部署:    ./bin/deploy.sh"

# 保存配置到日志
LOG_FILE="bin/article-creation.log"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] $POST_TYPE: $TITLE (slug: $SLUG)" >> "$LOG_FILE"
echo -e "\n日志: $LOG_FILE"