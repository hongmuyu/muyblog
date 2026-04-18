# 网页端发布指南

## 方案概述

已为您配置 **hexo-admin** 插件，这是一个完整的网页端博客管理界面。您可以通过浏览器访问管理界面，直接创建、编辑、发布文章，无需使用命令行工具。

## 快速开始

### 1. 本地启动管理界面
```bash
# 方法一：使用启动脚本
./bin/start-admin.sh

# 方法二：手动启动
hexo server -d
```

### 2. 访问管理界面
- 地址：http://localhost:4000/admin/
- 用户名：`admin`
- 密码：`admin123`（请务必修改！）

### 3. 基本功能
- **文章管理**：创建、编辑、删除文章
- **草稿箱**：保存未完成的文章
- **页面管理**：管理页面（关于、标签等）
- **一键部署**：点击按钮自动部署到 GitHub Pages
- **文件管理**：上传图片和其他文件

## 远程访问方案

### 方案一：云服务器部署（推荐）

#### 1. 购买云服务器
推荐服务商：
- **腾讯云**：轻量应用服务器
- **阿里云**：ECS
- **华为云**：弹性云服务器
- **Vultr/DigitalOcean**：国际服务商

配置建议：
- CPU：1核
- 内存：1GB
- 系统：Ubuntu 22.04 LTS
- 带宽：1Mbps 以上

#### 2. 部署 Hexo + hexo-admin
```bash
# 在服务器上执行
git clone git@github.com:hongmuyu/ashynesses.github.io.git blog
cd blog

# 安装依赖
npm install

# 修改配置（使用更强的密码）
# 编辑 _config.yml 中的 admin 配置

# 使用 PM2 保持进程运行
npm install -g pm2
pm2 start "hexo server -d" --name "hexo-admin"
pm2 save
pm2 startup

# 配置 Nginx 反向代理（可选）
sudo apt install nginx
# 配置 /etc/nginx/sites-available/hexo-admin
```

#### 3. 配置域名和 HTTPS
```bash
# 使用 Let's Encrypt 免费 SSL 证书
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d admin.yourdomain.com
```

### 方案二：内网穿透工具

#### 1. ngrok（最简单）
```bash
# 安装 ngrok（需要注册账号）
# 下载地址：https://ngrok.com/download

# 启动 hexo-admin
./bin/start-admin.sh

# 在另一个终端执行
ngrok http 4000
```

#### 2. frp（免费开源）
```bash
# 服务端（需要一台有公网 IP 的服务器）
wget https://github.com/fatedier/frp/releases/download/v0.58.0/frp_0.58.0_linux_amd64.tar.gz
tar -zxvf frp_0.58.0_linux_amd64.tar.gz
cd frp_0.58.0_linux_amd64

# 配置 frps.ini
./frps -c frps.ini

# 客户端（本地）
./frpc -c frpc.ini
```

#### 3. Cloudflare Tunnel（免费）
```bash
# 安装 cloudflared
# 参考：https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/tunnel-guide/
cloudflared tunnel --url http://localhost:4000
```

### 方案三：GitHub Codespaces（开发环境）

1. 访问 https://github.com/codespaces
2. 为您的仓库创建 Codespace
3. 在终端中启动 hexo-admin：
   ```bash
   hexo server -d -p 8080
   ```
4. Codespaces 会自动提供公共访问 URL

### 方案四：GitHub Web Editor（无需额外服务）

1. 访问您的 GitHub 仓库：https://github.com/hongmuyu/ashynesses.github.io
2. 导航到 `source/_posts/` 目录
3. 点击 "Add file" → "Create new file"
4. 按 `scaffolds/post.md` 模板编写文章
5. 提交后，GitHub Actions 会自动构建和部署

## 安全配置

### 1. 修改默认密码
```bash
# 生成新密码的哈希值
node -e "console.log(require('bcryptjs').hashSync('你的新密码', 10))"

# 更新 _config.yml 中的 password_hash
```

### 2. 增强安全措施
```yaml
# 在 _config.yml 中添加
admin:
  # 限制访问 IP（云服务器部署时使用）
  # allow_ips:
  #   - 127.0.0.1
  #   - 192.168.1.0/24

  # 启用 HTTPS（远程访问时必需）
  # ssl: true

  # 会话超时时间（分钟）
  # session_lifetime: 60
```

### 3. 防火墙配置
```bash
# 仅允许特定端口
sudo ufw allow 4000/tcp
sudo ufw allow 22/tcp
sudo ufw enable

# 或使用云服务商的安全组规则
```

## 功能集成

### 1. 图片上传
hexo-admin 支持图片上传，上传的图片会自动保存到：
- `source/images/uploads/` 目录
- 或当前文章的资产目录（如果启用了 `post_asset_folder`）

### 2. 与现有脚本集成
hexo-admin 可以调用您现有的部署脚本：
```yaml
# _config.yml 中的配置
admin:
  deployCommand: './bin/deploy.sh'
```

### 3. 自定义文章模板
hexo-admin 会自动使用 `scaffolds/post.md` 作为新文章模板。

### 4. 文章删除功能
hexo-admin 内置了文章删除功能，您也可以在命令行使用删除脚本：

```bash
# 列出所有文章
./bin/delete-post.sh --list

# 交互式删除
./bin/delete-post.sh --interactive

# 通过文件名删除
./bin/delete-post.sh "hello-world.md"

# 通过标题删除（模糊匹配）
./bin/delete-post.sh "Hello World"
```

删除文章后，需要重新部署才能从网站上移除：
```bash
./bin/deploy.sh
```

## 故障排除

### 问题1：无法访问管理界面
```bash
# 检查服务是否启动
netstat -tulpn | grep 4000

# 检查防火墙
sudo ufw status

# 检查 hexo 日志
hexo server -d --debug
```

### 问题2：部署失败
```bash
# 检查部署配置
cat _config.yml | grep -A5 "deploy:"

# 手动测试部署脚本
./bin/deploy.sh
```

### 问题3：图片上传失败
```bash
# 检查目录权限
ls -la source/images/

# 检查磁盘空间
df -h
```

## 最佳实践

### 1. 定期备份
```bash
# 备份文章和配置
tar -czf backup-$(date +%Y%m%d).tar.gz source/ _config.yml

# 推送到 GitHub
git add backup-*.tar.gz
git commit -m "备份 $(date +%Y%m%d)"
git push
```

### 2. 监控日志
```bash
# 查看 hexo-admin 访问日志
tail -f hexo.log

# 监控错误日志
pm2 logs hexo-admin
```

### 3. 定期更新
```bash
# 更新 hexo-admin
npm update hexo-admin

# 更新所有依赖
npm update
```

## 备选方案

如果 hexo-admin 不符合您的需求，还可以考虑：

### 1. Netlify CMS
- 专业的内容管理系统
- 与 GitHub 无缝集成
- 支持协作编辑

### 2. Forestry.io
- 可视化编辑器
- 支持 Hexo Front Matter
- 免费基础套餐

### 3. 自定义前端 + GitHub API
- 完全定制化的管理界面
- 通过 GitHub API 提交内容
- 需要前端开发技能

## 联系方式

如有问题，请参考：
- Hexo Admin 官方文档：https://github.com/jaredwong/hexo-admin
- 项目文档：`docs/` 目录
- GitHub Issues：https://github.com/hongmuyu/ashynesses.github.io/issues