// 碎碎念页生成器：读取 source/_data/moments.yml，渲染 /moments/ 页面
'use strict';

hexo.extend.generator.register('moments', function (locals) {
  const data = (locals.data && locals.data.moments) || {};
  const items = (data.items || [])
    .slice()
    .sort(function (a, b) { return String(b.date).localeCompare(String(a.date)); });

  return {
    path: 'moments/index.html',
    layout: ['moments', 'page'],
    data: {
      title: '碎碎念',
      subtitle: '不够写成文章的小瞬间，都记在这里',
      moments: items,
      comments: false
    }
  };
});
