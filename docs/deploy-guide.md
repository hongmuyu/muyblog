# 部署指南

## 自动部署脚本

已创建一键部署脚本：

```bash
# 赋予执行权限
chmod +x bin/deploy.sh

# 执行部署
./bin/deploy.sh
```

## 手动部署步骤

如果自动脚本失败，请按以下步骤手动部署：

1. **清理旧文件**
   ```bash
   hexo clean
   ```

2. **生成静态网站**
   ```bash
   hexo generate
   ```

3. **部署到 GitHub Pages**
   ```bash
   hexo deploy
   ```

## SSH密钥配置

部署需要SSH密钥认证，请确保：

1. **生成SSH密钥**（如果没有）
   ```bash
   ssh-keygen -t ed25519 -C "your-email@example.com"
   ```

2. **添加公钥到GitHub**
   - 访问：GitHub → Settings → SSH and GPG keys
   - 添加公钥：`~/.ssh/id_ed25519.pub`

3. **测试SSH连接**
   ```bash
   ssh -T git@github.com
   ```

## 故障排除

### 部署失败：认证错误
```bash
# 方案1：使用HTTPS + Token（推荐）
# 修改 _config.yml
deploy:
  repo: https://<token>@github.com/ashynesses/ashynesses.github.io.git

# 方案2：配置Git凭据
git config --global credential.helper store
```

### 部署失败：权限被拒绝
```bash
# 检查部署仓库权限
# 确保你有 ashynesses/ashynesses.github.io 仓库的写入权限
```

### 图片不显示
```bash
# 清理缓存并重新生成
hexo clean
hexo generate
hexo deploy
```

## GitHub Actions 自动部署（可选）

已在 `.github/workflows/deploy.yml` 创建自动化部署流程，每次推送到 `main` 分支时自动部署。

## 验证部署

1. 访问博客：https://zouwenxiang.cn
2. 检查功能：
   - [ ] 搜索功能正常
   - [ ] 评论系统显示（需配置Giscus）
   - [ ] 图片懒加载生效
   - [ ] 返回顶部按钮显示
   - [ ] 夜间模式切换正常

## 后续维护

### 日常更新
```bash
# 创建新文章
./bin/new-post.sh "文章标题" 标签1 标签2

# 本地预览
hexo server

# 部署发布
./bin/deploy.sh
```

### 主题更新
```bash
# 进入主题目录
cd themes/next

# 拉取最新版本
git pull origin master

# 返回项目根目录
cd ../..

# 测试更新
hexo clean && hexo server
```

### 插件更新
```bash
# 检查可用更新
npm outdated

# 更新所有插件
npm update

# 更新特定插件
npm install hexo-plugin-name@latest --save
```

## 重要提醒

1. **Giscus评论系统**：需要手动配置
   - 访问 https://giscus.app 获取配置
   - 更新 `source/_data/body-end.swig` 中的仓库信息

2. **图片上传**：需要配置 PicGo
   - 参考 `docs/upload-guide.md`

3. **定期备份**：建议每月备份一次源代码
   ```bash
   git push origin main  # 推送到GitHub
   tar -czf backup-$(date +%Y%m%d).tar.gz source/ _config.yml package.json
   ```

4. **监控**：设置 GitHub Pages 构建状态通知