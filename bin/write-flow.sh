#!/bin/bash
# 完整写作流程脚本
# 整合文章创建、预览、编辑和监控功能

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# 配置
EDITOR="code"  # 默认编辑器
PREVIEW_PORT=4000
WATCH_DIRS=("source/_posts" "source/_drafts" "source/images")

# 显示标题
show_header() {
    clear
    echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║           Hexo博客完整写作流程                   ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
}

# 显示主菜单
show_menu() {
    echo -e "${GREEN}请选择操作:${NC}"
    echo "  1) 创建新文章"
    echo "  2) 创建草稿"
    echo "  3) 编辑最近的文章"
    echo "  4) 启动本地预览"
    echo "  5) 文件变化监控"
    echo "  6) 一键部署"
    echo "  7) 图片优化"
    echo "  8) 搜索和替换"
    echo "  9) 退出"
    echo ""
}

# 创建新文章
create_new_post() {
    echo -e "${GREEN}创建新文章${NC}"
    echo -e "请输入文章标题:"
    read -r title

    if [ -z "$title" ]; then
        echo -e "${RED}错误: 标题不能为空${NC}"
        return 1
    fi

    echo -e "标签 (逗号分隔，默认: 随笔):"
    read -r tags
    tags=${tags:-"随笔"}

    echo -e "分类 (逗号分隔，默认: 未分类):"
    read -r categories
    categories=${categories:-"未分类"}

    echo -e "是否启用目录? [Y/n]:"
    read -r toc
    toc=${toc:-"Y"}

    echo -e "是否启用评论? [Y/n]:"
    read -r comments
    comments=${comments:-"Y"}

    # 构建命令参数
    cmd="./bin/new-post-enhanced.sh \"$title\" --tags \"$tags\" --categories \"$categories\" --open"

    if [[ "$toc" =~ ^([nN][oO]|[nN])$ ]]; then
        cmd="$cmd --no-toc"
    fi

    if [[ "$comments" =~ ^([nN][oO]|[nN])$ ]]; then
        cmd="$cmd --no-comments"
    fi

    echo -e "\n执行命令: $cmd"
    echo ""

    eval "$cmd"
}

# 创建草稿
create_draft() {
    echo -e "${GREEN}创建草稿${NC}"
    echo -e "请输入草稿标题:"
    read -r title

    if [ -z "$title" ]; then
        echo -e "${RED}错误: 标题不能为空${NC}"
        return 1
    fi

    ./bin/new-post-enhanced.sh "$title" --draft --open
}

# 编辑最近的文章
edit_recent_post() {
    echo -e "${GREEN}编辑最近的文章${NC}"

    # 查找最近修改的文章
    recent_post=$(find source/_posts -name "*.md" -type f -exec ls -t {} + | head -1)
    recent_draft=$(find source/_drafts -name "*.md" -type f -exec ls -t {} + 2>/dev/null | head -1)

    echo "最近的文章:"
    if [ -n "$recent_post" ]; then
        echo "  1) 文章: $(basename "$recent_post") ($(date -r "$recent_post" "+%Y-%m-%d %H:%M"))"
    fi

    if [ -n "$recent_draft" ]; then
        echo "  2) 草稿: $(basename "$recent_draft") ($(date -r "$recent_draft" "+%Y-%m-%d %H:%M"))"
    fi

    echo "  3) 手动选择文件"
    echo "  4) 返回"

    read -p "请选择 (1-4): " choice

    case $choice in
        1)
            if [ -n "$recent_post" ]; then
                open_editor "$recent_post"
            else
                echo -e "${RED}没有找到文章${NC}"
            fi
            ;;
        2)
            if [ -n "$recent_draft" ]; then
                open_editor "$recent_draft"
            else
                echo -e "${RED}没有找到草稿${NC}"
            fi
            ;;
        3)
            select_file_to_edit
            ;;
        4)
            return
            ;;
        *)
            echo -e "${RED}无效选择${NC}"
            ;;
    esac
}

# 选择文件编辑
select_file_to_edit() {
    echo -e "${GREEN}选择文件编辑${NC}"

    # 显示文章列表
    echo "文章列表:"
    find source/_posts -name "*.md" | sort -r | head -10 | while read -r file; do
        echo "  $(basename "$file")"
    done

    echo ""
    echo "输入文件名 (支持部分匹配):"
    read -r filename

    if [ -z "$filename" ]; then
        echo -e "${YELLOW}取消${NC}"
        return
    fi

    # 查找匹配的文件
    matches=()
    while IFS= read -r file; do
        if [[ "$(basename "$file")" == *"$filename"* ]]; then
            matches+=("$file")
        fi
    done < <(find source/_posts -name "*.md")

    if [ ${#matches[@]} -eq 0 ]; then
        echo -e "${RED}没有找到匹配的文件${NC}"
        return
    elif [ ${#matches[@]} -eq 1 ]; then
        open_editor "${matches[0]}"
    else
        echo -e "${YELLOW}找到多个匹配:${NC}"
        for i in "${!matches[@]}"; do
            echo "  $((i+1))) $(basename "${matches[$i]}")"
        done

        read -p "请选择 (1-${#matches[@]}): " index
        if [[ "$index" =~ ^[0-9]+$ ]] && [ "$index" -ge 1 ] && [ "$index" -le ${#matches[@]} ]; then
            open_editor "${matches[$((index-1))]}"
        else
            echo -e "${RED}无效选择${NC}"
        fi
    fi
}

# 打开编辑器
open_editor() {
    local file="$1"

    if [ ! -f "$file" ]; then
        echo -e "${RED}文件不存在: $file${NC}"
        return 1
    fi

    echo -e "打开: $file"

    if command -v "$EDITOR" &> /dev/null; then
        "$EDITOR" "$file"
        echo -e "${GREEN}已在 $EDITOR 中打开文件${NC}"
    else
        echo -e "${YELLOW}编辑器 $EDITOR 未找到，请手动打开${NC}"
        echo -e "文件路径: $file"
    fi
}

# 启动本地预览
start_preview() {
    echo -e "${GREEN}启动本地预览${NC}"

    # 检查是否已在运行
    if pgrep -f "hexo server" > /dev/null; then
        echo -e "${YELLOW}Hexo服务器已在运行${NC}"
        echo -e "访问: http://localhost:$PREVIEW_PORT"
        echo -e "停止命令: pkill -f 'hexo server'"
        return
    fi

    echo -e "启动Hexo本地服务器..."
    echo -e "访问: http://localhost:$PREVIEW_PORT"
    echo -e "停止服务器: Ctrl+C"
    echo ""

    # 在后台启动
    hexo server &
    SERVER_PID=$!

    echo -e "服务器PID: $SERVER_PID"
    echo -e "日志文件: hexo-server.log"

    # 保存PID到文件
    echo "$SERVER_PID" > /tmp/hexo-server.pid

    # 等待服务器启动
    sleep 2

    # 尝试打开浏览器
    if command -v xdg-open &> /dev/null; then
        xdg-open "http://localhost:$PREVIEW_PORT" 2>/dev/null &
    elif command -v open &> /dev/null; then
        open "http://localhost:$PREVIEW_PORT" 2>/dev/null &
    fi

    # 显示日志
    tail -f hexo-server.log 2>/dev/null || echo "日志输出不可用"
}

# 文件变化监控
watch_files() {
    echo -e "${GREEN}文件变化监控${NC}"

    if ! command -v fswatch &> /dev/null; then
        echo -e "${YELLOW}fswatch未安装，无法监控文件变化${NC}"
        echo -e "安装命令:"
        echo "  macOS: brew install fswatch"
        echo "  Linux: 需要从源码编译安装"
        return 1
    fi

    echo -e "监控目录: ${WATCH_DIRS[*]}"
    echo -e "文件变化时将自动重新生成静态文件"
    echo -e "停止监控: Ctrl+C"
    echo ""

    # 启动监控
    fswatch -o "${WATCH_DIRS[@]}" | while read -r; do
        echo -e "\n${YELLOW}[$(date '+%H:%M:%S')] 检测到文件变化，重新生成...${NC}"
        hexo generate --watch 2>&1 | head -5
    done
}

# 一键部署
deploy_blog() {
    echo -e "${GREEN}一键部署${NC}"

    echo -e "请选择部署方式:"
    echo "  1) 仅生成"
    echo "  2) 生成并部署"
    echo "  3) 清理后生成部署"
    echo "  4) 返回"

    read -p "请选择 (1-4): " choice

    case $choice in
        1)
            echo -e "生成静态文件..."
            hexo generate
            ;;
        2)
            echo -e "生成并部署..."
            hexo generate --deploy
            ;;
        3)
            echo -e "清理后生成部署..."
            hexo clean && hexo generate --deploy
            ;;
        4)
            return
            ;;
        *)
            echo -e "${RED}无效选择${NC}"
            ;;
    esac

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}部署完成!${NC}"
        echo -e "博客地址: https://zouwenxiang.cn"
    else
        echo -e "${RED}部署失败，请检查错误信息${NC}"
    fi
}

# 图片优化
optimize_images() {
    echo -e "${GREEN}图片优化${NC}"

    if [ -f "./bin/optimize-images.sh" ]; then
        ./bin/optimize-images.sh
    else
        echo -e "${YELLOW}图片优化脚本未找到${NC}"
        echo -e "请先运行: ./bin/process-images.sh"
    fi
}

# 搜索和替换
search_and_replace() {
    echo -e "${GREEN}搜索和替换${NC}"

    echo -e "请输入搜索内容:"
    read -r search

    if [ -z "$search" ]; then
        echo -e "${YELLOW}取消${NC}"
        return
    fi

    echo -e "请输入替换内容 (直接回车仅搜索):"
    read -r replace

    echo -e "搜索范围:"
    echo "  1) 所有文章 (source/_posts)"
    echo "  2) 所有草稿 (source/_drafts)"
    echo "  3) 自定义目录"

    read -p "请选择 (1-3): " scope

    case $scope in
        1)
            target_dir="source/_posts"
            ;;
        2)
            target_dir="source/_drafts"
            ;;
        3)
            echo -e "请输入目录路径:"
            read -r target_dir
            if [ ! -d "$target_dir" ]; then
                echo -e "${RED}目录不存在${NC}"
                return
            fi
            ;;
        *)
            echo -e "${RED}无效选择${NC}"
            return
            ;;
    esac

    echo -e "\n搜索: '$search'"
    if [ -n "$replace" ]; then
        echo -e "替换为: '$replace'"
    fi
    echo -e "范围: $target_dir"
    echo ""

    # 先显示匹配结果
    echo -e "${YELLOW}匹配结果:${NC}"
    grep -r -l "$search" "$target_dir" 2>/dev/null | while read -r file; do
        echo "  $file"
        grep -n "$search" "$file" | head -3 | sed 's/^/    /'
    done

    if [ -n "$replace" ]; then
        echo -e "\n是否执行替换? [y/N]:"
        read -r confirm

        if [[ "$confirm" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            echo -e "执行替换..."
            find "$target_dir" -type f -name "*.md" -exec sed -i "s/$search/$replace/g" {} \;
            echo -e "${GREEN}替换完成!${NC}"
        else
            echo -e "${YELLOW}取消替换${NC}"
        fi
    fi
}

# 主函数
main() {
    while true; do
        show_header
        show_menu

        read -p "请选择 (1-9): " choice

        case $choice in
            1)
                create_new_post
                ;;
            2)
                create_draft
                ;;
            3)
                edit_recent_post
                ;;
            4)
                start_preview
                ;;
            5)
                watch_files
                ;;
            6)
                deploy_blog
                ;;
            7)
                optimize_images
                ;;
            8)
                search_and_replace
                ;;
            9)
                echo -e "${GREEN}退出写作流程工具${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}无效选择，请重新输入${NC}"
                ;;
        esac

        echo ""
        read -p "按回车键继续..."
    done
}

# 执行主函数
main