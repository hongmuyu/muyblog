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

## 8. `themes/next/source/css/_variables/base.styl`
- **原因**：B-4 字体策略——移除 Google Fonts/Lato，改用系统字体栈。注意 `font.enable: false` 只停掉 `<link>`，Lato 仍会被 `get_font_family('global')` 拼进 `font-family` 声明。
- **改法**：新增 `$font-family-system = -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "PingFang SC", "Microsoft YaHei", "Noto Sans CJK SC", sans-serif`，`$font-family-base` 改为直接使用该栈；`$font-family-chinese` 追加 `"Noto Sans CJK SC"`（供等宽字体 CJK 回退）。

## 9. `themes/next/_config.yml`
- **原因**：同上，`font.global.family: Lato` 清空（`enable: false` 保持不变）。
- **改法 2（C-1/#8）**：`back2top.sidebar: true → false`。原配置把返回顶部按钮渲染进侧栏 DOM，移动端侧栏 `display:none` 导致按钮在移动端完全不渲染；改为 false 后由 `_partials/widgets.swig` 渲染到侧栏外（`position: fixed` 悬浮），移动端可用。

## 10. 主题 D：可访问性修复（2026-11）

本轮按 axe / Lighthouse 审计结果修复，涉及主题源码如下（另有 `scripts/a11y-fixes.js` 构建期修复与 `source/_data/styles.styl` 覆盖样式，不属主题源码）：

### `themes/next/layout/archive.swig`
- **原因**：归档页无任何 h1（axe page-has-heading-one / 文档结构）。
- **改法**：`.collection-title` 由 `<div>` 改为 `<h1>`。

### `themes/next/layout/_partials/widgets.swig`
- **原因**：返回顶部按钮是纯 div，屏幕阅读器无语义；内部百分比 span 与按钮 aria-label 重复朗读。
- **改法**：`.back-to-top` 加 `role="button" tabindex="0"` 与 `aria-label="返回顶部，已滚动 0%"`（滚动时由 utils.js 同步更新）；百分比 `<span>` 加 `aria-hidden="true"`。

### `themes/next/layout/_layout.swig`
- **原因**：缺跳转主内容的 skip link；`<main>` 无 id 无法作为锚点。
- **改法**：`<body>` 起始处加 `<a class="skip-link" href="#main">跳到主内容</a>`；`<main>` 加 `id="main"`。skip-link 样式在 `source/_data/styles.styl`（`:focus` 时 `top: 0` 滑入，带 0.2s transition）。

### `themes/next/layout/_partials/head/head.swig`
- **原因**：`maximum-scale=2` 限制用户缩放（axe meta-viewport-large，WCAG 1.4.4）。
- **改法**：viewport 改为 `width=device-width, initial-scale=1`，删除 `maximum-scale=2`。

### `themes/next/layout/_scripts/vendors.swig`
- **原因**：canvas-nest 背景动画为纯装饰，屏幕阅读器不应感知。
- **改法**：canvas-nest `<script>` 后追加一段内联脚本，创建后即对 `canvas[id^="c_n"]` 设 `aria-hidden="true"`（移动端不创建 canvas，选择器自然落空）。

### `themes/next/layout/_partials/header/brand.swig`
- **原因**：汉堡按钮 `<div class="toggle">` 带 aria-label 但无有效 role（axe aria-prohibited-attr，仅移动端视口暴露）。
- **改法**：加 `role="button" tabindex="0"`。

### `themes/next/source/js/next-boot.js`
- **原因**：配合上条，role=button 需支持键盘激活。
- **改法**：`.site-nav-toggle .toggle` 增加 `keydown` 监听，Enter/Space 时 `preventDefault()` 并转发 `click()`（展开/收起逻辑复用原 click 处理器）。

### `themes/next/source/js/utils.js`
- **原因**：
  1. `wrapTableWithBox`：客户端包裹的代码块表格容器需可键盘聚焦（axe scrollable-region-focusable），且构建期 a11y-fixes 已包裹的正文表格不能重复包裹；
  2. fancybox 图片说明 `.image-caption` 与 img alt 重复，屏幕阅读器会朗读两遍；
  3. `registerScrollPercent`：按钮 aria-label 需包含可见文本（滚动百分比），否则触发 label-content-name-mismatch。
- **改法**：
  1. 已包裹的表格直接 return；新容器加 `tabIndex=0`、`role="group"`、`aria-label="可横向滚动的表格"`（用 group 而非 region，避免多个同名 landmark 触发 landmark-unique）；
  2. `.image-caption` 加 `aria-hidden="true"`；
  3. 滚动回调里同步 `aria-label="返回顶部，已滚动 N%"`。

### `themes/next/source/css/_common/outline/footer/footer.styl`
- **原因**：页脚 #999 on #eee 对比度 2.46。
- **改法**：颜色改 `#6b6b6b`（4.59）。

### `themes/next/source/css/_common/components/post/post.styl`
- **原因**：图片说明 #999 on #fff 仅 2.85；正文段落链接仅靠颜色与正文区分（axe link-in-text-block），且 #0593d3 on #fff 仅 3.43。
- **改法**：`.image-caption` 改 `#767676`（4.54）；`.post-body p a` 改 `#047eb5`（4.51）并加 `border-bottom` 下划线（hover 变 `#036a99`），非颜色线索。

### `themes/next/source/css/_common/scaffolding/highlight/theme.styl`
- **原因**：代码高亮 `$highlight-orange` #f5871f（2.34）、`$highlight-green` #718c00（3.59）在 #f7f7f7 背景上不达标。
- **改法**：保持色相暗化——orange → `#a85e15`（4.58）、green → `#627a00`（4.56）。

### `themes/next/source/css/_common/outline/sidebar/sidebar-nav.styl` 与 `sidebar-toc.styl`
- **原因**：侧栏导航/TOC 激活色 #fc6423 on #fff 仅 3.01。
- **改法**：激活态颜色改 `#c74f1c`（4.60）。

### 配套（非主题源码）
- `scripts/a11y-fixes.js`（新建）：构建期 after_render:html 修复——任务清单 disabled checkbox 补 `aria-label="已完成/未完成"`；正文 `<table>` 包 `.table-container`（tabindex=0 + role=group + aria-label）；`<th>` 补 `scope="col"`。
- `source/_data/styles.styl`：行内 code `#ff7600 → #b85500`；暗色组（post-meta/caption/footer `#9b9b9b`、链接 `#30a5da` + 下划线、TOC `#fc7035`）；skip-link 样式；全局 `:focus-visible` 蓝色描边（亮 `#4d9fff` / 暗 `#7ab8ff`）及 `.table-container/.back-to-top/.copy-btn` 焦点样式；`.back-to-top { opacity: 1 }`（主题默认 0.6/0.8 会把按钮内灰字稀释到 3.69/4.36，取消半透明后 5.74/5.94）。
- **焦点描边规则的两个关键点（主题升级/改样式时勿丢）**：
  1. 全局规则写作 `body :focus-visible`，不能写纯 `:focus-visible`。PurgeCSS（`scripts/purge-css.js`）会把不含标签/类名的纯伪类选择器判为未使用并删除，导致线上完全没有自定义焦点色；加 `body` 前缀后选择器含标签名，可正常保留。
  2. 搜索输入框必须用 `.search-popup input.search-input:focus-visible`。主题 `search.styl` 的 `.search-popup input.search-input { outline: 0 }` 权重 (0,2,1) 高于普通类选择器，若只用 `.search-input:focus-visible` 会被压掉、输入框聚焦无描边。暗色覆盖块内需逐一列出同名选择器才能同权重覆盖颜色。
- **暗色 TOC 激活色（`#fc7035 !important`）**：位置 `source/_data/styles.styl` 的 `@media (prefers-color-scheme: dark)` 块内，作用于 `.sidebar-nav-active, .post-toc .nav .active > a, .post-toc .nav .active-current > a`。原因：主题侧栏/TOC 激活色 `#fc6423`（亮色已改 `#c74f1c`）在暗色 `#333` 底上约 4.20，需提亮到 `#fc7035`（4.52）才满足 AA；`!important` 是因为 NexT 主题在 `sidebar-toc.styl` 用 `.post-toc .nav .active > a` 的同等权重规则 + 主题自身也有 `!important`，不加强制标记会被主题覆盖。主题升级时若改用 CSS 变量或调整该选择器，需要重新核对这条覆盖是否仍然命中。

### P2-11（ARIA 完善）主题源码改动
- `themes/next/layout/_partials/header/menu.swig`：`<nav class="site-nav">` 加 `id="site-nav"`（供汉堡按钮 `aria-controls`）；搜索菜单项 `<a role="button">` 补 `tabindex="0"` 与 `aria-label`（无 href 的 a 本身不可聚焦）。
- `themes/next/layout/_partials/header/brand.swig`：汉堡 `.toggle` 补 `aria-expanded="false"` + `aria-controls="site-nav"`；搜索触发器 `.toggle.popup-trigger` 补 `role="button" tabindex="0" aria-label`。
- `themes/next/source/js/next-boot.js`：汉堡改为 `#site-nav` 引用；点击时先按目标状态写 `aria-expanded`，动画结束再按实际 class 校正；键盘激活改用共用函数。
- `themes/next/layout/_partials/search/index.swig`：`.popup.search-popup` 加 `role="dialog" aria-modal="true" aria-label`（焦点循环在 local-search.js 实现，未声明后置之不顾）。
- `themes/next/layout/_partials/search/localsearch.swig`：搜索输入框补 `aria-label="搜索文章"`；关闭控件由 `<span>` 改为原生 `<button type="button" class="popup-btn-close" aria-label="关闭搜索">`。
- `themes/next/source/js/local-search.js`：弹层打开时记录触发按钮并把焦点送入输入框；Tab/Shift+Tab 焦点循环（范围含结果链接）；关闭后焦点返还触发按钮（仅弹层原本处于打开态时）。
- `themes/next/source/js/utils.js`：新增 `NexT.utils.bindRoleButtonKeys`（幂等 Enter/Space → click，汉堡/搜索触发器/返回顶部共用）；复制按钮由 `<div>` 改为 `<button type="button" aria-label="复制代码">`，复制成功后 label 临时变「已复制」/「复制失败」，2 秒后复原；复制流程结束后把焦点交还按钮（临时 textarea 删除后焦点会落回 body，键盘用户会丢失位置），并移除原来的 `target.blur()`。
- `source/_data/styles.styl`：`.copy-btn, .popup-btn-close { background: transparent; border: 0; font-family: inherit }`（重置原生 button 默认外观）；`.popup-btn-close` 纳入焦点描边规则。

### P2-12（meta description）配套
- `scripts/seo-description.js`（新建）：`before_generate` 为无 front-matter description 的公开文章从正文首段提取纯文本（去图片/代码块/标题/引用/列表/表格，句末标点自然断句，120–160 字），写入 `post.seo_description`；`template_locals` 为首页/分类页/归档页生成模板描述。私密文章通过 `hexo.secret_is` 跳过。
- `themes/next/layout/_partials/head/head-unique.swig`：`open_graph()` 改为 `open_graph({ description: page.seo_description })`，未设置时回退到原链路（front-matter description / excerpt / 站点 description）。
- `source/admin/config.yml`：description 字段补 hint，说明选填与建议长度。
- 待核对（未实施）：文章数量超过一页后，核对 NexT 默认分页 `<nav class="pagination">` 是否带 `aria-label`，缺失则补「分页导航」。

