# 构建与质量门禁

本文档面向维护本仓库的人，说明本地构建、预览、图片处理、质量检查与 CI 发布流程。
README 只介绍博客本身，技术流程统一记录在这里。

## 1. 环境

- Node.js 22（CI 用 `actions/setup-node` 的 22）
- Hexo 8.1 + hexo-theme-next 7.8（Gemini scheme）
- 本地需安装 Google Chrome（仅 `npm run lhci` 需要；CI 的 ubuntu-latest 已预装 `/usr/bin/google-chrome`）

```bash
npm ci
```

## 2. 本地构建与预览

日常写文章预览：

```bash
npm run server          # hexo server，http://127.0.0.1:4000
```

产出与线上一致的静态文件（含 PurgeCSS 压缩）：

```bash
npm run clean
npx hexo generate
npm run purge           # 独立脚本，必须在 generate 之后执行
```

> 只跑 `hexo server` 不会执行 PurgeCSS，预览时的 CSS 会比线上大，属正常现象。

### 私密文章

私密文章源码放在独立私有仓库，构建时同步到 `source/_posts/secret/`（已 gitignore）。

- 本地构建加密版：把私有仓库克隆到 `.secret-content`（或设置 `SECRET_CONTENT_DIR`），并设置
  `SECRET_CATEGORY_PASSWORD`。缺密码时走本地开发模式，私密正文以明文构建并打印警告。
- CI 用 `SECRET_CONTENT_PAT` 拉取私有仓库、`SECRET_CATEGORY_PASSWORD` 提供密码；缺密码时 CI 直接报错拒绝发布。
- 私密文章写作走 `/admin-secret/`（Sveltia 指向私有仓库）。

## 3. 图片处理

- 存量图片直接保存 WebP，转换工具：`python3 tools/compress-images.py source/images`
  （文字截图 q85、照片/头像 q80，宽超 1200px 缩到 1200）。
- 增量图片（CMS 上传的 PNG/JPG）保留原图，构建期由 `scripts/auto-webp.js` 自动生成同目录 WebP
  并改写正文引用（限宽 1200、q85）。`sharp` 不可用时仅告警跳过，不阻断构建。
- `scripts/img-dimensions.js` 在渲染期为本地图片注入真实 `width`/`height`，避免 CLS。
- 内容图必须写描述性 alt，装饰图用 `alt=""`；详见 `docs/media-pipeline.md`。

## 4. 质量检查

三个检查均为「先告警、不阻断」，CI 中同样只记录问题，不影响部署。

| 命令 | 脚本 | 检查内容 | 当前阈值/基线 |
|---|---|---|---|
| `npm run audit` | `scripts/audit.js` | 图片 alt、内部死链与锚点、H1 唯一性、heading 不跳级 | 应输出空问题清单 |
| `npm run budget` | `scripts/perf-budget.js` | 首页首屏 JS/CSS（gzip）、单图体积 | JS 100KB / CSS 40KB / 图 200KB |
| `npm run lhci` | `lighthouserc.js` | Lighthouse 首页、文章页、分类页、归档页各 3 轮 | 全 warn 观察期 |

### audit

```bash
npx hexo generate && npm run audit
```

扫描 `public/**/*.html`（跳过 `admin/`、`admin-secret/`、`lib/`），输出：

- `img-alt`：`<img>` 缺 `alt` 属性（`alt=""` 放行）
- `link`：站内链接目标文件不存在
- `anchor`：页内锚点在目标页面不存在
- `h1`：每页 H1 数量不等于 1
- `heading`：标题层级跳级（如 h1 直接接 h3）

### 性能预算

```bash
npm run budget
```

读取首页 HTML 引用的站内 JS/CSS，按 gzip 后体积求和；再扫描 `public/` 所有图片。
`public/images/` 下的文章图超 200KB 单独列出但不计入告警。

### Lighthouse CI

```bash
npm run lhci   # npx @lhci/cli@0.15.1 autorun
```

`staticDistDir: './public'`，LHCI 自起静态服务，无需 hexo server；中文文章路径可正常访问。
当前断言全部为 `warn`：性能 ≥90、可访问性 ≥95、LCP ≤3000ms、CLS ≤0.1、TBT ≤200ms，`numberOfRuns: 3`。
报告写入 `.lighthouseci/`（已 gitignore）。

## 5. CI 发布流程

工作流：`.github/workflows/pages.yml`，push 到 `main` 或手动 `workflow_dispatch` 触发。

1. Checkout + Node 22 + `npm ci`
2. `actions/configure-pages`
3. 用 `SECRET_CONTENT_PAT` 克隆私有仓库到 `.secret-content`（未配置则告警并跳过私密内容）
4. `npx hexo generate`（读取 `SECRET_CATEGORY_PASSWORD`）
5. `npm run purge`（独立脚本，在产物落盘后执行）
6. 产物校验：缺 `public/index.html` 直接失败，保留上一个正常版本
7. `npm run audit`、`npm run budget`（只输出问题）
8. `npm run lhci`（warn 观察期，`continue-on-error`，不阻断部署）
9. 上传 Pages artifact
10. `git push --force origin main:backup` 同步滚动备份分支
11. `deploy` job 发布到 GitHub Pages

唯一发布方式是 `git push` 触发 Actions，不要同时启用 `hexo-deployer-git`。

## 6. 构建脚本一览

| 脚本 | 类型 | 用途 |
|---|---|---|
| `scripts/auto-webp.js` | Hexo 钩子 | 构建期生成 WebP、改写正文图片引用 |
| `scripts/img-dimensions.js` | Hexo 钩子 | 为本地图片注入 width/height，减少 CLS |
| `scripts/purge-css.js` | 独立脚本 | 产物 CSS 清理（`npm run purge`） |
| `scripts/audit.js` | 独立脚本 | 内容审计（`npm run audit`） |
| `scripts/perf-budget.js` | 独立脚本 | 性能预算（`npm run budget`） |
| `lighthouserc.js` | LHCI 配置 | 四个页面的 Lighthouse 审计（`npm run lhci`） |

> Hexo 会自动加载 `scripts/*.js` 作为插件；独立脚本入口都带 `if (require.main === module)` 守卫，
> 不会被构建立即执行。

## 7. 待办 / 后续计划

- **Lighthouse CI 观察期回看**：warn 模式运行一周后，汇总各页面分数分布，再决定是否把断言升为 `error`，
  以及是否调整 LCP / TBT 阈值（CI 环境比本地慢，暂定 LCP 3000ms）。
- **分类 description 偏短**：当前文章 tags 为空，分类页描述退回站点名。短期接受，长期在内容侧补 tags，
  不为了让描述变长而硬凑标签。
