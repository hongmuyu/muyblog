#!/bin/bash
# 删除文章脚本
# 用法: ./bin/delete-post.sh "文章文件名或标题"

set -e

echo "🗑️  文章删除工具"
echo "================"

# 参数检查
if [ $# -eq 0 ]; then
    echo "错误：请提供文章文件名或标题"
    echo ""
    echo "用法:"
    echo "  $0 \"文章标题\"          # 通过标题删除"
    echo "  $0 hello-world.md       # 通过文件名删除"
    echo "  $0 --list               # 列出所有文章"
    echo "  $0 --interactive        # 交互式删除"
    exit 1
fi

POSTS_DIR="source/_posts"

# 列出所有文章
if [ "$1" = "--list" ]; then
    echo "📚 所有文章列表:"
    echo ""
    ls -la "$POSTS_DIR"/*.md | awk '{print NR, $9}' | sed "s|$POSTS_DIR/||g"
    exit 0
fi

# 交互式删除
if [ "$1" = "--interactive" ]; then
    echo "🔍 选择要删除的文章:"
    echo ""

    # 创建文章列表
    POSTS=($(ls "$POSTS_DIR"/*.md))

    if [ ${#POSTS[@]} -eq 0 ]; then
        echo "📭 没有找到文章"
        exit 0
    fi

    for i in "${!POSTS[@]}"; do
        FILENAME=$(basename "${POSTS[$i]}")
        TITLE=$(grep -m1 "^title:" "${POSTS[$i]}" | sed 's/title: //' | sed 's/"//g' | sed "s/'//g")
        DATE=$(grep -m1 "^date:" "${POSTS[$i]}" | sed 's/date: //' | cut -d' ' -f1)
        echo "$((i+1)). $FILENAME - $TITLE ($DATE)"
    done

    echo ""
    echo "输入文章编号 (输入 q 退出): "
    read SELECTION

    if [ "$SELECTION" = "q" ] || [ -z "$SELECTION" ]; then
        echo "退出删除操作"
        exit 0
    fi

    if ! [[ "$SELECTION" =~ ^[0-9]+$ ]] || [ "$SELECTION" -lt 1 ] || [ "$SELECTION" -gt ${#POSTS[@]} ]; then
        echo "❌ 无效的选择"
        exit 1
    fi

    SELECTED_FILE="${POSTS[$((SELECTION-1))]}"
    FILENAME=$(basename "$SELECTED_FILE")
    TITLE=$(grep -m1 "^title:" "$SELECTED_FILE" | sed 's/title: //' | sed 's/"//g' | sed "s/'//g")

    echo ""
    echo "⚠️  确认删除以下文章吗？"
    echo "   文件: $FILENAME"
    echo "   标题: $TITLE"
    echo ""
    echo "此操作不可撤销！"
    echo "输入 y 确认删除，其他任意键取消: "
    read CONFIRM

    if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]; then
        rm "$SELECTED_FILE"
        echo "✅ 文章已删除: $FILENAME"

        # 检查是否有对应的资源目录
        ASSET_DIR="${POSTS_DIR}/../_posts/${FILENAME%.md}"
        if [ -d "$ASSET_DIR" ]; then
            echo "🗂️  检测到关联资源目录，是否一并删除？ [y/N]: "
            read DELETE_ASSETS
            if [ "$DELETE_ASSETS" = "y" ] || [ "$DELETE_ASSETS" = "Y" ]; then
                rm -rf "$ASSET_DIR"
                echo "✅ 资源目录已删除: $ASSET_DIR"
            fi
        fi
    else
        echo "取消删除"
    fi

    exit 0
fi

# 通过文件名或标题删除
TARGET="$1"

# 如果是完整路径或相对路径，只取文件名
if [[ "$TARGET" == *"/"* ]]; then
    TARGET=$(basename "$TARGET")
fi

# 如果是标题，需要转换为文件名格式
if [[ "$TARGET" != *".md" ]]; then
    # 尝试通过标题查找文件
    echo "🔍 通过标题搜索: $TARGET"
    FOUND_FILES=$(grep -l "title:.*$TARGET" "$POSTS_DIR"/*.md 2>/dev/null || true)

    if [ -z "$FOUND_FILES" ]; then
        # 尝试模糊搜索
        echo "🔍 尝试模糊搜索..."
        FOUND_FILES=$(grep -l -i "$TARGET" "$POSTS_DIR"/*.md 2>/dev/null || true)
    fi

    if [ -z "$FOUND_FILES" ]; then
        echo "❌ 找不到标题包含 '$TARGET' 的文章"
        echo ""
        echo "📚 可用的文章:"
        ls "$POSTS_DIR"/*.md | sed "s|$POSTS_DIR/||g"
        exit 1
    fi

    FILE_COUNT=$(echo "$FOUND_FILES" | wc -l)

    if [ "$FILE_COUNT" -gt 1 ]; then
        echo "❌ 找到多个匹配的文章:"
        echo "$FOUND_FILES" | sed "s|$POSTS_DIR/||g"
        echo ""
        echo "请使用具体的文件名:"
        echo "  $0 \"文件名.md\""
        exit 1
    fi

    TARGET_FILE="$FOUND_FILES"
else
    # 直接是文件名
    TARGET_FILE="$POSTS_DIR/$TARGET"

    if [ ! -f "$TARGET_FILE" ]; then
        echo "❌ 找不到文件: $TARGET"
        echo ""
        echo "📚 可用的文章:"
        ls "$POSTS_DIR"/*.md | sed "s|$POSTS_DIR/||g"
        exit 1
    fi
fi

FILENAME=$(basename "$TARGET_FILE")
TITLE=$(grep -m1 "^title:" "$TARGET_FILE" | sed 's/title: //' | sed 's/"//g' | sed "s/'//g")

echo "📝 文章信息:"
echo "   文件: $FILENAME"
echo "   标题: $TITLE"
echo "   路径: $TARGET_FILE"
echo ""
echo "⚠️  确认删除吗？此操作不可撤销！"
echo "输入 y 确认删除，其他任意键取消: "
read CONFIRM

if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]; then
    rm "$TARGET_FILE"
    echo "✅ 文章已删除: $FILENAME"

    # 检查是否有对应的资源目录
    ASSET_DIR="${POSTS_DIR}/${FILENAME%.md}"
    if [ -d "$ASSET_DIR" ]; then
        echo "🗂️  检测到关联资源目录，是否一并删除？ [y/N]: "
        read DELETE_ASSETS
        if [ "$DELETE_ASSETS" = "y" ] || [ "$DELETE_ASSETS" = "Y" ]; then
            rm -rf "$ASSET_DIR"
            echo "✅ 资源目录已删除: $ASSET_DIR"
        fi
    fi
else
    echo "取消删除"
fi

echo ""
echo "提示：删除后需要重新生成和部署才能生效:"
echo "  ./bin/deploy.sh"