# 图片与媒体处理管线

## 分工约定

- **存量图片**：仓库内直接保存 WebP（`source/images/*.webp`）。
  - 一次性转换工具：`python3 tools/compress-images.py source/images`
  - 规则：文字截图质量 85、照片/头像质量 80，宽超 1200px 等比缩到 1200。
- **增量图片**：CMS 上传的 PNG/JPG 原样留在仓库（保留原图），构建时由
  `scripts/auto-webp.js` 自动：
  1. `after_init` 阶段生成同目录 WebP（限宽 1200、q85）；
  2. `after_post_render` 把正文中已有 WebP 的 `/images/*.png|jpg` 引用改写为 `.webp`。
  - 头像等刻意保留 PNG 的资源不受影响（钩子只在 WebP 存在时改写）。

## 文章图片属性

- **alt**：所有内容图必须写描述性 alt（不写"图片/截图"等废词）；装饰图用 `alt=""`。
- **width/height**：`scripts/img-dimensions.js` 在 `after_post_render` 自动读取本地图片真实尺寸并注入，
  外链/读取失败的图跳过不阻断构建。

## CMS 上传

- `source/admin/config.yml` 中 `media_folder: source/images`，上传的 PNG 由构建钩子自动转 WebP。
- 私密内容图片走 `source/admin-secret/`（私有仓库），不进入公开仓库。

## 引用完整性

- og:image、RSS/Atom 由 hexo 从正文自动提取，随正文引用变化自动更新。
- `_data/links.yml` 等数据文件中的图片路径需手动维护。
