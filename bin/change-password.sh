#!/bin/bash
# hexo-admin 密码修改工具

set -e

echo "🔐 Hexo Admin 密码修改工具"
echo "=========================="

if [ $# -eq 0 ]; then
    echo "请输入新密码："
    read -s NEW_PASSWORD
    echo "请确认新密码："
    read -s CONFIRM_PASSWORD

    if [ "$NEW_PASSWORD" != "$CONFIRM_PASSWORD" ]; then
        echo "❌ 密码不匹配！"
        exit 1
    fi
else
    NEW_PASSWORD="$1"
fi

# 生成密码哈希
echo "生成密码哈希..."
PASSWORD_HASH=$(node -e "const bcrypt = require('bcrypt-nodejs'); const salt = bcrypt.genSaltSync(10); console.log(bcrypt.hashSync('$NEW_PASSWORD', salt));")

if [ $? -ne 0 ] || [ -z "$PASSWORD_HASH" ]; then
    echo "❌ 哈希生成失败！请检查 bcrypt-nodejs 是否安装。"
    exit 1
fi

# 转义哈希值中的 $ 符号，防止 shell 解释
ESCAPED_HASH=$(echo "$PASSWORD_HASH" | sed 's/\$/\\\$/g')

# 更新配置文件
echo "更新配置文件..."
CONFIG_FILE="_config.yml"
TEMP_FILE="${CONFIG_FILE}.tmp"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ 找不到配置文件：$CONFIG_FILE"
    exit 1
fi

# 查找并替换 password_hash（使用转义后的哈希值，防止 $ 符号被 shell 解释）
sed "s|password_hash:.*|password_hash: '$ESCAPED_HASH'|" "$CONFIG_FILE" > "$TEMP_FILE"

if [ $? -ne 0 ]; then
    echo "❌ 配置文件更新失败！"
    rm -f "$TEMP_FILE"
    exit 1
fi

mv "$TEMP_FILE" "$CONFIG_FILE"

echo "✅ 密码已更新！"
echo ""
echo "📋 新密码信息："
echo "   用户名：admin"
echo "   新密码：$NEW_PASSWORD"
echo ""
echo "⚠️  重要提示："
echo "1. 请妥善保存新密码"
echo "2. 重启 hexo-admin 服务使更改生效"
echo "3. 删除此脚本中的密码历史记录（如果使用了命令行参数）"
echo ""
echo "🔄 重启服务命令："
echo "   pkill -f 'hexo server'  # 停止旧服务"
echo "   ./bin/start-admin.sh    # 启动新服务"