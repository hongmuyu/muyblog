# 标签、分类和评论功能使用指南

## 概述

您的 Hexo 博客现已完全支持标签、分类和评论功能。所有功能都已配置完成，可直接使用。

## 功能列表

### ✅ 已实现功能

1. **标签系统**
   - 文章可添加多个标签
   - 标签页面自动生成
   - 标签云显示（可配置大小和颜色）
   - 点击标签筛选相关文章

2. **分类系统**
   - 文章可归属到多个分类
   - 分类页面自动生成
   - 分类树状结构显示
   - 点击分类查看同类别文章

3. **评论系统**
   - 基于 Giscus（GitHub Discussions）
   - 无需数据库或后端服务
   - 访客使用 GitHub 账号评论
   - 支持 Markdown 和表情符号
   - 评论存储在 GitHub Discussions 中

4. **管理界面**
   - hexo-admin 网页管理界面
   - 可视化的文章创建、编辑、删除
   - 图片拖拽上传
   - 一键部署到 GitHub Pages

## 快速开始

### 1. 创建带标签和分类的文章

#### 方法一：使用网页界面（推荐）
```bash
# 启动管理界面
./bin/start-admin.sh

# 访问 http://localhost:4000/admin/
# 使用用户名 admin 和您设置的密码登录
```

在管理界面中：
1. 点击 "Posts" → "New Post"
2. 填写文章内容
3. 在右侧边栏添加标签和分类
4. 点击 "Save & Publish" 发布

#### 方法二：使用命令行脚本
```bash
# 创建带标签的文章
./bin/new-post.sh "文章标题" 标签1 标签2 标签3
```

#### 方法三：手动编辑 Markdown 文件
```markdown
---
title: 文章标题
date: 2026-04-18 22:30:00
tags:
  - 标签1
  - 标签2
  - 标签3
categories:
  - 技术
  - 教程
comments: true
---
```

### 2. 配置 Giscus 评论系统

如果您尚未配置 Giscus，请运行配置脚本：

```bash
# 运行 Giscus 配置向导
./bin/configure-giscus.sh
```

按照提示输入从 https://giscus.app 获取的配置信息。

或手动配置：
1. 访问 https://giscus.app 获取配置
2. 更新 `source/_data/body-end.swig` 中的配置
3. 重新生成博客：`hexo clean && hexo generate`

### 3. 管理标签和分类

#### 查看所有标签
- 访问：https://zouwenxiang.cn/tags/
- 或本地：http://localhost:4000/tags/

#### 查看所有分类
- 访问：https://zouwenxiang.cn/categories/
- 或本地：http://localhost:4000/categories/

#### 删除文章（连带标签和分类）
```bash
# 交互式删除
./bin/delete-post.sh --interactive

# 按文件名删除
./bin/delete-post.sh "文件名.md"

# 按标题删除
./bin/delete-post.sh "文章标题"
```

## 详细配置

### 标签配置

#### 标签页面
- 位置：`source/tags/index.md`
- 类型：`type: "tags"`
- 禁用评论：`comments: false`

#### 标签显示设置
在 `themes/next/_config.yml` 中：
```yaml
# 使用图标代替 # 符号
tag_icon: true

# 标签云设置
tagcloud:
  min: 12    # 最小字体大小（像素）
  max: 30    # 最大字体大小（像素）
  start: "#ccc"  # 起始颜色
  end: "#111"    # 结束颜色
  amount: 200    # 最大标签数量
```

### 分类配置

#### 分类页面
- 位置：`source/categories/index.md`
- 类型：`type: "categories"`
- 禁用评论：`comments: false`

#### 分类显示
- 支持多级分类（使用 `/` 分隔）
- 示例：
  ```yaml
  categories:
    - 技术/编程
    - 技术/前端
    - 生活/随笔
  ```

### 评论配置

#### Giscus 设置
配置文件：`source/_data/body-end.swig`

关键配置项：
- `data-repo`: GitHub 仓库（如：`hongmuyu/ashynesses.github.io`）
- `data-repo-id`: 仓库 ID（从 giscus.app 获取）
- `data-category`: 讨论分类（如：`Announcements`）
- `data-category-id`: 分类 ID（从 giscus.app 获取）
- `data-lang`: `zh-CN`（中文界面）
- `data-theme`: `preferred_color_scheme`（跟随系统主题）

#### 启用/禁用评论
在文章 Front Matter 中：
```yaml
comments: true   # 启用评论（默认）
comments: false  # 禁用评论
```

## 最佳实践

### 标签使用建议
1. **数量适度**：每篇文章 3-5 个标签
2. **保持一致性**：使用相似的标签命名
3. **避免重复**：检查现有标签后再创建新标签
4. **使用特定标签**：避免过于宽泛的标签

### 分类组织建议
1. **层级清晰**：使用层级分类组织内容
2. **数量合理**：每篇文章 1-2 个主分类
3. **保持稳定**：避免频繁更改分类结构
4. **专题分类**：为系列文章创建专题分类

### 评论管理建议
1. **及时回复**：定期查看并回复评论
2. **设置通知**：在 GitHub 设置中启用评论通知
3. **管理不当评论**：在 GitHub Discussions 中删除或锁定
4. **鼓励讨论**：在文章中提出引导性问题

## 故障排除

### 标签不显示
1. 检查文章 Front Matter 中是否有 `tags:` 字段
2. 确保标签格式正确：
   ```yaml
   tags:
     - 标签1
     - 标签2
   ```
3. 重新生成博客：`hexo clean && hexo generate`

### 分类不显示
1. 检查文章 Front Matter 中是否有 `categories:` 字段
2. 确保分类格式正确：
   ```yaml
   categories:
     - 技术
     - 编程
   ```
3. 检查分类页面是否存在：`source/categories/index.md`

### 评论框不显示
1. 检查文章 Front Matter 中 `comments: true`
2. 验证 Giscus 配置是否正确
3. 检查 GitHub Discussions 是否已启用
4. 检查 Giscus App 是否已安装并授权

### 标签/分类页面无法访问
1. 检查页面文件是否存在
2. 检查 `_config.yml` 中的目录配置：
   ```yaml
   tag_dir: tags
   category_dir: categories
   ```
3. 重新生成博客：`hexo clean && hexo generate`

## 高级功能

### 自定义标签样式
编辑 `source/_data/styles.styl`：
```stylus
// 标签样式
.tag-cloud {
  a {
    margin: 5px;
    padding: 3px 8px;
    border-radius: 12px;
    transition: all 0.3s;

    &:hover {
      background-color: #3498db;
      color: white;
      text-decoration: none;
    }
  }
}
```

### 自定义分类样式
```stylus
// 分类样式
.category-list {
  .category-list-item {
    margin-bottom: 10px;

    .category-list-count {
      margin-left: 5px;
      color: #999;
      font-size: 0.9em;
    }
  }
}
```

### 评论框样式调整
在 `source/_data/body-end.swig` 中：
```html
<style>
.giscus, .giscus-frame {
  border-radius: 10px;
  margin: 2rem 0;
  box-shadow: 0 2px 15px rgba(0,0,0,0.1);
  border: 1px solid #eee;
}
</style>
```

## 维护建议

### 定期检查
1. **每月**：检查标签使用情况，合并相似标签
2. **每季度**：整理分类结构，优化层级
3. **半年**：审核评论设置，更新 Giscus 配置

### 备份策略
```bash
# 备份文章和配置
tar -czf backup-$(date +%Y%m%d).tar.gz source/_posts/ _config.yml

# 推送到 GitHub
git add backup-*.tar.gz
git commit -m "备份 $(date +%Y%m%d)"
git push
```

### 更新提醒
1. **Hexo 更新**：`npm update hexo`
2. **Next 主题更新**：`cd themes/next && git pull`
3. **插件更新**：`npm update`

## 获取帮助

- **官方文档**：
  - Hexo: https://hexo.io/docs/
  - Next 主题: https://theme-next.js.org/
  - Giscus: https://giscus.app/

- **问题反馈**：
  - GitHub Issues: https://github.com/hongmuyu/ashynesses.github.io/issues

- **本地测试**：
  ```bash
  # 启动本地服务器
  hexo server

  # 访问 http://localhost:4000
  # 测试所有功能
  ```

## 总结

您的博客现在具备完整的标签、分类和评论功能：

1. **创作体验**：通过网页界面轻松创建和管理文章
2. **内容组织**：使用标签和分类有效组织内容
3. **读者互动**：通过 Giscus 评论系统与读者交流
4. **维护简便**：所有数据存储在 GitHub，无需额外服务

开始创作吧！🎉