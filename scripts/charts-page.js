// 数据图表页生成器：统计分类/标签/年份分布与总字数，渲染 /charts/ 页面
// 纯构建期计算 + CSS 条形图，不引入外部图表库，保持零外链
'use strict';

const { stripHTML } = require('hexo-util');

function toRows(map, maxRows) {
  const counts = Object.keys(map).map(function (k) { return map[k]; });
  const max = Math.max.apply(null, counts.concat([1]));
  return Object.keys(map)
    .map(function (name) {
      return {
        name: name,
        count: map[name],
        percent: Math.round(map[name] / max * 1000) / 10
      };
    })
    .sort(function (a, b) { return b.count - a.count; })
    .slice(0, maxRows || Object.keys(map).length);
}

hexo.extend.generator.register('charts', function (locals) {
  const posts = locals.posts.toArray();

  const byCategory = {};
  const byTag = {};
  const byYear = {};
  let totalWords = 0;

  posts.forEach(function (post) {
    const year = String(post.date.year());
    byYear[year] = (byYear[year] || 0) + 1;

    if (post.categories && post.categories.length) {
      post.categories.each(function (c) {
        byCategory[c.name] = (byCategory[c.name] || 0) + 1;
      });
    } else {
      byCategory['未分类'] = (byCategory['未分类'] || 0) + 1;
    }

    if (post.tags && post.tags.length) {
      post.tags.each(function (t) {
        byTag[t.name] = (byTag[t.name] || 0) + 1;
      });
    }

    totalWords += stripHTML(post.content).replace(/\s+/g, '').length;
  });

  return {
    path: 'charts/index.html',
    layout: ['charts', 'page'],
    data: {
      title: '数据图表',
      subtitle: '用数字记录写作的痕迹',
      totalWords: totalWords,
      categories: toRows(byCategory),
      tags: toRows(byTag, 10),
      years: toRows(byYear).sort(function (a, b) { return a.name.localeCompare(b.name); }),
      comments: false
    }
  };
});
