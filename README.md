# 木与宁的小站

[![Hexo](https://img.shields.io/badge/Hexo-8.1.0-blue)](https://hexo.io/)
[![NexT](https://img.shields.io/badge/NexT-Gemini-orange)](https://theme-next.js.org/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

基于 Hexo + NexT 主题构建的个人技术博客，部署在 GitHub Pages。

**在线访问**: https://zouwenxiang.cn

---

## 技术栈

- **静态站点生成器**: [Hexo](https://hexo.io/) 8.1.0
- **主题**: [NexT](https://theme-next.js.org/) Gemini  scheme
- **评论系统**: [Giscus](https://giscus.app/) (基于 GitHub Discussions)
- **搜索**: 本地搜索 (hexo-generator-searchdb)
- **部署**: GitHub Pages + GitHub Actions
- **图床**: GitHub 仓库 (hexo-asset-image)

---

## 功能特性

### 核心功能
- ✍️ **文章发布**: 支持 Markdown，自动生成 Front Matter
- 🔍 **全站搜索**: 快速搜索文章内容，支持中文
- 💬 **评论系统**: 基于 Giscus，无需数据库，访客可直接评论
- 🏷️ **标签分类**: 自动标签云和分类归档
- 📱 **响应式设计**: 完美适配移动端和桌面端

### 用户体验
- ⚡ **性能优化**: 图片懒加载、CSS/JS 压缩、缓存策略
- 🌓 **暗色模式**: 自动适配系统主题
- 📖 **阅读进度条**: 顶部进度条显示阅读进度
- ⬆️ **返回顶部**: 平滑滚动返回顶部
- 📋 **代码复制**: 一键复制代码块

### 便捷工具
- 🖼️ **图片处理**: 自动压缩和优化
- 🤖 **自动部署**: 一键发布到 GitHub Pages
- 📝 **写作助手**: 快速创建文章脚本
- 📊 **字数统计**: 自动统计文章字数和阅读时间

---

## 目录结构

```
Blog/
├── _config.yml                 # Hexo 主配置文件
├── _config.landscape.yml       # Landscape 主题配置（备用）
├── package.json                # 项目依赖
├── CNAME                       # 自定义域名配置
├── scaffolds/                  # 文章模板
│   ├── post.md                 # 文章模板
│   ├── draft.md                # 草稿模板
│   └── page.md                 # 页面模板
├── source/                     # 源文件目录
│   ├── _posts/                 # 博客文章
│   ├── _drafts/                # 草稿文章
│   ├── _data/                  # 自定义数据文件
│   │   ├── body-end.swig      # 尾部脚本（评论、返回顶部等）
│   │   ├── head.swig          # 头部扩展
│   │   └── styles.styl        # 自定义样式
│   ├── images/                 # 全局图片资源
│   ├── tags/                   # 标签页面
│   └── categories/             # 分类页面
├── themes/                     # 主题目录
│   └── next/                   # NexT 主题
├── bin/                        # 自定义脚本
│   ├── deploy.sh              # 部署脚本
│   ├── new-post.sh            # 创建文章
│   ├── write-flow.sh          # 完整写作流程
│   ├── optimize-images.sh     # 图片优化
│   └── configure-giscus.sh    # 评论配置
└── docs/                       # 项目文档
    ├── quick-start-guide.md   # 快速开始
    ├── deploy-guide.md        # 部署指南
    └── giscus-config-guide.md # 评论配置指南
```

---

## 快速开始

### 环境要求

- Node.js >= 18.0.0
- npm >= 8.0.0
- Git

### 安装依赖

```bash
# 克隆仓库
git clone git@github.com:hongmuyu/muyblog.git
cd muyblog

# 安装依赖
npm install
```

### 本地预览

```bash
# 启动本地服务器
hexo server

# 或
npm run dev

# 访问 http://localhost:4000
```

---

## 常用命令

```bash
# 创建新文章
npm run new "文章标题" 标签1 标签2

# 或使用脚本
./bin/new-post.sh "文章标题"

# 完整写作流程（推荐）
./bin/write-flow.sh

# 生成静态文件
hexo generate

# 清理缓存
hexo clean

# 部署到 GitHub Pages
npm run deploy

# 启动 hexo-admin 后台
npm run admin
```

---

## 写作指南

### 创建文章

```bash
# 方式1：使用 npm 脚本
npm run new "我的新文章" Hexo 教程

# 方式2：使用 hexo 命令
hexo new post "我的新文章"

# 方式3：使用增强脚本（自动添加 Front Matter）
./bin/new-post-enhanced.sh "我的新文章"
```

### 文章 Front Matter 模板

```markdown
---
title: 文章标题
date: 2024-01-01 10:00:00
updated: 2024-01-01 10:00:00
categories:
  - 技术
  - 教程
tags:
  - Hexo
  - NexT
  - 博客
toc: true          # 显示目录
mathjax: false     # 数学公式
comments: true     # 启用评论
description: 文章描述
keywords: 关键词1, 关键词2
---

摘要内容...

<!-- more -->

正文内容...
```

### 图片使用

#### 方式1：文章资源文件夹（推荐）

1. 将图片放入 `source/_posts/文章标题/` 目录
2. 在文章中引用：`![描述](图片名.png)`

#### 方式2：全局图片

1. 将图片放入 `source/images/` 目录
2. 在文章中引用：`![描述](/images/图片名.png)`

#### 图片压缩

```bash
# 优化所有图片
./bin/optimize-images.sh source/images/

# 处理文章图片
./bin/process-images.sh
```

---

## 部署

### 自动部署（推荐）

```bash
# 一键部署
./bin/deploy.sh
```

### 手动部署

```bash
# 生成静态文件
hexo clean && hexo generate

# 部署
hexo deploy
```

### GitHub Actions 自动部署

项目已配置 `.github/workflows/pages.yml`，推送代码到 main 分支会自动触发部署。

---

## 配置说明

### 站点配置 (`_config.yml`)

关键配置项：

```yaml
# 站点信息
title: 木与宁的小站
description: 选择有时候比努力更重要
author: 木与宁
language: zh-CN

# URL
url: https://zouwenxiang.cn

# 部署配置
deploy:
  type: git
  repo: git@github.com:hongmuyu/muyblog.git
  branch: main
```

### 主题配置 (`themes/next/_config.yml`)

```yaml
# 菜单配置
menu:
  home: / || home
  archives: /archives/ || archive
  categories: /categories/ || th
  tags: /tags/ || tags

# 评论配置（Giscus）
comments:
  style: tabs
  active: giscus

# 搜索配置
local_search:
  enable: true
  trigger: auto
  top_n_per_article: 5
```

### 评论系统配置

1. 访问 [Giscus](https://giscus.app)
2. 配置仓库：`hongmuyu/muyblog`
3. 获取 `repo-id` 和 `category-id`
4. 更新 `source/_data/body-end.swig` 中的配置

或使用脚本：

```bash
./bin/configure-giscus.sh
```

---

## 性能优化

- **图片懒加载**: 启用原生懒加载 + Lozad.js
- **CSS/JS 压缩**: 使用 clean-css 和 terser
- **HTML 压缩**: 移除注释和空白
- **缓存策略**: 内存缓存，30分钟检查间隔
- **预加载**: 关键资源预加载
- **DNS 预解析**: 第三方域名预解析

---

## 浏览器支持

- Chrome / Edge 最新版
- Firefox 最新版
- Safari 最新版
- 移动端浏览器

---

## 更新日志

### 2024-XX-XX
- 升级 Hexo 到 8.1.0
- 升级 NexT 主题
- 添加 Giscus 评论系统
- 优化移动端体验

---

## 许可证

[MIT](LICENSE)

---

## 致谢

- [Hexo](https://hexo.io/)
- [NexT](https://theme-next.js.org/)
- [Giscus](https://giscus.app/)

---

**Enjoy writing! ✍️**
