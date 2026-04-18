# Giscus 评论系统配置指南

## 什么是 Giscus？

Giscus 是一个基于 GitHub Discussions 的评论系统，专为静态网站设计。它允许访客通过 GitHub 账号发表评论，无需单独的用户系统或数据库。

**优点：**
- 无需后端服务器
- 使用 GitHub 账号认证
- 评论存储在 GitHub Discussions 中
- 完全免费
- 支持 Markdown 和表情符号

## 配置步骤

### 步骤1：启用 GitHub Discussions

1. 访问您的 GitHub 仓库：https://github.com/hongmuyu/ashynesses.github.io
2. 点击 "Settings"（设置）
3. 在左侧菜单中找到 "Features"（功能）
4. 找到 "Discussions" 并勾选启用
5. 点击 "Save changes"（保存更改）

### 步骤2：安装 Giscus App

1. 访问 Giscus GitHub App 页面：https://github.com/apps/giscus
2. 点击 "Install"（安装）
3. 选择 "Only select repositories"（仅选择仓库）
4. 选择您的博客仓库：`hongmuyu/ashynesses.github.io`
5. 点击 "Install"

### 步骤3：获取 Giscus 配置

1. 访问 Giscus 配置页面：https://giscus.app
2. 按以下步骤填写：

**仓库配置：**
- Repository（仓库）：`hongmuyu/ashynesses.github.io`
- Discussion category（讨论分类）：选择 "Announcements" 或创建新分类

**页面 ↔️ discussions 映射：**
- Mapping（映射）：选择 "URL pathname"（URL路径名）
- Discussion term（讨论术语）：选择 "URL pathname"
- Enable reactions（启用反应）：✅ 勾选（推荐）

**主题和语言：**
- Theme（主题）：选择 "Preferred color scheme"（跟随系统主题）
- Language（语言）：选择 "zh-CN"（中文）

3. 点击 "Generate configuration"（生成配置）

### 步骤4：更新博客配置

复制生成的配置，更新 `source/_data/body-end.swig` 文件：

```html
<script src="https://giscus.app/client.js"
        data-repo="hongmuyu/ashynesses.github.io"
        data-repo-id="YOUR_REPO_ID"
        data-category="Announcements"
        data-category-id="YOUR_CATEGORY_ID"
        data-mapping="pathname"
        data-strict="0"
        data-reactions-enabled="1"
        data-emit-metadata="0"
        data-input-position="bottom"
        data-theme="preferred_color_scheme"
        data-lang="zh-CN"
        crossorigin="anonymous"
        async>
</script>
```

**重要：** 需要将 `YOUR_REPO_ID` 和 `YOUR_CATEGORY_ID` 替换为您从 Giscus 获取的实际 ID。

## 快速配置脚本

我们提供了一个快速配置脚本，请运行：

```bash
cd /home/abc/Blog
./bin/configure-giscus.sh
```

脚本会引导您完成配置过程。

## 验证配置

配置完成后，请验证：

1. **重新生成博客**
   ```bash
   hexo clean && hexo generate
   ```

2. **本地测试**
   ```bash
   hexo server
   ```
   访问：http://localhost:4000

3. **检查评论框**
   - 打开任意文章页面
   - 页面底部应该显示 Giscus 评论框
   - 可以尝试发表测试评论

## 故障排除

### 问题1：评论框不显示
- 检查 GitHub Discussions 是否已启用
- 检查 Giscus App 是否已安装并授权
- 检查 `body-end.swig` 中的配置是否正确

### 问题2：无法发表评论
- 确保您已登录 GitHub 账号
- 检查浏览器控制台是否有错误信息
- 尝试在其他浏览器中测试

### 问题3：配置后没有变化
- 清理缓存并重新生成
  ```bash
  hexo clean
  hexo generate
  ```

## 管理评论

### 查看评论
1. 访问您的 GitHub 仓库
2. 点击 "Discussions" 标签
3. 查看所有文章的评论讨论

### 管理评论
- 可以删除不当评论
- 可以锁定讨论
- 可以标记为已回答

### 通知设置
- 您可以在 GitHub 设置中配置评论通知
- 当有新评论时，GitHub 会发送邮件通知

## 自定义样式

如需自定义 Giscus 样式，可以修改 `source/_data/styles.styl` 文件：

```stylus
.giscus, .giscus-frame {
  border-radius: 10px;
  margin: 2rem 0;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}
```

## 备用方案

如果 Giscus 不符合需求，还可以考虑：

### 1. Utterances
- 基于 GitHub Issues
- 配置更简单
- 同样无需后端

### 2. Valine
- 基于 LeanCloud
- 支持匿名评论
- 需要注册 LeanCloud 账号

### 3. Disqus
- 最流行的评论系统
- 有免费和付费版本
- 可能需要科学上网

## 联系方式

如有问题，请参考：
- Giscus 官方文档：https://giscus.app
- GitHub Discussions 文档：https://docs.github.com/en/discussions
- Hexo Next 主题文档：https://theme-next.js.org

或创建 GitHub Issue：https://github.com/hongmuyu/ashynesses.github.io/issues