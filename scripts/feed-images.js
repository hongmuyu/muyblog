'use strict';

/**
 * RSS/Atom 图片修复。
 *
 * 背景：themes/next/scripts/filters/post.js 的 after_post_render 会把正文里所有
 * `<img src=` 改成 `<img data-src=`（供 lozad 懒加载）。但 hexo-generator-feed
 * 直接复用同一份 post.content 生成 atom.xml，而 RSS 阅读器不执行 JS，
 * 导致订阅源里的图片全部无法显示。
 *
 * 做法：在 after_generate 阶段读出已生成的 feed XML（这是一份副本，不触碰
 * post.content），把 data-src 还原为 src，并把相对路径补成绝对地址。
 * 文章页仍保留 data-src，lozad 懒加载不受影响。
 */

const { full_url_for } = require('hexo-util');

function readStream(stream) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    stream.on('data', chunk => chunks.push(Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk)));
    stream.on('error', reject);
    stream.on('end', () => resolve(Buffer.concat(chunks).toString('utf8')));
  });
}

function absolutize(src, ctx) {
  if (!src) return src;
  if (/^(?:https?:)?\/\//i.test(src) || /^(?:data|mailto):/i.test(src)) return src;
  return full_url_for.call(ctx, src);
}

function restoreImages(xml, ctx) {
  return xml.replace(/<img\b[^>]*>/gi, tag => {
    let result = tag;
    // 没有 src 时把 data-src 还原为 src；已有 src 则直接走绝对化
    if (!/\ssrc=/i.test(result)) {
      result = result.replace(/\sdata-src=/i, ' src=');
    }
    const match = result.match(/\ssrc=(["'])(.*?)\1/i);
    if (match && match[2]) {
      const absolute = absolutize(match[2], ctx);
      if (absolute !== match[2]) {
        result = result.replace(/\ssrc=(["']).*?\1/i, ` src="${absolute}"`);
      }
    }
    return result;
  });
}

hexo.extend.filter.register('after_generate', function () {
  const feedConfig = hexo.config.feed;
  if (!feedConfig || feedConfig.content === false) return;
  const feedPath = feedConfig.path || 'atom.xml';
  const stream = hexo.route.get(feedPath);
  if (!stream) return;
  return readStream(stream).then(xml => {
    const fixed = restoreImages(xml, { config: hexo.config });
    if (fixed !== xml) hexo.route.set(feedPath, fixed);
  });
});
