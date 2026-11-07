'use strict';

/**
 * PurgeCSS：构建产物优化（审计修复主题 B-3）。
 *
 * 独立脚本，不注册 Hexo 钩子：在 `hexo generate` 产物落盘后执行。
 * 原因：after_generate 钩子早于 Hexo 物理写文件，全新构建时 public/css/main.css
 * 尚不存在，清理会被跳过（CI 只构建一次，线上拿到的是未清理 CSS）。
 *
 * 用法：npm run purge
 */

const { PurgeCSS } = require('purgecss');
const fs = require('fs');
const path = require('path');

const publicDir = path.join(__dirname, '..', 'public');
const cssFile = path.join(publicDir, 'css', 'main.css');

const safelist = {
  standard: [
    // 纯伪类选择器：PurgeCSS 只内置保护 *, :root, :after, :before，
    // 其余伪类若单独成规则（如 :focus-visible）会被判为未使用而整条删除
    ':hover', ':focus', ':active', ':focus-visible', ':focus-within',
    ':visited', ':link', ':checked', ':disabled', ':placeholder-shown',
    '::selection', '::placeholder', '::before', '::after', '::marker',
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

async function main() {
  if (!fs.existsSync(cssFile)) {
    console.error(`PurgeCSS: 未找到 ${cssFile}，请先执行 hexo generate`);
    process.exit(1);
  }

  const original = fs.readFileSync(cssFile, 'utf-8');
  const result = await new PurgeCSS().purge({
    content: [
      path.join(publicDir, '**/*.html'),
      path.join(publicDir, '**/*.js')
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
  console.log(`PurgeCSS: main.css ${(original.length / 1024).toFixed(1)}KB → ${(result[0].css.length / 1024).toFixed(1)}KB, removed ${rejected.length} selectors`);
}

// 仅作为独立脚本执行时运行；被 Hexo 加载 scripts/ 目录时 require.main !== module，不执行
if (require.main === module) {
  main().catch(err => {
    console.error(err);
    process.exit(1);
  });
}
