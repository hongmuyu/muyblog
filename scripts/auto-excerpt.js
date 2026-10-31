// 自动摘要：未填写 description（CMS 里的“摘要描述”）的文章，
// 截取正文前 N 字纯文本作为首页摘要，让每篇文章都有“阅读全文”按钮。
// 手写的 description 优先级更高，不会被覆盖。
'use strict';

const { stripHTML } = require('hexo-util');

const EXCERPT_LENGTH = 150;

hexo.extend.filter.register('after_post_render', (data) => {
  if (data.layout !== 'post') return data;
  if (data.description || data.excerpt) return data;

  const text = stripHTML(data.content).replace(/\s+/g, ' ').trim();
  if (!text) return data;

  data.excerpt = text.length > EXCERPT_LENGTH
    ? text.slice(0, EXCERPT_LENGTH) + '…'
    : text;
  return data;
});
