// 友链页生成器：读取 source/_data/links.yml，渲染 /links/ 页面
// 维护友链只需要编辑 source/_data/links.yml，无需动任何页面代码
hexo.extend.generator.register('links', function (locals) {
  const links = (locals.data && locals.data.links) || [];

  return {
    path: 'links/index.html',
    layout: ['links', 'page'],
    data: {
      title: '友链',
      subtitle: '常来往，皆是朋友',
      links: links,
      comments: true
    }
  };
});
