#!/bin/bash
# 启动 hexo-admin 管理界面
# 使用方法: ./bin/start-admin.sh [端口号]
# 示例: ./bin/start-admin.sh 4001

# 默认端口
DEFAULT_PORT=4000

# 如果提供了端口参数，则使用指定的端口
if [ $# -eq 1 ] && [[ "$1" =~ ^[0-9]+$ ]]; then
    PORT="$1"
else
    PORT="$DEFAULT_PORT"
fi

# 检查端口是否被占用
check_port() {
    # 优先使用 ss 命令，不需要特权
    if command -v ss &> /dev/null; then
        if ss -tulpn 2>/dev/null | grep -q ":$PORT\b"; then
            echo "❌ 端口 $PORT 已被占用"
            echo "   请使用其他端口: ./bin/start-admin.sh 4001"
            return 1
        fi
    elif command -v netstat &> /dev/null; then
        if netstat -tulpn 2>/dev/null | grep -q ":$PORT\b"; then
            echo "❌ 端口 $PORT 已被占用"
            echo "   请使用其他端口: ./bin/start-admin.sh 4001"
            return 1
        fi
    elif command -v lsof &> /dev/null; then
        # lsof 可能需要特权，所以放在最后
        if sudo lsof -i :"$PORT" &> /dev/null; then
            echo "❌ 端口 $PORT 已被占用"
            echo "   请使用其他端口: ./bin/start-admin.sh 4001"
            echo "   或停止占用进程: sudo lsof -ti :$PORT | xargs kill -9"
            return 1
        elif lsof -i :"$PORT" &> /dev/null; then
            echo "❌ 端口 $PORT 已被占用"
            echo "   请使用其他端口: ./bin/start-admin.sh 4001"
            echo "   或停止占用进程: lsof -ti :$PORT | xargs kill -9"
            return 1
        fi
    else
        echo "⚠️  无法检查端口占用情况，将尝试直接启动..."
    fi
    return 0
}

# 检查端口
if ! check_port; then
    exit 1
fi

echo "🚀 启动 Hexo Admin 管理界面..."
echo "📝 访问地址: http://localhost:${PORT}/admin/"

# 从配置文件中读取用户名
USERNAME=$(grep "^  username:" _config.yml 2>/dev/null | awk '{print $2}' | sed "s/'//g" | sed 's/"//g')
if [ -z "$USERNAME" ]; then
    USERNAME="admin"
fi

echo "🔑 用户名: $USERNAME"
echo "🔑 密码: ******** (您设置的密码)"
echo ""
echo "📌 使用端口: $PORT"
echo ""
echo "⚠️  安全提示:"
echo "1. 请勿在公共网络中使用默认密码"
echo "2. 使用完成后及时关闭服务"
echo "3. 如需修改密码，请运行: ./bin/change-password.sh"
echo ""
echo "按 Ctrl+C 停止服务"

# 启动 hexo server 并启用 admin 插件，使用指定端口
hexo server -d -p "$PORT"