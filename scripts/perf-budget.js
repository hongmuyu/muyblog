'use strict';

/**
 * 主题 E-1：性能预算检查。
 *
 * 构建后用 `node scripts/perf-budget.js` 检查 public/ 产物：
 * - 首屏 JS（首页引用的全部 <script src>）gzip 后 ≤100KB
 * - 首屏 CSS（首页引用的全部 <link rel="stylesheet">）gzip 后 ≤40KB
 * - 单张图片 ≤200KB，文章图（public/images/ 下）超标单独列出，不阻断
 *
 * 只告警、不阻断构建（先观察）。被 Hexo 作为 scripts/ 插件加载时不执行。
 */

const fs = require('fs');
const path = require('path');
const zlib = require('zlib');

const ROOT = path.join(__dirname, '..');
const PUBLIC = path.join(ROOT, 'public');

const BUDGETS = {
  jsGzip: 100 * 1024,
  cssGzip: 40 * 1024,
  image: 200 * 1024
};

const IMAGE_EXT = new Set(['.jpg', '.jpeg', '.png', '.gif', '.webp', '.svg', '.avif']);

function gzipSize(file) {
  return zlib.gzipSync(fs.readFileSync(file)).length;
}

function collectFirstScreenAssets(htmlFile) {
  const html = fs.readFileSync(htmlFile, 'utf-8');
  const js = [...html.matchAll(/<script[^>]*\bsrc="([^"]+)"/g)]
    .map(m => m[1])
    .filter(u => u.startsWith('/'));
  const css = [...html.matchAll(/<link[^>]*rel="stylesheet"[^>]*href="([^"]+)"/g)]
    .map(m => m[1])
    .filter(u => u.startsWith('/'));
  return { js: [...new Set(js)], css: [...new Set(css)] };
}

function walk(dir, out) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) walk(full, out);
    else out.push(full);
  }
  return out;
}

function kb(bytes) {
  return `${(bytes / 1024).toFixed(1)}KB`;
}

function main() {
  if (!fs.existsSync(path.join(PUBLIC, 'index.html'))) {
    console.error('perf-budget: 未找到 public/index.html，请先执行 hexo generate');
    process.exit(1);
  }

  const warnings = [];
  const assets = collectFirstScreenAssets(path.join(PUBLIC, 'index.html'));

  let jsTotal = 0;
  let cssTotal = 0;
  console.log('首屏资源（gzip）:');
  for (const url of assets.js) {
    const file = path.join(PUBLIC, url);
    if (!fs.existsSync(file)) {
      warnings.push(`JS 引用缺失: ${url}`);
      continue;
    }
    const size = gzipSize(file);
    jsTotal += size;
    console.log(`  JS  ${url}  ${kb(size)}`);
  }
  for (const url of assets.css) {
    const file = path.join(PUBLIC, url);
    if (!fs.existsSync(file)) {
      warnings.push(`CSS 引用缺失: ${url}`);
      continue;
    }
    const size = gzipSize(file);
    cssTotal += size;
    console.log(`  CSS ${url}  ${kb(size)}`);
  }

  console.log('');
  console.log(`首屏 JS 合计 ${kb(jsTotal)} / 预算 ${kb(BUDGETS.jsGzip)}`);
  console.log(`首屏 CSS 合计 ${kb(cssTotal)} / 预算 ${kb(BUDGETS.cssGzip)}`);
  if (jsTotal > BUDGETS.jsGzip) warnings.push(`首屏 JS 超标: ${kb(jsTotal)} > ${kb(BUDGETS.jsGzip)}`);
  if (cssTotal > BUDGETS.cssGzip) warnings.push(`首屏 CSS 超标: ${kb(cssTotal)} > ${kb(BUDGETS.cssGzip)}`);

  const images = walk(PUBLIC, []).filter(f => IMAGE_EXT.has(path.extname(f).toLowerCase()));
  const oversize = images
    .map(f => ({ file: f, size: fs.statSync(f).size }))
    .filter(item => item.size > BUDGETS.image);

  console.log('');
  console.log(`图片检查：共 ${images.length} 张，阈值 ${kb(BUDGETS.image)}，超标 ${oversize.length} 张`);
  for (const item of oversize) {
    const rel = path.relative(PUBLIC, item.file).replace(/\\/g, '/');
    const isPostImage = rel.startsWith('images/');
    const mark = isPostImage ? '（文章图，允许例外）' : '';
    console.log(`  超标 ${kb(item.size)}  /${rel}${mark}`);
    if (!isPostImage) warnings.push(`非文章图超标: /${rel} ${kb(item.size)} > ${kb(BUDGETS.image)}`);
  }

  if (warnings.length) {
    console.log('');
    console.log(`告警 ${warnings.length} 条：`);
    warnings.forEach(w => console.log(`  - ${w}`));
  } else {
    console.log('');
    console.log('全部在预算内。');
  }
}

// 仅作为独立脚本执行时运行；被 Hexo 加载 scripts/ 目录时 require.main !== module，不执行
if (require.main === module) {
  main();
}
