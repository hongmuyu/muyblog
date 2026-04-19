#!/bin/bash
# 博客图片优化脚本 - 专门用于WebP转换和图片优化
# 针对Hexo博客文章中的图片进行批量优化

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认配置
WEBP_QUALITY=80
MAX_WIDTH=1200
COMPRESS_LEVEL=6

# 显示标题
show_header() {
    clear
    echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║           Hexo博客图片优化工具                  ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
}

# 检查依赖
check_dependencies() {
    echo -e "${GREEN}[1/4] 检查依赖...${NC}"

    local missing=()

    if ! command -v convert &> /dev/null; then
        missing+=("ImageMagick (convert)")
    fi

    if ! command -v cwebp &> /dev/null; then
        missing+=("WebP工具 (cwebp)")
    fi

    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${YELLOW}警告: 以下工具未安装:${NC}"
        for tool in "${missing[@]}"; do
            echo "  - $tool"
        done
        echo ""
        echo -e "${YELLOW}安装命令:${NC}"
        echo "  Ubuntu/Debian: sudo apt-get install imagemagick webp"
        echo "  macOS: brew install imagemagick webp"
        echo ""
        echo -e "${RED}请先安装依赖工具再运行本脚本${NC}"
        exit 1
    fi

    echo -e "${GREEN}✓ 所有依赖已安装${NC}"
    echo ""
}

# 选择优化模式
select_mode() {
    echo -e "${GREEN}[2/4] 选择优化模式:${NC}"
    echo "  1) 转换单个目录为WebP"
    echo "  2) 批量转换整个uploads目录"
    echo "  3) 优化文章资源文件夹"
    echo "  4) 生成响应式图片(srcset)"
    echo ""
    read -p "请选择 (1-4): " mode

    case $mode in
        1)
            read -p "请输入目录路径: " target_dir
            if [ ! -d "$target_dir" ]; then
                echo -e "${RED}错误: 目录不存在${NC}"
                exit 1
            fi
            optimize_directory "$target_dir"
            ;;
        2)
            if [ ! -d "source/images/uploads" ]; then
                echo -e "${YELLOW}创建目录: source/images/uploads${NC}"
                mkdir -p "source/images/uploads"
            fi
            optimize_directory "source/images/uploads"
            ;;
        3)
            optimize_post_images
            ;;
        4)
            generate_srcset
            ;;
        *)
            echo -e "${RED}错误: 无效选择${NC}"
            exit 1
            ;;
    esac
}

# 优化单个目录
optimize_directory() {
    local dir="$1"
    echo -e "${GREEN}[3/4] 优化目录: $dir${NC}"

    # 创建WebP目录
    local webp_dir="${dir}_webp"
    mkdir -p "$webp_dir"

    # 支持的图片格式
    local formats=("jpg" "jpeg" "png" "gif" "bmp")
    local total=0
    local converted=0

    for format in "${formats[@]}"; do
        find "$dir" -type f -iname "*.${format}" | while read -r image; do
            ((total++))
            local filename=$(basename "$image")
            local name="${filename%.*}"
            local webp_file="$webp_dir/${name}.webp"

            echo -n "  转换: $filename → ${name}.webp ... "

            # 转换到WebP
            if cwebp -q $WEBP_QUALITY -m $COMPRESS_LEVEL "$image" -o "$webp_file" > /dev/null 2>&1; then
                # 获取大小对比
                local orig_size=$(stat -c%s "$image" 2>/dev/null || stat -f%z "$image" 2>/dev/null)
                local new_size=$(stat -c%s "$webp_file" 2>/dev/null || stat -f%z "$webp_file" 2>/dev/null)
                local savings=$((100 - new_size * 100 / orig_size))

                if [ $savings -gt 0 ]; then
                    echo -e "${GREEN}✓ 节省 ${savings}%${NC}"
                else
                    echo -e "${YELLOW}⚠ 大小增加${NC}"
                fi

                ((converted++))
            else
                echo -e "${RED}✗ 失败${NC}"
            fi
        done
    done

    echo ""
    echo -e "${GREEN}[4/4] 完成!${NC}"
    echo -e "转换了 $converted/$total 个文件"
    echo -e "WebP文件保存在: $webp_dir"
    echo ""

    # 生成使用说明
    generate_usage_guide "$webp_dir"
}

# 优化文章资源文件夹
optimize_post_images() {
    echo -e "${GREEN}[3/4] 扫描文章资源文件夹...${NC}"

    local posts_dir="source/_posts"
    local optimized_count=0

    find "$posts_dir" -type d -name "*.assets" 2>/dev/null | while read -r asset_dir; do
        echo "  检查: $(basename "$asset_dir")"

        # 查找图片文件
        find "$asset_dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | while read -r image; do
            local filename=$(basename "$image")
            local name="${filename%.*}"
            local ext="${filename##*.}"
            local webp_file="${image%.*}.webp"

            # 如果WebP文件不存在，则创建
            if [ ! -f "$webp_file" ]; then
                echo -n "    转换: $filename → ${name}.webp ... "

                if cwebp -q $WEBP_QUALITY "$image" -o "$webp_file" > /dev/null 2>&1; then
                    echo -e "${GREEN}✓${NC}"
                    ((optimized_count++))
                else
                    echo -e "${RED}✗${NC}"
                fi
            fi
        done
    done

    echo ""
    echo -e "${GREEN}[4/4] 完成!${NC}"
    echo -e "优化了 $optimized_count 个文章图片"
    echo ""

    # 更新图片引用脚本
    update_image_references
}

# 生成响应式图片
generate_srcset() {
    echo -e "${GREEN}[3/4] 生成响应式图片...${NC}"

    local src_dir="source/images/uploads"
    local sizes=("400" "800" "1200" "1600")

    if [ ! -d "$src_dir" ]; then
        echo -e "${YELLOW}目录不存在: $src_dir${NC}"
        return
    fi

    # 为每张图片生成不同尺寸
    find "$src_dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | while read -r image; do
        local filename=$(basename "$image")
        local name="${filename%.*}"
        local ext="${filename##*.}"

        echo "  处理: $filename"

        # 为每个尺寸生成图片
        for size in "${sizes[@]}"; do
            local sized_file="source/images/responsive/${name}_${size}w.${ext}"
            mkdir -p "source/images/responsive"

            echo -n "    生成 ${size}px 版本 ... "

            if convert "$image" -resize "${size}x>" -quality 85 -strip "$sized_file" > /dev/null 2>&1; then
                echo -e "${GREEN}✓${NC}"
            else
                echo -e "${RED}✗${NC}"
            fi
        done

        # 生成WebP版本
        for size in "${sizes[@]}"; do
            local webp_file="source/images/responsive/${name}_${size}w.webp"

            echo -n "    生成 ${size}px WebP 版本 ... "

            local sized_file="source/images/responsive/${name}_${size}w.${ext}"
            if [ -f "$sized_file" ]; then
                if cwebp -q $WEBP_QUALITY "$sized_file" -o "$webp_file" > /dev/null 2>&1; then
                    echo -e "${GREEN}✓${NC}"
                else
                    echo -e "${RED}✗${NC}"
                fi
            fi
        done
    done

    echo ""
    echo -e "${GREEN}[4/4] 完成!${NC}"
    echo -e "响应式图片已生成到: source/images/responsive/"
    echo ""

    # 生成HTML示例
    generate_html_example
}

# 生成使用指南
generate_usage_guide() {
    local webp_dir="$1"
    cat > "$webp_dir/USAGE.md" << EOF
# WebP图片使用指南

## 文件说明
- 原始图片: 在上级目录中
- WebP图片: 在本目录中 (${webp_dir})

## 使用方法

### 1. Hexo文章中使用
\`\`\`markdown
<!-- 原图作为后备 -->
![图片描述](原始图片.jpg)

<!-- 优先使用WebP -->
<picture>
  <source srcset="/images/uploads_webp/图片名.webp" type="image/webp">
  <img src="/images/uploads/图片名.jpg" alt="图片描述">
</picture>
\`\`\`

### 2. HTML中使用
\`\`\`html
<picture>
  <source srcset="/images/uploads_webp/图片名.webp" type="image/webp">
  <source srcset="/images/uploads/图片名.jpg" type="image/jpeg">
  <img src="/images/uploads/图片名.jpg" alt="图片描述">
</picture>
\`\`\`

### 3. 更新现有文章
使用以下命令批量更新图片引用：
\`\`\`bash
# 将.jpg替换为.webp
find source/_posts -name "*.md" -exec sed -i 's/\\.jpg\\([^)]*\\))/.webp\\1)/g' {} \\;
\`\`\`

## 性能优势
- WebP通常比JPEG小25-35%
- 比PNG小80%以上
- 支持透明度和动画

## 浏览器支持
- 现代浏览器都支持WebP
- 旧版浏览器会自动回退到原始格式

## 维护建议
1. 定期运行优化脚本更新图片
2. 新图片直接上传WebP格式
3. 删除不再使用的原始图片节省空间
EOF

    echo -e "${BLUE}使用指南已生成: $webp_dir/USAGE.md${NC}"
}

# 更新图片引用
update_image_references() {
    cat > "bin/update-image-refs.sh" << 'EOF'
#!/bin/bash
# 批量更新文章中的图片引用

echo "开始更新文章图片引用..."

# 1. 将普通图片引用更新为响应式图片
find source/_posts -name "*.md" -exec sed -i \
    -e 's/!\[\([^]]*\)\](\([^)]*\)\.\(jpg\|jpeg\|png\))/<picture>\n  <source srcset="\/images\/responsive\/\2_800w.webp" type="image\/webp">\n  <source srcset="\/images\/uploads\/\2.\3" type="image\/\3">\n  <img src="\/images\/uploads\/\2.\3" alt="\1">\n<\/picture>/g' \
    {} \;

# 2. 更新资源文件夹中的图片引用
find source/_posts -name "*.md" -exec sed -i \
    -e 's/{% asset_img \([^ ]*\)\.\(jpg\|jpeg\|png\)\(.*\) %}/<picture>\n  <source srcset="{% asset_path \1.webp %}" type="image\/webp">\n  <img src="{% asset_path \1.\2 %}" alt="\3">\n<\/picture>/g' \
    {} \;

echo "更新完成!"
EOF

    chmod +x "bin/update-image-refs.sh"
    echo -e "${BLUE}图片引用更新脚本已生成: bin/update-image-refs.sh${NC}"
    echo -e "${YELLOW}注意: 请先检查脚本，然后手动运行${NC}"
}

# 生成HTML示例
generate_html_example() {
    cat > "source/images/responsive/EXAMPLE.md" << 'EOF'
# 响应式图片使用示例

## HTML代码
```html
<!-- 基础用法 -->
<img
  src="/images/responsive/example_800w.jpg"
  srcset="/images/responsive/example_400w.jpg 400w,
          /images/responsive/example_800w.jpg 800w,
          /images/responsive/example_1200w.jpg 1200w"
  sizes="(max-width: 600px) 400px,
         (max-width: 1200px) 800px,
         1200px"
  alt="示例图片"
  loading="lazy"
>

<!-- WebP优先 -->
<picture>
  <source
    srcset="/images/responsive/example_400w.webp 400w,
            /images/responsive/example_800w.webp 800w"
    type="image/webp"
    sizes="(max-width: 600px) 400px, 800px">
  <source
    srcset="/images/responsive/example_400w.jpg 400w,
            /images/responsive/example_800w.jpg 800w"
    type="image/jpeg"
    sizes="(max-width: 600px) 400px, 800px">
  <img
    src="/images/responsive/example_800w.jpg"
    alt="示例图片"
    loading="lazy">
</picture>
```

## Markdown中使用
由于Markdown不支持srcset，建议使用HTML标签或在文章中直接嵌入HTML。

## 性能优化
1. 使用`sizes`属性告诉浏览器如何选择图片
2. 添加`loading="lazy"`实现懒加载
3. 使用WebP格式优先
4. 为小屏幕设备提供小尺寸图片
EOF

    echo -e "${BLUE}示例文件已生成: source/images/responsive/EXAMPLE.md${NC}"
}

# 主函数
main() {
    show_header
    check_dependencies
    select_mode
}

# 执行
main