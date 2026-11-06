// 站点统计辅助函数：供侧栏显示「本站总字数」和「最后更新时间」
'use strict';

const { stripHTML } = require('hexo-util');

function getPosts(context) {
  return (context && context.site && context.site.posts) || hexo.locals.get('posts');
}

hexo.extend.helper.register('site_total_words', function () {
  let total = 0;
  getPosts(this).each(function (post) {
    total += stripHTML(post.content).replace(/\s+/g, '').length;
  });
  return total >= 10000 ? (total / 10000).toFixed(1) + '万' : String(total);
});

hexo.extend.helper.register('site_last_updated', function () {
  let last = 0;
  getPosts(this).each(function (post) {
    const t = (post.updated && post.updated.valueOf()) || post.date.valueOf();
    if (t > last) last = t;
  });
  return last;
});
