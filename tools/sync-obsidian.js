'use strict';

/**
 * 把 Obsidian 知识库里的技术笔记同步成 Hexo 文章。
 *
 * 设计原则：
 * 1. 只发布白名单目录下的笔记，私人目录（简历、复盘、Pictures 等）永不进入博客；
 * 2. 自动剔除目录页（Waypoint）、空笔记、过短笔记、带 publish:false/draft/private 标记的笔记；
 * 3. 处理 Obsidian 专有语法：![[图片]] 拷贝并改写、[[笔记]] 转站内链接、%%注释%% 删除、
 *    正文 H1 降级为 H2（博客标题本身占一个 H1）、--- 分隔线规范化；
 * 4. 输出到独立目录 source/_posts/obsidian 与 source/images/obsidian，
 *    每次同步先清空再重建，避免残留旧文章。
 *
 * 用法：npm run sync:notes
 * 库路径可用环境变量 OBSIDIAN_VAULT 覆盖。
 */

const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

const ROOT = path.resolve(__dirname, '..');
const VAULT = path.resolve(process.env.OBSIDIAN_VAULT || '/home/abc/tools/Obsidian');
const POST_DIR = path.join(ROOT, 'source/_posts/obsidian');
const IMAGE_DIR = path.join(ROOT, 'source/images/obsidian');

// 白名单：只有这些目录（含子目录）下的笔记才会发布。新增目录在这里加一行即可。
const FOLDERS = [
  { dir: '代码', category: '🧮 算法与编程' },
  { dir: 'programming', category: '🧮 算法与编程' },
  { dir: 'FastAPI&MySQL', category: '🐍 Web 后端' },
  { dir: 'server', category: '🛠️ 服务器与运维' },
  { dir: 'terminal', category: '🛠️ 服务器与运维' },
  { dir: 'environment', category: '🛠️ 服务器与运维' },
  { dir: 'tools', category: '🛠️ 开发工具' },
  { dir: 'models', category: '🤖 大模型与 AI' },
  { dir: '实习技能', category: '🤖 大模型与 AI' },
  { dir: 'proj', category: '🚀 项目实战' },
];

// 白名单目录内部仍需排除的路径（隐私 / 个人向内容）。
const EXCLUDE_PATHS = [
  '实习技能/简历',
  '实习技能/职业规划.md',
  // 明显没写完 / 只是提示词草稿的笔记
  '实习技能/Fastapi/sum.md',
  '实习技能/项目开发流程/04开发遇到阻断.md',
];

const MIN_CHARS = 300; // 正文去空白后的最小字数，低于此视为未写完
const GENERIC_TITLE = new Set([
  'readme', 'index', 'prd', 'process', '未命名', '无标题', 'untitled', '新建笔记',
]);
const SKIP_DIRS = new Set(['.git', '.obsidian', '.remember', '.idea', 'node_modules', '.trash']);
const IMAGE_EXT = /\.(png|jpe?g|gif|webp|svg)$/i;

const warnings = [];
const skipped = [];
const published = [];

function walk(dir, out = []) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (SKIP_DIRS.has(entry.name)) continue;
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) walk(full, out);
    else out.push(full);
  }
  return out;
}

function relOf(file) {
  return path.relative(VAULT, file).split(path.sep).join('/');
}

function parseFrontMatter(text) {
  const match = text.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n?/);
  if (!match) return { data: {}, body: text };
  const data = {};
  for (const line of match[1].split(/\r?\n/)) {
    const m = line.match(/^([A-Za-z0-9_-]+)\s*:\s*(.*)$/);
    if (!m) continue;
    let value = m[2].trim();
    if (/^".*"$/.test(value) || /^'.*'$/.test(value)) value = value.slice(1, -1);
    data[m[1].toLowerCase()] = value;
  }
  return { data, body: text.slice(match[0].length) };
}

function nonSpaceLength(text) {
  return text.replace(/\s/g, '').length;
}

function isExcluded(rel) {
  return EXCLUDE_PATHS.some((p) => rel === p || rel.startsWith(p + '/'));
}

function isPrivate(rel, data) {
  if (data.private === 'true' || data.draft === 'true' || data.publish === 'false') return '笔记标记为私密/草稿';
  if (isExcluded(rel)) return '命中排除清单（隐私/未完成）';
  return null;
}

function stripNoise(text) {
  return text
    .replace(/[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE0F}]/gu, '')
    .replace(/\s+/g, ' ')
    .trim();
}

function deriveTitle(rel, data, body) {
  if (data.title) return { title: stripNoise(data.title), removeLine: null };
  const base = path.posix.basename(rel).replace(/\.md$/i, '');
  if (GENERIC_TITLE.has(base.toLowerCase())) {
    const m = body.match(/^#\s+(.+)$/m);
    if (m) {
      let title = stripNoise(m[1]);
      const parent = path.posix.basename(path.posix.dirname(rel));
      if (parent && !title.includes(parent)) title = `${parent} ${title}`;
      return { title, removeLine: m[0] };
    }
    return { title: base, removeLine: null };
  }
  return { title: stripNoise(base), removeLine: null };
}

function pad(n) {
  return String(n).padStart(2, '0');
}

function formatDate(timestamp) {
  const d = new Date(timestamp);
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`;
}

const gitDateCache = new Map();
function gitDates(rel) {
  if (gitDateCache.has(rel)) return gitDateCache.get(rel);
  const result = { created: null, updated: null };
  try {
    const out = execFileSync('git', ['-C', VAULT, 'log', '--format=%ct', '--', rel], {
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'ignore'],
    }).trim();
    if (out) {
      const stamps = out.split('\n').map(Number).filter(Boolean);
      result.created = stamps[stamps.length - 1];
      result.updated = stamps[0];
    }
  } catch (e) {
    // 库不是 git 仓库或文件未跟踪时，退回文件修改时间
  }
  gitDateCache.set(rel, result);
  return result;
}

function noteDates(rel, absPath) {
  const git = gitDates(rel);
  const mtime = fs.statSync(absPath).mtimeMs;
  return {
    created: git.created ? git.created * 1000 : mtime,
    updated: Math.max(git.updated ? git.updated * 1000 : 0, mtime),
  };
}

function sanitizeFileName(name) {
  return name.replace(/[\\/:*?"<>|]/g, '-').replace(/\s+/g, '-').replace(/-+/g, '-');
}

const usedSlugs = new Set();

// 文章永久链接用的短 slug：稳定、唯一、去掉标点；重名时追加序号
function titleSlug(title) {
  let slug = title
    .replace(/[\\/:*?"<>|#%&{}$!'@+`=,.;!?，。、：；（）【】《》〈〉「」『』]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-|-$/g, '')
    .slice(0, 60)
    .replace(/^-|-$/g, '');
  if (!slug) slug = 'note';
  let candidate = slug;
  let index = 2;
  while (usedSlugs.has(candidate.toLowerCase())) {
    candidate = `${slug}-${index}`;
    index += 1;
  }
  usedSlugs.add(candidate.toLowerCase());
  return candidate;
}

// ---------- 图片索引 ----------

const imageByRel = new Map();
const imageByBase = new Map();

function indexImages() {
  for (const file of walk(VAULT)) {
    if (!IMAGE_EXT.test(file)) continue;
    const rel = relOf(file);
    imageByRel.set(rel.toLowerCase(), file);
    const base = path.posix.basename(rel).toLowerCase();
    if (!imageByBase.has(base)) imageByBase.set(base, file);
  }
}

function resolveImage(target, fromRel) {
  const key = target.replace(/\\/g, '/').replace(/^\.\//, '').toLowerCase();
  if (imageByRel.has(key)) return imageByRel.get(key);
  const dir = path.posix.dirname(fromRel);
  const sibling = (dir === '.' ? '' : dir + '/') + key;
  if (imageByRel.has(sibling.toLowerCase())) return imageByRel.get(sibling);
  const base = key.split('/').pop();
  return imageByBase.get(base) || null;
}

const usedImageNames = new Map();
function copyImage(source, slug) {
  const dir = path.join(IMAGE_DIR, slug);
  fs.mkdirSync(dir, { recursive: true });
  const used = usedImageNames.get(slug) || new Set();
  usedImageNames.set(slug, used);
  let name = sanitizeFileName(path.basename(source));
  let index = 1;
  while (used.has(name)) {
    const ext = path.extname(name);
    name = sanitizeFileName(path.basename(source, ext)) + '-' + index + ext;
    index += 1;
  }
  used.add(name);
  fs.copyFileSync(source, path.join(dir, name));
  return `/images/obsidian/${slug}/${name}`;
}

// ---------- 内容转换 ----------

function splitFences(text) {
  // 围栏代码块与行内代码都要保护，避免把 Python 里的 == 当成 Obsidian 高亮
  return text.split(/(```[\s\S]*?```|~~~[\s\S]*?~~~|`[^`\n]*`)/g);
}

function mapOutsideFences(text, fn) {
  return splitFences(text)
    .map((segment, index) => (index % 2 === 1 ? segment : fn(segment)))
    .join('');
}

function normalizeSeparators(segment) {
  const lines = segment.split('\n');
  const output = [];
  for (const line of lines) {
    if (/^([-*_])\1{2,}$/.test(line.trim())) {
      if (output.length && output[output.length - 1] !== '') output.push('');
      output.push('---');
      output.push('');
    } else {
      output.push(line);
    }
  }
  return output.join('\n');
}

function normalizeHeadingLevels(text) {
  const segments = splitFences(text);
  const stack = [];
  const headingRe = /^(#{1,6})\s+/gm;

  // 按出现顺序重排标题层级：第一个标题固定为 H2（H1 留给文章标题），
  // 后续标题不跳级（出现更深层级时只加深一级，回退时按栈收敛）。
  return segments
    .map((segment, index) => {
      if (index % 2 === 1) return segment;
      return segment.replace(headingRe, (all, hashes) => {
        const level = hashes.length;
        while (stack.length && stack[stack.length - 1] >= level) stack.pop();
        stack.push(level);
        const mapped = Math.min(Math.max(2, stack.length + 1), 6);
        return '#'.repeat(mapped) + ' ';
      });
    })
    .join('');
}

function transformContent(body, ctx) {
  let titleLineRemoved = false;

  const transformed = mapOutsideFences(body, (segment) => {
    // Obsidian 注释 %% ... %%
    segment = segment.replace(/%%[\s\S]*?%%/g, '');

    // ![[图片]] -> 标准图片，拷贝到博客
    segment = segment.replace(/!\[\[([^\]\n]+)\]\]/g, (original, inner) => {
      const [targetRaw, ...aliasParts] = inner.split('|');
      const alias = aliasParts.join('|').trim();
      const target = targetRaw.trim();
      if (!IMAGE_EXT.test(target)) {
        warnings.push(`${ctx.rel}: 非图片附件 "${target}" 暂不处理`);
        return original;
      }
      const source = resolveImage(target, ctx.rel);
      if (!source) {
        warnings.push(`${ctx.rel}: 找不到图片 "${target}"`);
        return `*[缺图：${target}]*`;
      }
      const url = copyImage(source, ctx.slug);
      return `![${alias || path.basename(target)}](${url})`;
    });

    // [[笔记]] / [[笔记|别名]] / [[笔记#小节]] -> 站内链接或纯文本
    segment = segment.replace(/(?<!!)\[\[([^\]\n]+)\]\]/g, (original, inner) => {
      const [targetRaw, ...aliasParts] = inner.split('|');
      const alias = aliasParts.join('|').trim();
      const [notePart, ...sectionParts] = targetRaw.split('#');
      const section = sectionParts.join('#').trim();
      const noteName = notePart.trim();
      if (!noteName) return alias || section;

      const target = resolvePublishedNote(noteName, ctx.rel);
      const display = alias || noteName.replace(/\.md$/i, '') || section;
      if (!target) return display;
      return display === target.title
        ? `{% post_link ${JSON.stringify(target.title)} %}`
        : `{% post_link ${JSON.stringify(target.title)} ${JSON.stringify(display)} %}`;
    });

    // Obsidian 高亮 ==text==
    segment = segment.replace(/==([^=\n]+)==/g, '<mark>$1</mark>');

    // 块引用标识 ^block-id
    segment = segment.replace(/\s+\^[A-Za-z0-9_-]+\s*$/gm, '');

    // 行级处理：标题行、分隔线、H1 降级
    let text = normalizeSeparators(segment);
    const lines = text.split('\n').map((line) => line.replace(/\s+$/, ''));
    const result = [];
    for (const line of lines) {
      if (!titleLineRemoved && ctx.removeLine && line.trim() === ctx.removeLine.trim()) {
        titleLineRemoved = true;
        continue;
      }
      // 博客标题本身是 H1，正文顶层标题统一降为 H2，避免一页多个 H1
      result.push(line.replace(/^#\s+(.+)$/, '## $1'));
    }
    text = result.join('\n');
    return text.replace(/\n{3,}/g, '\n\n');
  })
    .replace(/^\s*(?:---\s*\n)+/, '')
    .replace(/\n+(?:---\s*\n*)+\s*$/, '')
    .trim();

  // 优化：正文里 1x1 追踪像素这类编辑器残留直接去掉
  const cleaned = transformed.replace(/!\[[^\]]*\]\(data:image\/gif;base64,[^)]*\)/g, '');
  return normalizeHeadingLevels(cleaned);
}

// ---------- 图片后处理：生成 WebP 并改写引用 ----------

async function convertImagesToWebp() {
  let sharp = null;
  try {
    sharp = require('sharp');
  } catch (e) {
    warnings.push('sharp 不可用，本次跳过 WebP 转换');
    return;
  }

  const bitmaps = walk(IMAGE_DIR).filter((file) => /\.(png|jpe?g)$/i.test(file));
  for (const file of bitmaps) {
    const webp = file.replace(/\.(png|jpe?g)$/i, '.webp');
    try {
      let image = sharp(file);
      const meta = await image.metadata();
      if (meta.width > 1200) image = image.resize({ width: 1200 });
      await image.webp({ quality: 85 }).toFile(webp);
    } catch (e) {
      warnings.push(`WebP 转换失败 ${path.relative(ROOT, file)}: ${e.message}`);
    }
  }

  // 把生成文章里的 png/jpg 引用改写成 WebP（原图仍保留在仓库）
  for (const post of walk(POST_DIR).filter((file) => file.endsWith('.md'))) {
    const text = fs.readFileSync(post, 'utf8');
    const next = text.replace(
      /(\/images\/obsidian\/[^)\s"']+?)\.(png|jpe?g)/gi,
      (match, prefix, ext) => {
        const webp = path.join(ROOT, 'source', prefix + '.webp');
        return fs.existsSync(webp) ? prefix + '.webp' : match;
      }
    );
    if (next !== text) fs.writeFileSync(post, next, 'utf8');
  }
}

// ---------- 笔记索引与主流程 ----------

const publishedByRel = new Map();
const publishedByBase = new Map();

function resolvePublishedNote(target, fromRel) {
  let key = target.replace(/\\/g, '/').replace(/^\.\//, '');
  key = key.replace(/\.md$/i, '').toLowerCase();
  const dir = path.posix.dirname(fromRel);
  const sibling = (dir === '.' ? '' : dir + '/') + key;
  if (publishedByRel.has(sibling.toLowerCase())) return publishedByRel.get(sibling.toLowerCase());
  if (publishedByRel.has(key)) return publishedByRel.get(key);
  const base = key.split('/').pop();
  return publishedByBase.get(base) || null;
}

function categoryFor(rel) {
  const top = rel.split('/')[0];
  const folder = FOLDERS.find((item) => item.dir === top);
  return folder ? folder.category : '📝 笔记';
}

function cleanOutput() {
  fs.rmSync(POST_DIR, { recursive: true, force: true });
  fs.rmSync(IMAGE_DIR, { recursive: true, force: true });
  fs.mkdirSync(POST_DIR, { recursive: true });
  fs.mkdirSync(IMAGE_DIR, { recursive: true });
}

async function main() {
  if (!fs.existsSync(VAULT)) {
    throw new Error(`找不到 Obsidian 库：${VAULT}`);
  }

  indexImages();
  cleanOutput();

  // 第一步：扫描白名单目录并决定哪些笔记发布
  const candidates = [];
  for (const folder of FOLDERS) {
    const dir = path.join(VAULT, folder.dir);
    if (!fs.existsSync(dir)) {
      warnings.push(`白名单目录不存在：${folder.dir}`);
      continue;
    }
    for (const file of walk(dir)) {
      if (!file.endsWith('.md')) continue;
      const rel = relOf(file);
      const text = fs.readFileSync(file, 'utf8');
      const { data, body } = parseFrontMatter(text);
      const base = path.posix.basename(rel).replace(/\.md$/i, '');
      const chars = nonSpaceLength(body);

      if (body.includes('%% Begin Waypoint %%')) {
        skipped.push({ rel, reason: 'Waypoint 目录页（无正文）' });
        continue;
      }
      const privateReason = isPrivate(rel, data);
      if (privateReason) {
        skipped.push({ rel, reason: privateReason });
        continue;
      }
      if (GENERIC_TITLE.has(base.toLowerCase()) && !body.match(/^#\s+(.+)$/m)) {
        skipped.push({ rel, reason: '通用文件名且没有 H1 标题' });
        continue;
      }
      if (chars < MIN_CHARS && data.publish !== 'true') {
        skipped.push({ rel, reason: `内容过短（${chars} 字）` });
        continue;
      }

      candidates.push({ file, rel, data, body, chars });
    }
  }

  // 第二步：建立标题索引，供 [[wiki 链接]] 解析
  for (const note of candidates) {
    const { title, removeLine } = deriveTitle(note.rel, note.data, note.body);
    note.title = title;
    note.removeLine = removeLine;
    note.slug = titleSlug(title);
    note.category = note.data.category || note.data.categories || categoryFor(note.rel);
    const entry = { title, rel: note.rel };
    publishedByRel.set(note.rel.replace(/\.md$/i, '').toLowerCase(), entry);
    const base = path.posix.basename(note.rel, '.md');
    if (!publishedByBase.has(base) || publishedByBase.get(base).rel === note.rel) {
      publishedByBase.set(base, entry);
    }
  }

  // 第三步：转换并写出
  for (const note of candidates) {
    const dates = noteDates(note.rel, note.file);
    const content = transformContent(note.body, {
      rel: note.rel,
      slug: note.slug,
      removeLine: note.removeLine,
    });

    const frontMatter = [
      '---',
      `title: ${JSON.stringify(note.title)}`,
      `date: ${formatDate(dates.created)}`,
      `updated: ${formatDate(dates.updated)}`,
      `permalink: /notes/${note.slug}/`,
      'categories:',
      `  - ${note.category}`,
      'tags: []',
      'toc: true',
      'comments: true',
      '---',
      '',
    ].join('\n');

    const outPath = path.join(POST_DIR, note.slug + '.md');
    fs.writeFileSync(outPath, frontMatter + content + '\n', 'utf8');
    published.push({ rel: note.rel, title: note.title, category: note.category, chars: note.chars });
  }

  // 输出报告
  await convertImagesToWebp();

  console.log(`\nObsidian 同步完成：${published.length} 篇发布，${skipped.length} 篇跳过\n`);
  for (const item of published) {
    console.log(`  ✓ [${item.category}] ${item.rel} -> ${item.title}（${item.chars} 字）`);
  }
  if (skipped.length) {
    console.log('\n跳过：');
    for (const item of skipped) console.log(`  - ${item.rel}：${item.reason}`);
  }
  if (warnings.length) {
    console.log('\n警告：');
    for (const item of warnings) console.log(`  ! ${item}`);
  }
  console.log(`\n文章目录：${path.relative(ROOT, POST_DIR)}`);
  console.log(`图片目录：${path.relative(ROOT, IMAGE_DIR)}`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
