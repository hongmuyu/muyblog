'use strict';

/**
 * 未来新增图片的自动 WebP 压缩（对应审计修复 #2 的「发布链路压缩步骤」）。
 *
 * 分工约定：
 * - 存量图片：仓库内直接保存 WebP（见 tools/compress-images.py 一次性转换）。
 * - 增量图片：CMS 上传的 PNG/JPG 原样留在仓库（保留原图），本钩子在构建时
 *   1) after_init：为 source/images 下缺少 WebP 的位图生成 WebP
 *      （宽超 1200px 等比缩到 1200，q85）。
 *      必须在 after_init 而非 before_generate：后者触发时 hexo 已扫完
 *      source 目录，新建文件不会进入本轮构建产物；
 *   2) after_post_render：把正文中指向 /images/*.png|jpg 且已有 WebP 的
 *      引用改写为 .webp（og:image 由 open_graph 在布局渲染时取正文图，随动）。
 *
 * sharp 缺失（如 CI 未装 devDependencies）时仅告警跳过，不阻断构建：
 * 已提交的 WebP 不受影响，新 PNG 则按原样发布。
 */

const fs = require('fs');
const path = require('path');

const MAX_WIDTH = 1200;
const QUALITY = 85;
const BITMAP_RE = /\.(png|jpe?g)$/i;

let sharp = null;
try {
  sharp = require('sharp');
} catch (e) {
  // 延迟到真正需要时报 warning，避免每次启动都刷屏
}

function webpName(file) {
  return file.replace(BITMAP_RE, '.webp');
}

function hasWebp(imgDir, file) {
  return fs.existsSync(path.join(imgDir, webpName(file)));
}

hexo.extend.filter.register('after_init', async function autoWebpGenerate() {
  const imgDir = path.join(hexo.source_dir, 'images');
  if (!fs.existsSync(imgDir)) return;
  const targets = fs.readdirSync(imgDir).filter(f => {
    if (!BITMAP_RE.test(f)) return false;
    const webp = path.join(imgDir, webpName(f));
    return !fs.existsSync(webp) ||
      fs.statSync(path.join(imgDir, f)).mtimeMs > fs.statSync(webp).mtimeMs;
  });
  if (!targets.length) return;
  if (!sharp) {
    hexo.log.warn('[auto-webp] sharp 不可用，跳过 %d 张图片的 WebP 生成', targets.length);
    return;
  }
  for (const f of targets) {
    const src = path.join(imgDir, f);
    const dst = path.join(imgDir, webpName(f));
    try {
      let img = sharp(src);
      const meta = await img.metadata();
      if (meta.width > MAX_WIDTH) img = img.resize({ width: MAX_WIDTH });
      await img.webp({ quality: QUALITY }).toFile(dst);
      hexo.log.info('[auto-webp] %s -> %s', f, webpName(f));
    } catch (e) {
      hexo.log.warn('[auto-webp] 转换失败 %s: %s', f, e.message);
    }
  }
});

hexo.extend.filter.register('after_post_render', function autoWebpRewrite(data) {
  const imgDir = path.join(hexo.source_dir, 'images');
  if (!fs.existsSync(imgDir)) return data;
  data.content = data.content.replace(
    /(<img[^>]+src=["'])(\/images\/[^"']+?)(\.(?:png|jpe?g))(["'])/gi,
    (m, pre, p, ext, post) =>
      hasWebp(imgDir, path.basename(p) + ext) ? pre + p + '.webp' + post : m
  );
  return data;
});
