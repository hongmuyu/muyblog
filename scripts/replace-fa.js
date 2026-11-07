'use strict';

/**
 * FontAwesome → 内联 SVG 替换（审计修复 #5 / 主题 B-1）。
 *
 * after_render:html 阶段：
 * 1) 把 <i class="fa[srb]? fa-xxx ..."> 替换为 <svg class="fa fa-xxx ...">，
 *    内部用 <use href="#i-xxx">；
 * 2) 社交图标 <i class="github|envelope|gratipay fa-fw"> 一并映射；
 * 3) </body> 前注入 SVG sprite（仅当页用到的 symbol）；
 * 4) fa-fw/fa-lg/fa-5x/fa-pulse 等辅助类保留，由配套 CSS 换算。
 *
 * 动态图标（复制按钮 fa-clipboard/check/times、搜索无结果 search/frown）：
 * 过滤器同样替换为 svg，utils.js / local-search.js 中改为操作 <use> 的 href。
 */

const fs = require('fs');
const path = require('path');

const ICONS = JSON.parse(fs.readFileSync(path.join(hexo.base_dir, 'data/fa-icons.json'), 'utf-8'));

// 社交图标别名映射（无 fa- 前缀的 class）
const SOCIAL = { github: 'github', envelope: 'envelope', gratipay: 'gratipay' };

// thumb-tack 旧名统一到 thumbtack
const ALIASES = { 'thumb-tack': 'thumbtack' };

function symbolFor(name) {
  const key = ALIASES[name] || name;
  const ic = ICONS[key];
  if (!ic) return null;
  return `<symbol id="i-${key}" viewBox="0 0 ${ic.w} ${ic.h}"><path fill="currentColor" d="${ic.d}"/></symbol>`;
}

const FA_ICON_RE = /<i\b([^>]*?)>\s*<\/i>/g;

function parseAttrs(s) {
  const m = s.match(/class="([^"]*)"/);
  return m ? m[1].split(/\s+/).filter(Boolean) : [];
}

hexo.extend.filter.register('after_render:html', function replaceFa(str) {
  const used = new Set();
  // 动态图标（复制按钮、搜索无结果）运行时插入，必须始终包含在 sprite 中
  ['clipboard', 'check', 'times', 'search', 'frown'].forEach(n => used.add(n));
  let count = 0;

  str = str.replace(FA_ICON_RE, (whole, attrs) => {
    const classes = parseAttrs(attrs);
    // 找图标名：fa-xxx 或社交名
    let icon = null;
    for (const c of classes) {
      if (c.startsWith('fa-') && !['fa-fw','fa-lg','fa-5x','fa-pulse','fa-spin','fa-sm','fa-xs','fa-2x','fa-3x','fa-4x'].includes(c)) {
        icon = c.slice(3);
        break;
      }
      if (SOCIAL[c]) { icon = SOCIAL[c]; break; }
    }
    if (!icon) return whole;
    const key = ALIASES[icon] || icon;
    if (!ICONS[key]) return whole;

    used.add(key);
    count++;
    // 保留原 class（含 fa-xxx、fa-fw、fa-5x 等），用于 CSS 对齐/尺寸/动画
    const cls = classes.join(' ');
    return `<svg class="${cls}" data-icon="${key}" aria-hidden="true" focusable="false"><use href="#i-${key}" xlink:href="#i-${key}"/></svg>`;
  });

  if (!used.size) return str;

  const symbols = [...used].map(symbolFor).filter(Boolean).join('');
  const sprite = `<svg xmlns="http://www.w3.org/2000/svg" style="display:none" aria-hidden="true">${symbols}</svg>`;
  return str.replace('</body>', sprite + '</body>');
});

// 暴露给验证脚本
hexo.extend.helper.register('fa_replace_count', () => count);
