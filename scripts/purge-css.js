'use strict';

/**
 * PurgeCSS：构建产物优化（审计修复主题 B-3）。
 *
 * after_generate 阶段对 main.css 执行未使用 CSS 清理。
 * 扫描所有产物 HTML 和 JS 中实际出现的类名，
 * 删除未被引用的 CSS 规则。safelist 保护运行时动态类名。
 */

const { PurgeCSS } = require('purgecss');
const fs = require('fs');
const path = require('path');

hexo.extend.filter.register('after_generate', async function purgeCss() {
  const cssFile = path.join(hexo.public_dir, 'css', 'main.css');
  if (!fs.existsSync(cssFile)) return;

  const safelist = {
    standard: [
      // 运行时动态切换
      /^giscus-/, /^sidebar-actions$/, /^use-motion$/,
      // 主题核心组件（含子选择器）
      /^site-/, /^header-/, /^footer-/, /^nav-/, /^menu-/,
      /^post-/, /^pagination-/, /^page-number$/, /^extend$/,
      /^back-to-top/, /^post-nav/, /^breadcrumbs/, /^toc/, /^sidebar-nav/,
      /^sidebar-/, /^brand/, /^logo/, /^site-title/, /^site-subtitle/,
      // 代码块/高亮
      /^copy-btn/, /^copy-success$/, /^highlight/, /^gutter$/, /^code$/,
      /^line/, /^marked/, /^figure/, /^table/, /^pre/, /^hljs/,
      // 搜索
      /^search-/, /^local-search-/, /^search-result/,
      // 暗色/主题
      /^dark$/, /^darkmode-/, /^theme-/,
      // 动画/画布
      /^canvas-/, /^motion-/,
      // SVG 图标（保留所有 fa- 前缀，含辅助类）
      /^fa($|[.-])/, /^fab$/, /^fas$/, /^far$/,
      // 状态类
      /^active$/, /^current$/, /^open$/, /^show$/, /^hide$/, /^fixed$/,
      /^animated$/, /^fade/, /^slide/, /^zoom/,
      // PurgeCSS dry-run 中误删的（实际在使用）
      /^category-all-page/,
      /^moment-empty/,
      /^blockquote-center/,
      // 404 页
      /^not-found/,
      // 私密分类
      /^secret-/,
      // 评论（giscus 容器）
      /^comments$/, /^comment$/,
      // 友链
      /^links-/,
      // 图片懒加载
      /^lozad/, /^lazy/
    ],
    deep: [/fa-/],
    greedy: [/sidebar-actions/, /use-motion/, /local-search/, /copy-btn/, /category-all-page/]
  };

  const original = fs.readFileSync(cssFile, 'utf-8');
  const purge = new PurgeCSS();
  const result = await purge.purge({
    content: [
      path.join(hexo.public_dir, '**/*.html'),
      path.join(hexo.public_dir, '**/*.js')
    ],
    css: [{ raw: original }],
    safelist,
    variables: false,
    keyframes: false,
    fontFace: false,
    rejected: true
  });

  const rejected = result[0].rejected || [];
  fs.writeFileSync(cssFile, result[0].css);
  hexo.log.info(`PurgeCSS: main.css ${(original.length/1024).toFixed(1)}KB → ${(result[0].css.length/1024).toFixed(1)}KB, removed ${rejected.length} selectors`);
});
