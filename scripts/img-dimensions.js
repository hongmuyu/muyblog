'use strict';

/**
 * 构建期为文章内 <img> 补 width/height（对应审计修复 #3）。
 *
 * - after_post_render：解析正文中指向本地 /images/* 的图片，读取真实尺寸，
 *   注入 width/height 属性（已有则不覆盖）。
 * - 支持 PNG/JPG/WebP（PIL... 这里用 sharp，构建已依赖）。
 * - 外链图或尺寸读取失败的图跳过，不阻断构建。
 */

const fs = require('fs');
const path = require('path');

let sharp = null;
try { sharp = require('sharp'); } catch (e) { /* 降级 */ }

const IMG_RE = /<img([^>]*?)>/g;
const SRC_RE = /src=["'](\/images\/[^"']+\.(webp|png|jpe?g|gif))["']/i;
const WH_RE = /\b(width|height)\s*=/i;

const dimCache = new Map();

async function readDimensions(src) {
  if (dimCache.has(src)) return dimCache.get(src);
  const imgDir = path.join(hexo.source_dir, 'images');
  const name = path.basename(src);
  const fp = path.join(imgDir, name);
  if (!fs.existsSync(fp)) return null;
  try {
    if (sharp) {
      const meta = await sharp(fp).metadata();
      const d = { width: meta.width, height: meta.height };
      dimCache.set(src, d);
      return d;
    }
  } catch (e) { /* fallthrough */ }
  // sharp 不可用时降级：通过 image-size（若安装）或返回 null
  try {
    const sizeOf = require('image-size');
    const m = sizeOf(fp);
    const d = { width: m.width, height: m.height };
    dimCache.set(src, d);
    return d;
  } catch (e) {
    return null;
  }
}

hexo.extend.filter.register('after_post_render', async function injectImgDimensions(data) {
  if (!data.content || typeof data.content !== 'string') return data;
  const replacements = [];
  for (const m of data.content.matchAll(IMG_RE)) {
    const full = m[0];
    const attrs = m[1];
    const srcM = attrs.match(SRC_RE);
    if (!srcM) continue;
    if (WH_RE.test(attrs)) continue; // 已有尺寸，跳过
    const src = srcM[1];
    replacements.push({ full, src });
  }
  if (!replacements.length) return data;

  // 串行读取避免并发过高
  for (const r of replacements) {
    const d = await readDimensions(r.src);
    if (!d) continue;
    const newTag = r.full.replace(/<img/, `<img width="${d.width}" height="${d.height}"`);
    data.content = data.content.replace(r.full, newTag);
  }
  return data;
});
