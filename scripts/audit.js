'use strict';

/**
 * 主题 E-1：内容审计。
 *
 * 构建后执行 `node scripts/audit.js`，检查 public/ 产物：
 * 1. 图片 alt：内容图必须有 alt，装饰图 alt="" 放行（缺失 alt 属性即告警）
 * 2. 死链：站内链接 4xx/5xx（产物文件不存在）与锚点不存在
 * 3. H1 唯一性：每页恰好 1 个 h1
 * 4. heading 层级：不跳级（如 h1 直接接 h3）
 *
 * 只输出问题清单与统计，不阻断构建。被 Hexo 加载 scripts/ 目录时不执行。
 */

const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..');
const PUBLIC = path.join(ROOT, 'public');
const SKIP_DIRS = new Set(['admin', 'admin-secret', 'lib']);

function walk(dir, out) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (entry.name.startsWith('.')) continue;
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      const rel = path.relative(PUBLIC, full).replace(/\\/g, '/');
      if (SKIP_DIRS.has(rel) || /^(admin|admin-secret|lib)(\/|$)/.test(rel)) continue;
      walk(full, out);
    } else if (entry.name.endsWith('.html')) {
      out.push(full);
    }
  }
  return out;
}

function pageUrl(file) {
  const rel = path.relative(PUBLIC, file).replace(/\\/g, '/');
  if (rel === 'index.html') return '/';
  if (rel.endsWith('/index.html')) return '/' + rel.slice(0, - 'index.html'.length);
  return '/' + rel;
}

function stripNonContent(html) {
  return html
    .replace(/<script[\s\S]*?<\/script>/gi, ' ')
    .replace(/<style[\s\S]*?<\/style>/gi, ' ')
    .replace(/<!--[\s\S]*?-->/g, ' ');
}

// 将站内 URL 路径映射到 public/ 下的实际文件
function resolveTarget(pathname) {
  const clean = decodeURIComponent(pathname.split('?')[0]);
  const base = path.join(PUBLIC, clean);
  const candidates = [];
  if (clean.endsWith('/')) {
    candidates.push(path.join(base, 'index.html'));
  } else if (path.extname(clean)) {
    candidates.push(base);
  } else {
    candidates.push(base, base + '.html', path.join(base, 'index.html'));
  }
  return candidates.find(f => fs.existsSync(f) && fs.statSync(f).isFile()) || null;
}

function collectIds(html) {
  const ids = new Set();
  for (const m of html.matchAll(/\b(?:id|name)="([^"]+)"/g)) ids.add(m[1]);
  return ids;
}

function main() {
  if (!fs.existsSync(PUBLIC)) {
    console.error('audit: 未找到 public/，请先执行 hexo generate');
    process.exit(1);
  }

  const pages = walk(PUBLIC, []);
  const issues = [];
  const idCache = new Map();

  for (const file of pages) {
    const url = pageUrl(file);
    const raw = fs.readFileSync(file, 'utf-8');
    const html = stripNonContent(raw);

    // 1. H1 唯一性 + heading 层级
    const headings = [...html.matchAll(/<h([1-6])\b[^>]*>/gi)].map(m => Number(m[1]));
    const h1Count = headings.filter(l => l === 1).length;
    if (h1Count !== 1) {
      issues.push({ page: url, type: 'h1', message: `h1 数量为 ${h1Count}（应为 1）` });
    }
    let prev = 0;
    headings.forEach((level, index) => {
      if (prev && level > prev + 1) {
        issues.push({ page: url, type: 'heading', message: `第 ${index + 1} 个标题 h${level} 前为 h${prev}，跳级` });
      }
      prev = level;
    });

    // 2. 图片 alt
    for (const m of html.matchAll(/<img\b([^>]*)>/gi)) {
      if (!/\balt=("|')/.test(m[1])) {
        const src = (m[1].match(/\bsrc=("|')([^"']+)/) || [])[2] || '(unknown)';
        issues.push({ page: url, type: 'img-alt', message: `缺少 alt 属性: ${src}` });
      }
    }

    // 3. 死链与锚点
    for (const m of html.matchAll(/<a\b[^>]*\bhref=("|')([^"']+)\1/gi)) {
      const href = m[2].trim();
      if (!href || href === '#') continue;
      if (/^(?:https?:|mailto:|tel:|javascript:|data:|\/\/)/i.test(href)) continue;

      let target;
      try {
        target = new URL(href, 'http://site.local' + url);
      } catch (e) {
        issues.push({ page: url, type: 'link', message: `无法解析的链接: ${href}` });
        continue;
      }
      if (target.origin !== 'http://site.local') continue;

      const fileTarget = resolveTarget(target.pathname);
      if (!fileTarget) {
        issues.push({ page: url, type: 'link', message: `链接目标不存在: ${href}` });
        continue;
      }

      const fragment = decodeURIComponent(target.hash.replace(/^#/, ''));
      if (!fragment || fragment.startsWith(':') || fragment.startsWith('!')) continue;
      if (!fileTarget.endsWith('.html')) continue;

      if (!idCache.has(fileTarget)) {
        idCache.set(fileTarget, collectIds(fs.readFileSync(fileTarget, 'utf-8')));
      }
      if (!idCache.get(fileTarget).has(fragment)) {
        issues.push({ page: url, type: 'anchor', message: `锚点不存在: ${href}` });
      }
    }
  }

  const byType = issues.reduce((acc, issue) => {
    acc[issue.type] = (acc[issue.type] || 0) + 1;
    return acc;
  }, {});

  console.log(`audit: 扫描 ${pages.length} 个页面`);
  console.log(`问题汇总: ${JSON.stringify(byType)}`);
  if (issues.length) {
    console.log('');
    for (const issue of issues) {
      console.log(`[${issue.type}] ${issue.page} — ${issue.message}`);
    }
  } else {
    console.log('未发现问题。');
  }
}

// 仅作为独立脚本执行时运行；被 Hexo 加载 scripts/ 目录时 require.main !== module，不执行
if (require.main === module) {
  main();
}
