'use strict';

/**
 * 主题 D（P2-12）：meta description 生成。
 *
 * 策略（B+C）：
 * - 文章页：front-matter 写了 description 的，直接沿用（B，由 Sveltia 后台维护）；
 *   缺失时从正文首段提取纯文本兜底（C）。
 * - 列表页：构建期按页面类型模板生成（首页为站点介绍，分类/归档带数量）。
 *
 * 约束：
 * - 不得与 post.swig 的 post.description 渲染冲突，因此本脚本写入独立字段
 *   page.seo_description，仅由 head-unique.swig 传给 open_graph()；
 * - 私密分类文章一律跳过（hexo.secret_is），避免正文内容进入 meta；
 * - 长度为 120–160 字符，优先在句末标点（。？！）处自然断句，不做省略号硬截断。
 */

const HOME_DESC = '木与宁的小站，记录学习笔记、踩坑经验与生活随想。用 Hexo 生成静态页面、'
  + 'GitHub Pages 托管、GitHub Actions 自动部署，没有服务器与数据库；'
  + '配合 Sveltia 网页后台，电脑和手机上都能随时写作，也欢迎通过 RSS 订阅更新。';

const MIN_LEN = 120;
const MAX_LEN = 160;

const ENTITY_MAP = {
  '&nbsp;': ' ', '&amp;': '&', '&lt;': '<', '&gt;': '>', '&quot;': '"',
  '&#39;': '\'', '&ldquo;': '“', '&rdquo;': '”', '&lsquo;': '‘', '&rsquo;': '’',
  '&hellip;': '…', '&mdash;': '—', '&ndash;': '–'
};

function decodeEntities(str) {
  return str
    .replace(/&(?:nbsp|amp|lt|gt|quot|#39|ldquo|rdquo|lsquo|rsquo|hellip|mdash|ndash);/g, m => ENTITY_MAP[m] || m)
    .replace(/&#(\d+);/g, (m, d) => String.fromCodePoint(Number(d)));
}

// 从渲染后的正文 HTML 提取首段纯文本（去图片/代码块/标题/引用/列表/表格）
function extractParagraphs(html) {
  let s = String(html || '');
  s = s.replace(/<script[\s\S]*?<\/script>/gi, ' ');
  s = s.replace(/<style[\s\S]*?<\/style>/gi, ' ');
  s = s.replace(/<figure[\s\S]*?<\/figure>/gi, ' ');      // 代码块与图片图注
  s = s.replace(/<pre[\s\S]*?<\/pre>/gi, ' ');
  s = s.replace(/<blockquote[\s\S]*?<\/blockquote>/gi, ' '); // 引用
  s = s.replace(/<h[1-6][^>]*>[\s\S]*?<\/h[1-6]>/gi, ' ');   // 标题
  s = s.replace(/<img[\s\S]*?>/gi, ' ');
  s = s.replace(/<table[\s\S]*?<\/table>/gi, ' ');
  s = s.replace(/<ul[\s\S]*?<\/ul>/gi, ' ');
  s = s.replace(/<ol[\s\S]*?<\/ol>/gi, ' ');
  s = s.replace(/<div[^>]*class="[^"]*(?:hide|more)[^"]*"[\s\S]*?<\/div>/gi, ' ');

  const result = [];
  const re = /<p(?:\s[^>]*)?>([\s\S]*?)<\/p>/gi;
  let m;
  while ((m = re.exec(s)) !== null) {
    const text = decodeEntities(m[1].replace(/<br\s*\/?>/gi, ' ').replace(/<[^>]+>/g, ''))
      .replace(/\s+/g, ' ')
      .trim();
    if (text) result.push(text);
  }
  return result;
}

// 自然断句：在 120–160 字符内优先截到句末标点，不用省略号
function cutNaturally(text) {
  const chars = Array.from(text);
  if (chars.length <= MAX_LEN) return chars.join('');

  const head = chars.slice(0, MAX_LEN);
  let lastPunct = -1;
  for (const p of ['。', '？', '！']) {
    const i = head.lastIndexOf(p);
    if (i > lastPunct) lastPunct = i;
  }
  if (lastPunct + 1 >= MIN_LEN) return head.slice(0, lastPunct + 1).join('');

  // 160 内没有合适断点：取 120 之后第一个句末标点（可能略超 160）
  const tail = chars.slice(MIN_LEN);
  const idx = tail.findIndex(c => '。？！'.includes(c));
  if (idx >= 0) return chars.slice(0, MIN_LEN + idx + 1).join('');

  return head.join('');
}

function buildFromContent(html) {
  const paragraphs = extractParagraphs(html);
  if (!paragraphs.length) return '';

  let text = '';
  for (const p of paragraphs) {
    text = text ? `${text} ${p}` : p;
    if (Array.from(text).length >= MIN_LEN) break;
  }
  return cutNaturally(text);
}

const isSecretPost = post => typeof hexo.secret_is === 'function' && hexo.secret_is(post);

function toArray(query) {
  if (!query) return [];
  if (typeof query.toArray === 'function') return query.toArray();
  return Array.from(query);
}

// 归档页：数量 + 年份跨度 + 最新文章标题
function buildArchiveDesc(posts, siteTitle) {
  const list = toArray(posts).filter(p => p && !isSecretPost(p));
  if (!list.length) return `归档 - 共 0 篇文章 - ${siteTitle}`;

  const sorted = [...list].sort((a, b) => b.date.valueOf() - a.date.valueOf());
  const newest = sorted[0].date.format('YYYY');
  const oldest = sorted[sorted.length - 1].date.format('YYYY');
  const range = newest === oldest ? `${newest} 年` : `${oldest} 至 ${newest} 年`;
  return `共 ${list.length} 篇文章，覆盖 ${range}，最新为「${sorted[0].title}」。`;
}

// 分类页：优先分类自身描述；否则用前 3 个高频标签概括主题
function buildCategoryDesc(category, posts, siteTitle) {
  if (category && category.description) return category.description;

  const name = category ? category.name : '';
  const list = toArray(posts).filter(p => p && !isSecretPost(p));
  const counts = new Map();
  list.forEach(post => {
    toArray(post.tags).forEach(tag => {
      counts.set(tag.name, (counts.get(tag.name) || 0) + 1);
    });
  });
  const top = [...counts.entries()]
    .sort((a, b) => b[1] - a[1])
    .slice(0, 3)
    .map(([tagName]) => tagName);
  // 分类下文章暂无标签时退回站点名，避免描述过短
  const tail = top.length ? `，涵盖 ${top.join('、')} 等主题` : ` - ${siteTitle}`;
  return `「${name}」分类下共 ${list.length} 篇文章${tail}。`;
}

// 文章页：仅处理 front-matter 无 description 的公开文章
hexo.extend.filter.register('before_generate', function () {
  const posts = hexo.locals.get('posts');
  let count = 0;
  posts.forEach(post => {
    if (!post || post.seo_description || post.description) return;
    if (typeof hexo.secret_is === 'function' && hexo.secret_is(post)) return;
    const text = buildFromContent(post.content);
    if (!text) return;
    post.seo_description = text;
    count++;
  });
  if (count) hexo.log.info('seo-description: 为 %d 篇文章自动生成 meta description', count);
}, 20);

// 分享卡片图（og:image）：只取首图——front-matter image/photos 优先，
// 否则正文第一张 <img>（after_post_render 已在此钩子前执行，拿到的已是 .webp 路径），
// 都没有时退回站点级 og_image（_config.yml，当前未配置则不输出 og:image）。
// 私密文章跳过：正文为密文，且不向外暴露任何媒体引用。
const FIRST_IMG_RE = /<img [^>]*src=['"]([^'"]+)['"]/i;
hexo.extend.filter.register('before_generate', function () {
  const posts = hexo.locals.get('posts');
  posts.forEach(post => {
    if (!post || post.seo_image) return;
    if (typeof hexo.secret_is === 'function' && hexo.secret_is(post)) return;
    const fm = post.image || (post.photos && post.photos.length ? post.photos[0] : null);
    if (fm) { post.seo_image = fm; return; }
    const m = FIRST_IMG_RE.exec(post.content || '');
    if (m) post.seo_image = m[1];
    else if (hexo.config.og_image) post.seo_image = hexo.config.og_image;
  });
}, 20);

// 列表页：按页面类型生成
// 注：生成器产出的列表页 page.layout 为空（静态页才是 'page'），故按 path 判定
hexo.extend.filter.register('template_locals', function (locals) {
  const page = locals.page;
  if (!page || page.seo_description) return locals;

  const path = page.path || '';
  const siteTitle = hexo.config.title || '';

  if (path === 'index.html' || path.startsWith('page/')) {
    // 首页（含分页）
    page.seo_description = HOME_DESC;
  } else if (path.startsWith('archives/')) {
    // 归档总览与按年/月归档
    page.seo_description = buildArchiveDesc(page.posts, siteTitle);
  } else if (page.category) {
    // 单个分类页：分类自身描述优先，否则按标签概括
    const category = locals.site && locals.site.categories
      ? locals.site.categories.findOne({ name: page.category })
      : null;
    page.seo_description = buildCategoryDesc(category, page.posts, siteTitle);
  } else if (path === 'categories/index.html') {
    // 分类总览页
    const siteCats = locals.site && locals.site.categories;
    const n = siteCats ? siteCats.length : 0;
    page.seo_description = `全站文章分类总览 - 共 ${n} 个分类 - ${siteTitle}`;
  }

  return locals;
});
