#!/bin/bash
# hexo-admin 配置验证脚本

set -e

echo "🔍 Hexo Admin 配置验证"
echo "====================="

ERRORS=0
WARNINGS=0

# 检查关键文件
echo ""
echo "📁 文件检查:"

# 1. 检查配置文件
if [ -f "_config.yml" ]; then
    echo "  ✅ _config.yml 存在"

    # 检查admin配置
    if grep -q "^admin:" _config.yml; then
        echo "  ✅ admin 配置节存在"

        # 检查用户名
        if grep -q "username:" _config.yml; then
            USERNAME=$(grep "username:" _config.yml | head -1 | awk '{print $2}')
            echo "  ✅ 用户名: $USERNAME"
        else
            echo "  ⚠️  未找到 username 配置"
            WARNINGS=$((WARNINGS+1))
        fi

        # 检查密码哈希
        if grep -q "password_hash:" _config.yml; then
            echo "  ✅ password_hash 存在"

            # 检查是否为默认密码
            DEFAULT_HASH="\$2a\$10\$h2ctho3y8PKpp4czX2Vf3.dn3Ot7a/yrog6VYIymgvEOYPvlT6PJ6"
            CURRENT_HASH=$(grep "password_hash:" _config.yml | head -1 | awk '{print $2}')
            if [ "$CURRENT_HASH" = "$DEFAULT_HASH" ]; then
                echo "  ⚠️  警告：使用默认密码！请立即修改"
                echo "      运行: ./bin/change-password.sh"
                WARNINGS=$((WARNINGS+1))
            fi
        else
            echo "  ❌ 未找到 password_hash 配置"
            ERRORS=$((ERRORS+1))
        fi

        # 检查deployCommand
        if grep -q "deployCommand:" _config.yml; then
            DEPLOY_CMD=$(grep "deployCommand:" _config.yml | head -1 | sed 's/deployCommand://' | sed "s/^[[:space:]]*//" | sed "s/'//g" | sed 's/"//g')
            echo "  ✅ deployCommand: $DEPLOY_CMD"

            if [ -f "$DEPLOY_CMD" ]; then
                echo "  ✅ 部署脚本存在且可执行"
            else
                echo "  ⚠️  警告：部署脚本不存在: $DEPLOY_CMD"
                WARNINGS=$((WARNINGS+1))
            fi
        else
            echo "  ⚠️  未找到 deployCommand 配置"
            WARNINGS=$((WARNINGS+1))
        fi
    else
        echo "  ❌ 未找到 admin 配置节"
        ERRORS=$((ERRORS+1))
    fi
else
    echo "  ❌ _config.yml 不存在"
    ERRORS=$((ERRORS+1))
fi

# 2. 检查package.json中的hexo-admin依赖
if [ -f "package.json" ]; then
    if grep -q "\"hexo-admin\"" package.json; then
        echo "  ✅ hexo-admin 在 package.json 中"
    else
        echo "  ❌ 未在 package.json 中找到 hexo-admin"
        ERRORS=$((ERRORS+1))
    fi
fi

# 3. 检查scaffolds/post.md模板
if [ -f "scaffolds/post.md" ]; then
    echo "  ✅ 文章模板存在"

    # 检查模板内容
    TEMPLATE_LINES=$(wc -l < scaffolds/post.md)
    if [ "$TEMPLATE_LINES" -lt 5 ]; then
        echo "  ⚠️  警告：文章模板可能过于简单"
        WARNINGS=$((WARNINGS+1))
    fi
else
    echo "  ⚠️  警告：文章模板不存在"
    WARNINGS=$((WARNINGS+1))
fi

# 4. 检查图片上传目录
if [ -d "source/images/uploads" ]; then
    echo "  ✅ 图片上传目录存在"
else
    echo "  ⚠️  警告：图片上传目录不存在，创建中..."
    mkdir -p source/images/uploads 2>/dev/null || true
    if [ -d "source/images/uploads" ]; then
        echo "  ✅ 图片上传目录已创建"
    else
        echo "  ⚠️  无法创建图片上传目录"
        WARNINGS=$((WARNINGS+1))
    fi
fi

# 5. 检查脚本文件
echo ""
echo "📜 脚本检查:"

SCRIPTS=("bin/start-admin.sh" "bin/deploy.sh" "bin/change-password.sh" "bin/new-post.sh" "bin/delete-post.sh")
for SCRIPT in "${SCRIPTS[@]}"; do
    if [ -f "$SCRIPT" ]; then
        if [ -x "$SCRIPT" ]; then
            echo "  ✅ $SCRIPT (可执行)"
        else
            echo "  ⚠️  $SCRIPT 存在但不可执行"
            WARNINGS=$((WARNINGS+1))
        fi
    else
        echo "  ⚠️  $SCRIPT 不存在"
        WARNINGS=$((WARNINGS+1))
    fi
done

# 6. 检查node_modules中的hexo-admin
if [ -d "node_modules/hexo-admin" ]; then
    echo "  ✅ hexo-admin 已安装"
else
    echo "  ❌ hexo-admin 未安装，请运行: npm install"
    ERRORS=$((ERRORS+1))
fi

echo ""
echo "📊 检查结果汇总:"
echo "   错误: $ERRORS"
echo "   警告: $WARNINGS"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "🎉 所有检查通过！"
    echo ""
    echo "🚀 启动命令:"
    echo "   ./bin/start-admin.sh"
    echo ""
    echo "📖 使用指南:"
    echo "   访问: http://localhost:4000/admin/"
    echo "   用户名: $(grep "username:" _config.yml | head -1 | awk '{print $2}' 2>/dev/null || echo 'admin')"
    echo "   密码: 您设置的密码"
elif [ $ERRORS -eq 0 ]; then
    echo "⚠️  存在警告，但可以继续使用。"
    echo ""
    echo "建议修复警告后再使用。"
else
    echo "❌ 存在错误，请修复后再使用。"
    exit 1
fi

echo ""
echo "🔧 其他工具:"
echo "   - 修改密码: ./bin/change-password.sh"
echo "   - 创建文章: ./bin/new-post.sh \"文章标题\""
echo "   - 删除文章: ./bin/delete-post.sh --interactive"
echo "   - 部署网站: ./bin/deploy.sh"