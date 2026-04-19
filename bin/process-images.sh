#!/bin/bash
# 图片批量处理脚本
# 功能：压缩、重命名、转换图片格式
# 依赖：ImageMagick (convert命令), pngquant, jpegoptim (可选)

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 默认配置
QUALITY=85
MAX_WIDTH=1920
SRC_DIR="source/images/uploads"
DEST_DIR="source/images/optimized"
BACKUP_DIR="source/images/backups/$(date +%Y%m%d_%H%M%S)"
FORMAT="jpg"  # 输出格式：jpg, png, webp

# 显示帮助信息
show_help() {
    cat << EOF
图片批量处理脚本

用法: $0 [选项] [目录]

选项:
  -h, --help          显示此帮助信息
  -s, --source DIR    源目录 (默认: $SRC_DIR)
  -d, --dest DIR      目标目录 (默认: $DEST_DIR)
  -q, --quality N     图片质量 1-100 (默认: $QUALITY)
  -w, --width N       最大宽度像素 (默认: $MAX_WIDTH)
  -f, --format FORMAT 输出格式: jpg, png, webp (默认: $FORMAT)
  -b, --backup        创建备份
  -r, --rename        使用时间戳重命名文件
  -v, --verbose       显示详细输出

示例:
  $0 -s source/images/uploads -d source/images/optimized -q 80 -w 1200
  $0 --source source/_posts/文章标题 --format webp --backup
  $0 --rename --verbose

EOF
}

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -s|--source)
            SRC_DIR="$2"
            shift 2
            ;;
        -d|--dest)
            DEST_DIR="$2"
            shift 2
            ;;
        -q|--quality)
            QUALITY="$2"
            shift 2
            ;;
        -w|--width)
            MAX_WIDTH="$2"
            shift 2
            ;;
        -f|--format)
            FORMAT="$2"
            shift 2
            ;;
        -b|--backup)
            BACKUP_ENABLED=true
            shift
            ;;
        -r|--rename)
            RENAME_ENABLED=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        *)
            # 如果第一个参数不是以-开头，视为目录
            if [[ ! "$1" =~ ^- ]]; then
                SRC_DIR="$1"
                shift
            else
                echo -e "${RED}错误: 未知选项 $1${NC}"
                show_help
                exit 1
            fi
            ;;
    esac
done

# 检查源目录
if [ ! -d "$SRC_DIR" ]; then
    echo -e "${YELLOW}警告: 源目录不存在: $SRC_DIR${NC}"
    echo -e "是否创建目录? [y/N]"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        mkdir -p "$SRC_DIR"
        echo -e "${GREEN}已创建目录: $SRC_DIR${NC}"
    else
        echo -e "${RED}错误: 源目录不存在，请提供正确的目录${NC}"
        exit 1
    fi
fi

# 创建目标目录
mkdir -p "$DEST_DIR"
if [ "$BACKUP_ENABLED" = true ]; then
    mkdir -p "$BACKUP_DIR"
fi

# 检查依赖
check_dependencies() {
    local missing_deps=()

    # 检查ImageMagick
    if ! command -v convert &> /dev/null; then
        missing_deps+=("ImageMagick (convert)")
    fi

    # 检查pngquant (用于PNG压缩)
    if ! command -v pngquant &> /dev/null; then
        missing_deps+=("pngquant (可选)")
    fi

    # 检查jpegoptim (用于JPEG压缩)
    if ! command -v jpegoptim &> /dev/null; then
        missing_deps+=("jpegoptim (可选)")
    fi

    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo -e "${YELLOW}警告: 以下依赖未安装:${NC}"
        for dep in "${missing_deps[@]}"; do
            echo "  - $dep"
        done
        echo -e "\n安装命令:"
        echo "  Ubuntu/Debian: sudo apt-get install imagemagick pngquant jpegoptim"
        echo "  macOS: brew install imagemagick pngquant jpegoptim"
        echo -e "\n继续使用基本功能? [Y/n]"
        read -r response
        if [[ "$response" =~ ^([nN][oO]|[nN])$ ]]; then
            exit 1
        fi
    fi
}

# 处理单个图片
process_image() {
    local src_file="$1"
    local filename=$(basename "$src_file")
    local name="${filename%.*}"
    local ext="${filename##*.}"

    # 生成目标文件名
    if [ "$RENAME_ENABLED" = true ]; then
        local timestamp=$(date +%Y%m%d_%H%M%S_%3N)
        local dest_filename="${timestamp}.${FORMAT}"
    else
        local dest_filename="${name}.${FORMAT}"
    fi

    local dest_file="$DEST_DIR/$dest_filename"

    # 备份原始文件
    if [ "$BACKUP_ENABLED" = true ]; then
        cp "$src_file" "$BACKUP_DIR/$filename"
        [ "$VERBOSE" = true ] && echo -e "  ${GREEN}✓${NC} 备份: $BACKUP_DIR/$filename"
    fi

    # 根据格式处理图片
    case $FORMAT in
        jpg|jpeg)
            # JPEG处理
            if command -v jpegoptim &> /dev/null; then
                jpegoptim --max=$QUALITY --strip-all --size=70% --dest="$DEST_DIR" "$src_file"
                [ "$VERBOSE" = true ] && echo -e "  ${GREEN}✓${NC} 使用jpegoptim压缩"
            else
                convert "$src_file" -resize "${MAX_WIDTH}x>" -quality $QUALITY -strip "$dest_file"
                [ "$VERBOSE" = true ] && echo -e "  ${GREEN}✓${NC} 使用ImageMagick转换"
            fi
            ;;
        png)
            # PNG处理
            if command -v pngquant &> /dev/null; then
                pngquant --quality=$QUALITY --force --output "$dest_file" "$src_file"
                [ "$VERBOSE" = true ] && echo -e "  ${GREEN}✓${NC} 使用pngquant压缩"
            else
                convert "$src_file" -resize "${MAX_WIDTH}x>" -quality $QUALITY -strip "$dest_file"
                [ "$VERBOSE" = true ] && echo -e "  ${GREEN}✓${NC} 使用ImageMagick转换"
            fi
            ;;
        webp)
            # WebP处理
            convert "$src_file" -resize "${MAX_WIDTH}x>" -quality $QUALITY -strip "$dest_file"
            [ "$VERBOSE" = true ] && echo -e "  ${GREEN}✓${NC} 转换为WebP格式"
            ;;
        *)
            echo -e "  ${RED}✗${NC} 不支持的格式: $FORMAT"
            return 1
            ;;
    esac

    # 获取原始和优化后的大小
    if [ "$VERBOSE" = true ]; then
        local orig_size=$(stat -c%s "$src_file" 2>/dev/null || stat -f%z "$src_file" 2>/dev/null)
        local new_size=$(stat -c%s "$dest_file" 2>/dev/null || stat -f%z "$dest_file" 2>/dev/null)
        local savings=$((100 - new_size * 100 / orig_size))

        if [ $savings -gt 0 ]; then
            echo -e "  ${GREEN}✓${NC} 大小: $(echo "scale=1; $orig_size/1024" | bc)KB → $(echo "scale=1; $new_size/1024" | bc)KB (节省 ${savings}%)"
        else
            echo -e "  ${YELLOW}⚠${NC} 大小: $(echo "scale=1; $orig_size/1024" | bc)KB → $(echo "scale=1; $new_size/1024" | bc)KB"
        fi
    fi

    return 0
}

# 主函数
main() {
    echo -e "${GREEN}开始图片批量处理${NC}"
    echo -e "源目录: $SRC_DIR"
    echo -e "目标目录: $DEST_DIR"
    echo -e "格式: $FORMAT, 质量: $QUALITY%, 最大宽度: ${MAX_WIDTH}px"
    echo -e "----------------------------------------"

    # 检查依赖
    check_dependencies

    # 统计
    local total=0
    local success=0
    local skipped=0

    # 支持的图片格式
    local supported_formats=("jpg" "jpeg" "png" "gif" "bmp" "webp")

    # 遍历源目录
    find "$SRC_DIR" -type f | while read -r src_file; do
        local ext="${src_file##*.}"
        ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

        # 检查是否是支持的图片格式
        local is_supported=false
        for format in "${supported_formats[@]}"; do
            if [ "$ext" = "$format" ]; then
                is_supported=true
                break
            fi
        done

        if [ "$is_supported" = false ]; then
            [ "$VERBOSE" = true ] && echo -e "${YELLOW}跳过: $src_file (不支持格式 .$ext)${NC}"
            ((skipped++))
            continue
        fi

        ((total++))

        echo -e "${GREEN}[$total]${NC} 处理: $(basename "$src_file")"

        if process_image "$src_file"; then
            ((success++))
        else
            echo -e "  ${RED}✗ 处理失败${NC}"
        fi

        echo ""
    done

    # 显示统计信息
    echo -e "${GREEN}处理完成!${NC}"
    echo -e "----------------------------------------"
    echo -e "总计: $total 个文件"
    echo -e "成功: $success"
    echo -e "跳过: $skipped"
    echo -e "失败: $((total - success - skipped))"

    if [ $success -gt 0 ]; then
        echo -e "\n优化后的图片保存在: $DEST_DIR"
        if [ "$BACKUP_ENABLED" = true ]; then
            echo -e "原始文件备份在: $BACKUP_DIR"
        fi

        # 显示优化建议
        echo -e "\n${YELLOW}下一步建议:${NC}"
        echo -e "1. 手动检查优化后的图片质量"
        echo -e "2. 更新文章中的图片引用"
        echo -e "3. 考虑删除原始文件以节省空间"
    fi
}

# 执行主函数
main