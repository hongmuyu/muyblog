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
- **样式易丢失规则**：焦点描边、暗色 TOC 覆盖等已统一归档到「12. 构建期样式坑位统一归档」，主题升级后按该节逐项复查。

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
- `scripts/seo-description.js`（新建）：`before_generate` 为无 front-matter description 的公开文章从正文首段提取纯文本（去图片/代码块/标题/引用/列表/表格，句末标点自然断句，120–160 字），写入 `post.seo_description`；`template_locals` 为首页/分类页/归档页生成模板描述。私密文章通过 `hexo.secret_is` 跳过。分类页优先取分类自身 description，缺失则用该分类下前 3 个高频标签拼「涵盖 X、Y、Z 等主题」，无标签时退回站点名；归档页为「共 N 篇文章，覆盖 YYYY 至 YYYY 年，最新为「标题」」（均只统计公开文章）。
- `themes/next/layout/_partials/head/head-unique.swig`：`open_graph()` 改为 `open_graph({ description: page.seo_description })`，未设置时回退到原链路（front-matter description / excerpt / 站点 description）。
- `source/admin/config.yml`：description 字段补 hint，说明选填与建议长度。

### 待核对（未实施）
- 分页（P2-11 遗留）：文章数量超过一页后，核对 NexT 默认分页 `<nav class="pagination">` 是否带 `aria-label`，缺失则补「分页导航」。

## 11. 主题 E-1：内容审计修复（2026-11）

### `themes/next/layout/charts.swig`
- **原因**：`/charts/` 页面的三个小节标题原为 `<h3>`，页面标题是 `<h1>`，形成 h1 → h3 跳级（axe heading-order）。
- **改法**：三个 `<h3>`（分类分布、标签 Top 10、年度发文）统一改为 `<h2>`。配套 `source/_data/styles.styl` 的 `.chart-section h3` 选择器同步改为 `h2`。

### 关于页重复 h1（非主题源码）
- **原因**：`source/about/index.md` 正文里的 `# 你好，我是木与宁` 会与主题渲染的页面标题 h1（「关于」）重复。
- **改法**：正文标题降为 `##`；`source/_data/styles.styl` 的 `.about-hero h1` 选择器改为 `.about-hero h2`。

### `themes/next/layout/_macro/post.swig`：补 `#more` 锚点
- **原因**：主题第 200 行的「阅读全文」固定链接到 `{{ post.path }}#more`，但 Hexo 只在源码含 `<!-- more -->` 时生成 `<span id="more">`；本站 `scripts/auto-excerpt.js` 只写 `data.excerpt`（纯文本），不动正文，因此自动摘要文章的文章页没有该锚点。
- **改法**：文章页正文分支（`{% else %}`，即非首页列表）在 `<div class="post-body">` 内、`{{ post.content }}` 之前插入 `<span id="more"></span>`；条件为 `page.layout === 'post'` 且正文不含 `id="more"` / `id='more'`，避免手动 `<!-- more -->` 时重复 id。

### `themes/next/layout/_macro/post.swig`：私密分类/标签链接降级
- **原因**：私密文章的「分类于」「标签」由主题自动渲染成 `<a href="{{ cat.path }}">`，但私密分类/标签没有任何公开文章，对应页面不生成，形成死链。
- **改法**：
  - `scripts/secret-category.js` 注册 helper `has_public_posts(entry)`：分类/标签下至少有一篇「非隐藏且非私密」文章才返回 true（同时覆盖「公开文章属于只含私密文章的分类」这一边界）。
  - 模板按该 helper 分支：true 保持 `<a>`；false 改为纯文本 `<span>`（无 `role`/`tabindex`，屏幕阅读器不会读成链接）。
  - `source/_data/styles.styl` 增加 `.post-tags span`，样式与链接标签保持一致。
  - 私密文章自身仍算「隐藏」，因此其分类/标签自动落入纯文本分支，无需额外判断当前文章是否私密。

### `themes/next/scripts/helpers/next-config.js`：fancybox 开关按页面限定
- **原因**：B-2 把 jquery/fancybox 限定为仅文章页加载后，前端 `CONFIG.fancybox` 仍取 `theme.fancybox`（全站 true），列表页执行 `wrapImageWithFancyBox()` 时抛出 `$ is not defined`（首页、分类页、归档页均有，控制台可见，不影响渲染）。
- **改法**：`fancybox: theme.fancybox && this.page.layout === 'post'`，与 `vendors.swig` / `head.swig` 的加载条件保持一致。主题依赖 head 的 partial 缓存已关闭（见第 5 条），逐页取值有效。

## 12. 构建期样式坑位统一归档（2026-11）

主题升级或调整构建流程后，先按本节逐项复查。

### 12.1 PurgeCSS 纯伪类误删

- **现象**：写在 `source/_data/styles.styl` 的全局 `:focus-visible` 规则在线上完全不存在，键盘聚焦无描边，但本地开发（不跑 PurgeCSS）正常。
- **原因**：PurgeCSS 内置只保护 `*`、`:root`、`:after`、`:before` 四个纯伪类；单独成规则的 `:focus-visible`、`:hover` 等会被判为「未使用」整条删除。
- **双保险**：
  1. `scripts/purge-css.js` 的 `safelist.standard` 显式列出 `:hover/:focus/:active/:focus-visible/:focus-within/::selection/::placeholder` 等纯伪类；
  2. 实际规则仍写元素前缀（`body :focus-visible`），即使 safelist 失效也不会被删。
- **注意**：PurgeCSS 还会从逗号选择器列表中单独删掉某个选择器，所以 `body :focus-visible` 与具体组件选择器要拆成两条独立规则，不要写在同一组逗号列表里。
- **升级复查**：`npm run purge` 后检查 `public/css/main.css` 是否仍含 `:focus-visible` 规则，并用键盘 Tab 实测焦点框。

### 12.2 `outline: 0` 清单（6 处逐一评估）

| # | 位置 | 选择器 | 评估与处理 |
|---|---|---|---|
| 1 | `themes/next/source/css/_common/scaffolding/base.styl` | `a, span.exturl` | 全站链接的 outline 归零；被 `body :focus-visible`（权重更高）正常覆盖，无需改动 |
| 2 | `themes/next/source/css/_common/components/third-party/search.styl` | `.search-popup input.search-input` | 权重 (0,2,1) 压过普通类规则，聚焦无描边；已用 `.search-popup input.search-input:focus-visible` 覆盖 |
| 3 | `themes/next/source/css/_common/scaffolding/tags/tabs.styl` | tabs 内 `a` | 文章内 tabs 链接聚焦无描边；已补 `.post-body .tabs ul.nav-tabs li.tab a:focus-visible` 与 `.tabs-comment ...` |
| 4 | `themes/next/source/css/_common/components/post/post-reward.styl` | 打赏按钮 | `reward_settings.enable: false`，产物不渲染，无影响 |
| 5 | `source/_data/styles.styl` | `.local-search-popup .local-search-input-wrapper input:focus` | NexT 实际弹层是 `.search-popup`，该样式为历史遗留、无页面使用，保持原样 |
| 6 | `source/_data/styles.styl` | `.secret-input:focus` | 私密入口输入框聚焦无描边；已补 `.secret-input:focus-visible`（同权重、写在文件末尾靠后覆盖） |

### 12.3 暗色 `!important` 覆盖（TOC 激活色）

- **位置**：`source/_data/styles.styl` 的 `@media (prefers-color-scheme: dark)` 块内。
- **对象**：`.sidebar-nav-active, .post-toc .nav .active > a, .post-toc .nav .active-current > a`。
- **原因**：主题侧栏/TOC 激活色 `#fc6423`（亮色已改 `#c74f1c`）在暗色 `#333` 底上对比度约 4.20，不满足 AA；提亮到 `#fc7035`（约 4.52）。主题自身对同选择器已有 `!important`，不加强制标记会被覆盖。
- **升级复查**：主题若改用 CSS 变量或调整该选择器结构，需要重新核对覆盖是否命中，并在暗色模式下跑 axe / Lighthouse 确认对比度仍达标。

### 12.4 PurgeCSS 拆分为独立脚本

- **原因**：Hexo 的 `after_generate` 钩子早于物理写文件，全新 checkout 首次构建时 `public/css/main.css` 还不存在，清理会被跳过，CI 上线的是未压缩 CSS。主题升级后若把清理重新挂回 Hexo 钩子，这个坑会复现。
- **现状**：`scripts/purge-css.js` 是独立脚本，`npm run purge` 在 `hexo generate` 之后、上传产物之前执行；不要依赖钩子时机。
- **升级/改流程复查**：构建步骤必须保持「generate → purge → 质量检查 → upload」的顺序；PurgeCSS 体积异常偏大时，先确认 purge 是否真的执行过。



