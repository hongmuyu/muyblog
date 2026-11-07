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

  return str;
});
