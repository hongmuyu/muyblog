# Hexo Admin 快速入门指南

## 概述

本博客已配置完整的网页端管理界面（hexo-admin），您可以通过浏览器创建、编辑、删除文章，并一键部署到 GitHub Pages。

## 快速开始

### 1. 启动管理界面
```bash
# 进入博客目录
cd /home/abc/Blog

# 启动服务
./bin/start-admin.sh
```

### 2. 访问管理界面
- 地址：http://localhost:4000/admin/
- 用户名：`admin`
- 密码：`admin123`（**请立即修改！**）

### 3. 修改默认密码（重要！）
```bash
# 运行密码修改工具
./bin/change-password.sh
```

## 核心功能

### 📝 网页写博客
1. 登录管理界面后，点击左侧菜单的 "Posts" → "New Post"
2. 填写文章标题、内容、标签等
3. 使用富文本编辑器或 Markdown 编辑器编写
4. 点击 "Save" 保存草稿，或 "Save & Publish" 直接发布

### 🖼️ 图片上传
1. 在文章编辑器中点击图片上传按钮
2. 选择本地图片文件
3. 图片会自动保存到 `source/images/uploads/` 目录
4. 上传后会自动生成 Markdown 图片链接

### 🗑️ 删除博客文章
**方法一：在管理界面删除**
1. 进入 "Posts" 列表
2. 找到要删除的文章
3. 点击右侧的 "Delete" 按钮
4. 确认删除

**方法二：使用命令行脚本**
```bash
# 列出所有文章
./bin/delete-post.sh --list

# 交互式删除（推荐）
./bin/delete-post.sh --interactive

# 通过文件名删除
./bin/delete-post.sh "hello-world.md"

# 通过标题删除
./bin/delete-post.sh "Hello World"
```

### 🚀 一键部署
1. 在管理界面点击右上角的 "Deploy" 按钮
2. 系统会自动执行 `./bin/deploy.sh` 脚本
3. 等待部署完成（约1-2分钟）
4. 访问 https://zouwenxiang.cn 查看更新

## 命令行工具（备用方案）

### 创建文章
```bash
# 创建新文章（带自动标签）
./bin/new-post.sh "文章标题" 标签1 标签2

# 示例
./bin/new-post.sh "Hexo博客优化指南" Hexo 博客 优化
```

### 删除文章
```bash
# 交互式删除
./bin/delete-post.sh --interactive
```

### 部署网站
```bash
# 手动部署
./bin/deploy.sh
```

### 修改密码
```bash
# 修改 hexo-admin 密码
./bin/change-password.sh
```

### 验证配置
```bash
# 检查所有配置是否正确
./bin/verify-admin.sh
```

## 工作流程示例

### 日常写作流程
```bash
# 1. 启动管理界面
./bin/start-admin.sh

# 2. 浏览器访问 http://localhost:4000/admin/
# 3. 创建/编辑文章，上传图片
# 4. 点击 "Deploy" 发布
# 5. 访问 https://zouwenxiang.cn 验证
```

### 批量操作流程
```bash
# 1. 创建多篇文章
./bin/new-post.sh "文章1" 技术 教程
./bin/new-post.sh "文章2" 生活 随笔

# 2. 本地预览
hexo server

# 3. 部署发布
./bin/deploy.sh
```

## 高级功能

### 远程访问
如果您需要在外部网络访问管理界面，请参考：
- `docs/web-publishing-guide.md` 中的远程访问方案
- 推荐使用云服务器或内网穿透工具

### 自定义配置
- 文章模板：`scaffolds/post.md`
- 部署脚本：`bin/deploy.sh`
- 配置文件：`_config.yml` 中的 `admin:` 部分

### 故障排除
1. **无法访问管理界面**
   - 检查端口 4000 是否被占用
   - 运行 `./bin/verify-admin.sh` 检查配置

2. **部署失败**
   - 检查 GitHub SSH 密钥配置
   - 查看 `docs/deploy-guide.md`

3. **图片不显示**
   - 检查图片路径是否正确
   - 确保已启用 `post_asset_folder: true`

## 安全提醒

1. **立即修改默认密码**
   ```bash
   ./bin/change-password.sh
   ```

2. **仅在受信任的网络中使用**
   - 不要在生产环境中使用默认密码
   - 考虑配置防火墙或 IP 白名单

3. **定期备份**
   ```bash
   # 备份文章
   tar -czf backup-$(date +%Y%m%d).tar.gz source/_posts/
   ```

## 获取帮助

- 详细文档：查看 `docs/` 目录
- Hexo Admin 官方文档：https://github.com/jaredwong/hexo-admin
- 问题反馈：创建 GitHub Issue

---

**提示**：所有脚本都在 `bin/` 目录下，使用前请确保已添加执行权限：
```bash
chmod +x bin/*.sh
```