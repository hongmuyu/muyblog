# 主题源码本地修改记录

本博客使用 hexo-theme-next，以下文件已在本地修改，主题升级时需手动合并：

## 1. `themes/next/source/js/utils.js`
- **原因**：FontAwesome 替换为内联 SVG 后，代码复制按钮的图标切换逻辑（`className = 'fa fa-check fa-fw'`）失效。
- **改法**：
  - 第 70 行：复制按钮初始 DOM 由 `<i class="fa fa-clipboard fa-fw">` 改为 `<svg class="fa fa-clipboard fa-fw" data-icon="clipboard"><use href="#i-clipboard" xlink:href="#i-clipboard"/></svg>`。
  - 第 89-94 行（点击后）：不再重写 `className`，改为操作 `<use>` 的 `href`/`xlink:href` 属性（`#i-check` / `#i-times`），同步更新 `data-icon`。
  - 第 106-110 行（mouseleave 恢复）：同理改回 `#i-clipboard`。

## 2. `themes/next/source/js/local-search.js`
- **原因**：同上，搜索无结果图标由 JS 动态插入。
- **改法**：
  - 第 193、195、242 行：`<i class="fa fa-search fa-5x">` / `<i class="far fa-frown fa-5x">` 改为对应 `<svg><use href="#i-search/#i-frown"/></svg>`。

## 3. `themes/next/layout/_partials/head/head.swig`
- **原因**：fancybox 仅文章页加载。
- **改法**：fancybox CSS 加载条件加 `and page.layout === 'post'`。

## 4. `themes/next/layout/_scripts/vendors.swig`
- **原因**：fancybox（含 jquery）仅文章页加载。
- **改法**：fancybox + jquery 加载条件加 `and page.layout === 'post'`。

## 5. `themes/next/layout/_layout.swig`
- **原因**：head.swig 与 _scripts/index.swig 被 partial 缓存，导致按页面判断（如 fancybox 条件）取到首次渲染的值。
- **改法**：这两个 partial 的 `cache` 参数设为 `false`。

## 6. `themes/next/layout/_macro/post.swig`
- **原因**：`fa-thumb-tack` 是旧名，与 `fa-thumbtack` 为同一图标。
- **改法**：第 45 行 `fa-thumb-tack` 改为 `fa-thumbtack`。

## 7. `themes/next/layout/_partials/header/brand.swig` 与 `category.swig` / `tag.swig`
- **原因**：修复 H1 重复（非首页站点名降为 div，列表页标题升为 h1）。
- **改法**：按 `page.__index` / 页面类型区分；brand.swig 关闭 partial 缓存。

## 配套脚本
- `scripts/replace-fa.js`：构建期把 `<i class="fa...">` 替换为内联 SVG + sprite。
- `data/fa-icons.json`：48 个图标 + 3 社交图标的 SVG path 数据。
- `source/_data/styles.styl`：SVG 辅助类（fa-fw/fa-lg/fa-5x/fa-pulse）换算。
