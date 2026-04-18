/* global hexo */

'use strict';

/**
 * Count symbols in content (supports Chinese and English)
 * @param {String} content - Content string
 * @param {Number} awl - Average word length (default: 4)
 * @returns {Number} Total symbol count
 */
function countSymbols(content, awl = 4) {
  if (!content) return 0;
  
  // Remove HTML tags if present
  const plainText = content.replace(/<[^>]+>/g, ' ');
  
  // Count Chinese characters
  const chineseChars = (plainText.match(/[\u4e00-\u9fa5]/g) || []).length;
  
  // Count English words
  const englishText = plainText.replace(/[\u4e00-\u9fa5]/g, ' ');
  const englishWords = englishText.trim().split(/\s+/).filter(word => word.length > 0).length;
  
  // Total symbols: Chinese characters + English words * average word length
  return chineseChars + englishWords * awl;
}

/**
 * Calculate reading time for a single post
 * @param {Object} post - Post object
 * @param {Number} awl - Average word length (default: 4)
 * @param {Number} wpm - Words per minute (default: 275)
 * @param {String} minutesText - Text for minutes
 * @returns {String} Reading time string
 */
function symbolsTime(post, awl = 4, wpm = 275, minutesText = 'min') {
  if (!post) {
    return '0 ' + minutesText;
  }

  // Try to get content from post (could be raw or rendered)
  const content = post._content || post.content || '';
  const totalSymbols = countSymbols(content, awl);
  
  // Calculate reading time
  const minutes = Math.max(1, Math.ceil(totalSymbols / wpm));
  
  return minutes + ' ' + minutesText;
}

/**
 * Calculate total reading time for all posts
 * @param {Object} site - Site object
 * @param {Number} awl - Average word length (default: 4)
 * @param {Number} wpm - Words per minute (default: 275)
 * @param {String} minutesText - Text for minutes
 * @returns {String} Total reading time string
 */
function symbolsTimeTotal(site, awl = 4, wpm = 275, minutesText = 'min') {
  if (!site) {
    return '0 ' + minutesText;
  }

  let totalSymbols = 0;
  let posts = [];
  
  // Handle different post collection types in Hexo
  if (site.posts && typeof site.posts.toArray === 'function') {
    // Hexo collection object
    posts = site.posts.toArray();
  } else if (Array.isArray(site.posts)) {
    // Plain array
    posts = site.posts;
  } else if (site.posts && site.posts.length) {
    // Array-like object
    posts = Array.from(site.posts);
  }
  
  posts.forEach(post => {
    if (post) {
      const content = post._content || post.content || '';
      totalSymbols += countSymbols(content, awl);
    }
  });
  
  // Calculate total reading time
  const minutes = Math.max(1, Math.ceil(totalSymbols / wpm));
  
  return minutes + ' ' + minutesText;
}

hexo.extend.helper.register('symbolsTime', function(post, awl, wpm, minutesText) {
  if (!awl) awl = 4;
  if (!wpm) wpm = 275;
  if (!minutesText) minutesText = 'min';
  return symbolsTime(post, awl, wpm, minutesText);
});

hexo.extend.helper.register('symbolsTimeTotal', function(site, awl, wpm, minutesText) {
  // If site is not provided or is undefined, try to get it from context
  if (!site || site === undefined || site === null) {
    // Try to get site from helper context
    site = this.site || this.locals.get('site');
    // If still not available, try to access from hexo context
    if (!site || !site.posts) {
      // Create a minimal site object with posts
      const allPosts = hexo.locals.get('posts') || hexo.database.model('Post').toArray() || [];
      site = { posts: allPosts };
    }
  }
  if (!awl) awl = 4;
  if (!wpm) wpm = 275;
  if (!minutesText) minutesText = 'min';
  return symbolsTimeTotal(site, awl, wpm, minutesText);
});

