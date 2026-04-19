#!/bin/bash
# GitHub Pages部署验证脚本
# 检查网站的可访问性、性能和兼容性

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
SITE_URL="https://zouwenxiang.cn"
LOCAL_PORT=4000
TIMEOUT=10

# 显示标题
show_header() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║          GitHub Pages部署验证工具                ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
}

# 检查命令依赖
check_dependencies() {
    echo -e "${GREEN}[1/6] 检查依赖...${NC}"

    local missing=()

    if ! command -v curl &> /dev/null; then
        missing+=("curl")
    fi

    if ! command -v grep &> /dev/null; then
        missing+=("grep")
    fi

    if ! command -v awk &> /dev/null; then
        missing+=("awk")
    fi

    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${RED}错误: 缺少必要工具: ${missing[*]}${NC}"
        exit 1
    fi

    echo -e "${GREEN}✓ 所有依赖已安装${NC}"
}

# 检查本地服务
check_local_server() {
    echo -e "${GREEN}[2/6] 检查本地服务...${NC}"

    # 检查是否在运行
    if curl -s -o /dev/null -w "%{http_code}" "http://localhost:$LOCAL_PORT" | grep -q "200"; then
        echo -e "  ${GREEN}✓ 本地服务运行正常 (端口: $LOCAL_PORT)${NC}"
        return 0
    else
        echo -e "  ${YELLOW}⚠ 本地服务未运行${NC}"

        echo -e "是否启动本地服务? [Y/n]"
        read -r response
        if [[ ! "$response" =~ ^([nN][oO]|[nN])$ ]]; then
            echo -e "启动Hexo本地服务器..."
            hexo server --port $LOCAL_PORT > /tmp/hexo-server.log 2>&1 &
            SERVER_PID=$!
            echo -e "  ${GREEN}✓ 服务器已启动 (PID: $SERVER_PID)${NC}"
            echo -e "  日志: /tmp/hexo-server.log"

            # 等待服务器启动
            sleep 3
            return 0
        fi
        return 1
    fi
}

# 检查网站可访问性
check_accessibility() {
    echo -e "${GREEN}[3/6] 检查网站可访问性...${NC}"

    # 检查主站
    echo -n "  检查 $SITE_URL ... "
    local status_code
    status_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time $TIMEOUT "$SITE_URL")

    if [ "$status_code" = "200" ]; then
        echo -e "${GREEN}✓ 可访问 (HTTP $status_code)${NC}"
    else
        echo -e "${RED}✗ 不可访问 (HTTP $status_code)${NC}"
        return 1
    fi

    # 检查HTTPS
    echo -n "  检查HTTPS重定向... "
    local http_url="http://${SITE_URL#https://}"
    local location
    location=$(curl -s -o /dev/null -w "%{redirect_url}" --max-time $TIMEOUT "$http_url")

    if [[ "$location" == *"https://"* ]]; then
        echo -e "${GREEN}✓ HTTPS重定向正常${NC}"
    else
        echo -e "${YELLOW}⚠ 无HTTPS重定向${NC}"
    fi

    # 检查CNAME
    if [ -f "source/CNAME" ]; then
        echo -n "  检查CNAME配置... "
        local cname_content
        cname_content=$(cat source/CNAME)
        if [[ "$cname_content" == *"zouwenxiang.cn"* ]]; then
            echo -e "${GREEN}✓ CNAME配置正确${NC}"
        else
            echo -e "${YELLOW}⚠ CNAME配置可能有问题: $cname_content${NC}"
        fi
    fi

    return 0
}

# 检查性能指标
check_performance() {
    echo -e "${GREEN}[4/6] 检查性能指标...${NC}"

    # 使用curl测量时间
    echo -n "  测量响应时间... "
    local time_total
    time_total=$(curl -s -o /dev/null -w "%{time_total}\n" --max-time $TIMEOUT "$SITE_URL")

    if (( $(echo "$time_total < 1.0" | bc -l 2>/dev/null || echo "$time_total" | awk '$1 < 1.0') )); then
        echo -e "${GREEN}✓ 快速 ($(echo "$time_total*1000" | bc | cut -d. -f1)ms)${NC}"
    elif (( $(echo "$time_total < 3.0" | bc -l 2>/dev/null || echo "$time_total" | awk '$1 < 3.0') )); then
        echo -e "${YELLOW}⚠ 一般 ($(echo "$time_total*1000" | bc | cut -d. -f1)ms)${NC}"
    else
        echo -e "${RED}✗ 较慢 ($(echo "$time_total*1000" | bc | cut -d. -f1)ms)${NC}"
    fi

    # 检查页面大小
    echo -n "  检查页面大小... "
    local page_size
    page_size=$(curl -s -o /dev/null -w "%{size_download}\n" "$SITE_URL")
    local page_size_kb=$((page_size / 1024))

    if [ $page_size_kb -lt 100 ]; then
        echo -e "${GREEN}✓ 优秀 (${page_size_kb}KB)${NC}"
    elif [ $page_size_kb -lt 500 ]; then
        echo -e "${YELLOW}⚠ 正常 (${page_size_kb}KB)${NC}"
    else
        echo -e "${RED}✗ 较大 (${page_size_kb}KB)${NC}"
    fi

    # 检查HTTP头
    echo -n "  检查缓存头... "
    local cache_header
    cache_header=$(curl -s -I "$SITE_URL" | grep -i "cache-control" || true)

    if [[ "$cache_header" == *"max-age"* ]] || [[ "$cache_header" == *"public"* ]]; then
        echo -e "${GREEN}✓ 缓存配置正常${NC}"
    else
        echo -e "${YELLOW}⚠ 无缓存配置${NC}"
    fi
}

# 检查兼容性
check_compatibility() {
    echo -e "${GREEN}[5/6] 检查兼容性...${NC}"

    # 检查.nojekyll文件
    if [ -f "source/.nojekyll" ]; then
        echo -e "  ${GREEN}✓ .nojekyll文件存在${NC}"
    else
        echo -e "  ${YELLOW}⚠ .nojekyll文件不存在${NC}"
        echo -e "是否创建.nojekyll文件? [Y/n]"
        read -r response
        if [[ ! "$response" =~ ^([nN][oO]|[nN])$ ]]; then
            touch source/.nojekyll
            echo -e "  ${GREEN}✓ 已创建.nojekyll文件${NC}"
        fi
    fi

    # 检查GitHub Pages限制
    echo -n "  检查文件大小限制... "
    local large_files
    large_files=$(find public -type f -size +100M 2>/dev/null | head -5)

    if [ -z "$large_files" ]; then
        echo -e "${GREEN}✓ 无超大文件${NC}"
    else
        echo -e "${RED}✗ 发现超大文件 (>100MB):${NC}"
        echo "$large_files" | while read -r file; do
            echo "    - $file ($(du -h "$file" | cut -f1))"
        done
    fi

    # 检查相对路径
    echo -n "  检查相对路径... "
    local broken_links
    broken_links=$(grep -r "href=\"//" public/ 2>/dev/null | head -3 || true)

    if [ -z "$broken_links" ]; then
        echo -e "${GREEN}✓ 相对路径正常${NC}"
    else
        echo -e "${YELLOW}⚠ 发现可能的问题链接${NC}"
        echo "$broken_links" | head -3 | while read -r link; do
            echo "    - $link"
        done
    fi
}

# 生成报告
generate_report() {
    echo -e "${GREEN}[6/6] 生成验证报告...${NC}"

    local report_file="deployment-verification-$(date +%Y%m%d-%H%M%S).md"
    cat > "$report_file" << EOF
# GitHub Pages部署验证报告

**生成时间:** $(date '+%Y-%m-%d %H:%M:%S')
**网站地址:** $SITE_URL

## 1. 基本检查
- 本地服务: $(if check_local_server >/dev/null 2>&1; then echo "✅ 正常"; else echo "❌ 异常"; fi)
- 网站可访问性: $(if curl -s -o /dev/null -w "%{http_code}" "$SITE_URL" | grep -q "200"; then echo "✅ 正常"; else echo "❌ 异常"; fi)
- HTTPS重定向: $(if curl -s -o /dev/null -w "%{redirect_url}" "http://${SITE_URL#https://}" | grep -q "https://"; then echo "✅ 正常"; else echo "❌ 异常"; fi)
- CNAME配置: $(if [ -f "source/CNAME" ] && grep -q "zouwenxiang.cn" source/CNAME; then echo "✅ 正常"; else echo "❌ 异常"; fi)

## 2. 性能指标
- 响应时间: $(curl -s -o /dev/null -w "%{time_total}" "$SITE_URL") 秒
- 页面大小: $(curl -s -o /dev/null -w "%{size_download}" "$SITE_URL" | awk '{printf "%.1fKB", $1/1024}')
- 缓存配置: $(curl -s -I "$SITE_URL" | grep -i "cache-control" | head -1 || echo "未配置")

## 3. 兼容性检查
- .nojekyll文件: $(if [ -f "source/.nojekyll" ]; then echo "✅ 存在"; else echo "❌ 缺失"; fi)
- 文件大小限制: $(if find public -type f -size +100M 2>/dev/null | grep -q "."; then echo "❌ 有超大文件"; else echo "✅ 正常"; fi)
- 协议相对链接: $(if grep -r "href=\"//" public/ 2>/dev/null | grep -q "."; then echo "❌ 存在问题"; else echo "✅ 正常"; fi)

## 4. 优化建议
$(generate_suggestions)

## 5. 后续步骤
1. 检查报告中的问题项
2. 运行 \`./bin/deploy.sh\` 重新部署
3. 验证部署后的网站
4. 定期运行此验证脚本

---

*报告由Hexo博客优化工具生成*
EOF

    echo -e "  ${GREEN}✓ 报告已生成: $report_file${NC}"
    echo ""
    cat "$report_file" | grep -E "(✅|❌|⚠)" | while read -r line; do
        if [[ "$line" == *"✅"* ]]; then
            echo -e "${GREEN}$line${NC}"
        elif [[ "$line" == *"❌"* ]]; then
            echo -e "${RED}$line${NC}"
        elif [[ "$line" == *"⚠"* ]]; then
            echo -e "${YELLOW}$line${NC}"
        else
            echo "$line"
        fi
    done
}

# 生成优化建议
generate_suggestions() {
    cat << EOF
### 性能优化
1. **图片优化**: 运行 \`./bin/optimize-images.sh\` 压缩图片
2. **缓存策略**: 确保静态资源有正确的缓存头
3. **代码分割**: 考虑拆分大型JS/CSS文件

### 兼容性优化
1. **移动端适配**: 测试网站在手机上的显示效果
2. **浏览器兼容**: 检查主要浏览器的兼容性
3. **SEO优化**: 确保关键页面有正确的元标签

### 监控维护
1. **定期验证**: 每月运行一次此验证脚本
2. **性能监控**: 使用Google PageSpeed Insights定期测试
3. **错误监控**: 设置网站错误监控
EOF
}

# 主函数
main() {
    show_header
    check_dependencies

    # 检查是否有参数
    if [ "$1" = "--local" ]; then
        check_local_server || exit 1
    fi

    check_accessibility || {
        echo -e "${RED}网站访问检查失败，停止后续检查${NC}"
        exit 1
    }

    check_performance
    check_compatibility
    generate_report

    echo ""
    echo -e "${GREEN}验证完成!${NC}"
    echo -e "请查看生成的报告文件获取详细结果。"
    echo -e "重新部署命令: ./bin/deploy.sh"
}

# 执行
main "$@"