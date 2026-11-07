// 私密分类：文章归入「私密」分类后全站隐藏，仅 /secret/ 密码门可达
// 依赖 hexo-hide-posts（hidden 标记 + 生成器白名单），配置见根 _config.yml
// 密码来源：构建环境变量 SECRET_CATEGORY_PASSWORD（GitHub Actions Secret / 本地 export）
// 门页逻辑：文章列表在构建期用 AES-256-GCM 加密，浏览器输密码后本地解密渲染
'use strict';

const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

const cfg = hexo.config.secret_category || {};
const NAME = cfg.name || '私密';
const URL_PATH = (cfg.url || 'secret').replace(/\/+$/, '') + '/';
const PASSWORD = process.env.SECRET_CATEGORY_PASSWORD || cfg.password || '';

// 启动时同步私密内容：.secret-content（私有仓库本地克隆，gitignored）→ source/_posts/secret/
// 必须在 Hexo 扫描 source 之前完成（脚本加载早于 load 阶段）；目录不存在则跳过（公开仓库独立构建）
(function syncSecretContent() {
  const src = process.env.SECRET_CONTENT_DIR
    ? path.resolve(process.env.SECRET_CONTENT_DIR)
    : path.join(hexo.base_dir, '.secret-content', 'posts');
  const dest = path.join(hexo.source_dir, '_posts', 'secret');
  if (!fs.existsSync(src)) return;
  fs.mkdirSync(dest, { recursive: true });
  // 全量同步：先清后拷，保证私有仓库里删除的文章本地也消失
  for (const f of fs.readdirSync(dest)) {
    if (f.endsWith('.md')) fs.unlinkSync(path.join(dest, f));
  }
  let n = 0;
  for (const f of fs.readdirSync(src)) {
    if (f.endsWith('.md')) {
      fs.copyFileSync(path.join(src, f), path.join(dest, f));
      n++;
    }
  }
  hexo.log.info('secret-category: 已同步 %d 篇私密文章', n);
})();

// AES-256-GCM 加密，载荷 base64(salt[16] + iv[12] + ciphertext + tag[16])，与浏览器 WebCrypto 对齐
// 盐固定不随机：浏览器只在门页派生一次密钥并存入会话，之后各文章页共用同一把密钥；
// 若每次构建换盐，缓存了旧页面的浏览器会派生出一把不同的密钥导致解密失败
const BUILD_SALT = crypto.createHash('sha256').update('muyblog-secret-salt-v1').digest().subarray(0, 16);
function encryptPayload(plainText) {
  const iv = crypto.randomBytes(12);
  const key = crypto.pbkdf2Sync(PASSWORD, BUILD_SALT, 120000, 32, 'sha256');
  const c = crypto.createCipheriv('aes-256-gcm', key, iv);
  const ct = Buffer.concat([c.update(Buffer.from(plainText, 'utf8')), c.final()]);
  return Buffer.concat([BUILD_SALT, iv, ct, c.getAuthTag()]).toString('base64');
}

// 判断一篇文章是否属于私密分类
hexo.secret_is = function (post) {
  if (!post || !post.categories || !post.categories.length) return false;
  let found = false;
  post.categories.each(c => {
    if (c.name === NAME) found = true;
  });
  return found;
};

// 自动打标记：属于私密分类的文章写入 hidden: true（hide-posts 据此隐藏）
// 挂点必须是 after_post_render：load 阶段逐篇触发且早于入库，
// 赶在 hide-posts 的 before_generate 拆分之前；after_init 时数据库还是空的
hexo.extend.filter.register('after_post_render', function (data) {
  if (data.layout !== 'post' || data.hidden) return data;
  if (hexo.secret_is(data)) {
    data.hidden = true;
    // 构建期整页加密：部署产物里只存密文，curl/查看源代码也读不到正文；
    // 浏览器端由 body-end.swig 用会话密钥（门页解锁时存入）解密
    if (PASSWORD && data.content) {
      data.content = '<div class="secret-post" data-cipher="'
        + encryptPayload(data.content) + '"></div>\n<!-- flag of hidden posts -->';
    } else if (data.content && data.content.indexOf('<!-- flag of hidden posts -->') === -1) {
      // 本地无密码开发模式：保留明文，但 hide-posts 追加 flag 的钩子先于本站脚本执行，
      // 等它再看到 hidden 标记时已错过时机，这里自己补上 flag，
      // 供其 after_render:html 注入 noindex、以及前端守卫识别私密文章页
      data.content += '\n<!-- flag of hidden posts -->';
    }
    // 防 meta description / 摘要带出正文开头
    data.excerpt = '';
    data.description = '';
    hexo.log.info('secret-category: 已隐藏并加密私密文章「%s」', data.title);
  }
  return data;
});

// 渲染期保险：分类/标签生成器会把文章烤进 page.posts，逐页剥掉私密文章
// （hexo-hide-posts 已处理 locals.posts 与生成器，这里兜住 data 烤入的漏网）
// 同时过滤 site.categories / site.tags：分类总览、标签云、侧栏都从这里取数，
// 只保留「至少有一篇公开文章」的分类/标签，hide-posts 不管这一层
hexo.extend.filter.register('template_locals', function (locals) {
  const page = locals.page;
  if (page && page.layout !== 'secret-category' && page.posts && page.posts.filter) {
    page.posts = page.posts.filter(p => !hexo.secret_is(p));
  }
  if (!locals.site) return locals;
  const hasPublic = entry => {
    let ok = false;
    if (entry.posts && entry.posts.each) {
      entry.posts.each(p => {
        if (!p.hidden && !hexo.secret_is(p)) ok = true;
      });
    }
    return ok;
  };
  const site = Object.create(locals.site);
  site.categories = hexo.model('Category').filter(hasPublic);
  site.tags = hexo.model('Tag').filter(hasPublic);
  locals.site = site;
  return locals;
});

// 模板 helper：分类/标签是否还有公开文章（决定其页面是否存在）
// 私密文章所在的分类、以及「只含私密文章（或被 hide-posts 隐藏）」的分类/标签都不生成页面，
// 模板据此把链接降级为纯文本，避免 /categories/私密/、/tags/测试/ 这类死链
hexo.extend.helper.register('has_public_posts', function (entry) {
  if (!entry || !entry.posts || typeof entry.posts.each !== 'function') return false;
  let ok = false;
  entry.posts.each(p => {
    if (p && !p.hidden && !hexo.secret_is(p)) ok = true;
  });
  return ok;
});

// 私密入口页生成器（生成器名 secret-page 必须与 hide_posts.allowlist_generators 一致，
// 才能拿到全量文章——生成器收到的 locals.posts 由 hide-posts 包装注入）
hexo.extend.generator.register('secret-page', function (locals) {
  const posts = locals.posts.filter(p => hexo.secret_is(p))
    .sort('-date')
    .map(p => ({ t: p.title, u: p.path.replace(/index\.html$/, ''), d: p.date.format('YYYY-MM-DD') }));

  let locked = true;
  let cipher = '';
  let postsJson = '';

  if (!posts.length) {
    locked = false;
  } else if (PASSWORD) {
    cipher = encryptPayload(JSON.stringify(posts));
  } else {
    locked = false;
    postsJson = JSON.stringify(posts);
    if (process.env.CI) {
      hexo.log.error('SECRET_CATEGORY_PASSWORD 未设置，私密分类将明文构建——CI 环境拒绝发布');
      throw new Error('SECRET_CATEGORY_PASSWORD is required in CI');
    }
    hexo.log.warn('SECRET_CATEGORY_PASSWORD 未设置，/secret/ 列表将以明文渲染（仅限本地开发）');
  }

  return {
    path: URL_PATH,
    layout: ['secret-category', 'page'],
    data: {
      title: NAME,
      subtitle: '不对外公开的自留地',
      locked: locked,
      cipher: cipher,
      posts_json: postsJson,
      comments: false
    }
  };
});
