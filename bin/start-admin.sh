#!/bin/bash
# 启动 hexo-admin 管理界面
# 访问地址: http://localhost:4000/admin/
# 默认用户名: admin
# 默认密码: admin123

echo "🚀 启动 Hexo Admin 管理界面..."
echo "📝 访问地址: http://localhost:4000/admin/"
echo "🔑 用户名: admin"
echo "🔑 密码: admin123"
echo ""
echo "⚠️  安全提示:"
echo "1. 请及时修改默认密码"
echo "2. 仅在受信任的网络环境中使用"
echo "3. 使用完成后及时关闭服务"
echo ""
echo "按 Ctrl+C 停止服务"

# 启动 hexo server 并启用 admin 插件
hexo server -d