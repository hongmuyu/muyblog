'use strict';

/**
 * 主题 D：可访问性修复。
 *
 * after_render:html 阶段：
 * 1) 为 marked 生成的任务清单 disabled checkbox 补 aria-label（P0-1）；
 * 2) 为正文表格包裹 .table-container 并补 tabindex="0" + role="group" + aria-label，
 *    使键盘用户可聚焦并横向滚动（P0-3，代码块表格由 utils.js wrapTableWithBox 客户端包裹）；
 * 3) 为表格 <th> 补 scope="col"（补查-4）。
 */

hexo.extend.filter.register('after_render:html', function a11yFixes(str) {
  // 1) disabled checkbox -> aria-label
  // marked 输出为 <input disabled type="checkbox">（无引号）
  str = str.replace(/<input\b([^>]*?)type="checkbox"([^>]*)>/g, (match, before, after) => {
    // 只处理 disabled 的（任务清单）
    if (!/disabled/.test(match)) return match;
    const checked = /\bchecked\b/.test(match);
    const label = checked ? '已完成' : '未完成';
    if (/aria-label=/.test(match)) return match;
    return `<input${before}type="checkbox"${after} aria-label="${label}">`;
  });

  // 2) 为 <table> 包裹 .table-container 并补 tabindex + role + aria-label
  // 仅处理非代码块内的表格（代码块 table 在 figure.highlight 内）
  // 用配对扫描：找每个 <table> 是否在 figure.highlight 内，不是则包裹
  let result = '';
  let cursor = 0;
  const tableRe = /<table>/g;
  let m;
  while ((m = tableRe.exec(str)) !== null) {
    const idx = m.index;
    // 向前找最近的 <figure 和 </figure>，判断是否在 highlight 内
    const before = str.slice(0, idx);
    const lastFigOpen = before.lastIndexOf('<figure');
    const lastFigClose = before.lastIndexOf('</figure>');
    const isHighlight = lastFigOpen > lastFigClose;
    if (!isHighlight) {
      result += str.slice(cursor, idx) + '<div class="table-container" tabindex="0" role="group" aria-label="可横向滚动的表格"><table>';
      cursor = idx + m[0].length;
    }
  }
  result += str.slice(cursor);
  str = result;

  // 同样处理 </table>（需要跳过 figure.highlight 内的）
  result = '';
  cursor = 0;
  const tableEndRe = /<\/table>/g;
  while ((m = tableEndRe.exec(str)) !== null) {
    const idx = m.index;
    const before = str.slice(0, idx);
    const lastFigOpen = before.lastIndexOf('<figure');
    const lastFigClose = before.lastIndexOf('</figure>');
    const isHighlight = lastFigOpen > lastFigClose;
    if (!isHighlight) {
      result += str.slice(cursor, idx) + '</table></div>';
      cursor = idx + m[0].length;
    }
  }
  result += str.slice(cursor);
  str = result;

  // 3) <th> -> scope="col"（避免匹配 thead/th 前缀）
  str = str.replace(/<th(\s[^>]*)?>/g, (match, attrs) => {
    if (attrs && /scope=/.test(attrs)) return match;
    return `<th scope="col"${attrs || ''}>`;
  });

  return str;
});
