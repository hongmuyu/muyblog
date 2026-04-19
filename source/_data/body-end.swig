<style>
/* Giscus 评论容器 */
.giscus-container {
  display: none;  /* 默认隐藏 */
  margin: 2rem 0;
  padding: 1.5rem;
  background: var(--card-bg-color);
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0,0,0,0.05);
  transition: all 0.3s ease;
}

.giscus-container.active {
  display: block;  /* 激活时显示 */
}

.giscus, .giscus-frame {
  width: 100%;
  border: none;
  border-radius: 8px;
}

/* 右侧悬浮按钮容器 */
.sidebar-actions {
  position: fixed;
  right: 30px;
  bottom: 120px;
  z-index: 1000;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

/* 评论按钮 - 固定在右侧的圆形样式 */
.comment-toggle-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 50px;
  height: 50px;
  background: #fff;
  color: #666;
  border: none;
  border-radius: 50%;
  cursor: pointer;
  font-size: 20px;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(0,0,0,0.12);
  position: relative;
}

.comment-toggle-btn:hover {
  background: #f5f5f5;
  color: #333;
  transform: translateY(-3px) scale(1.1);
  box-shadow: 0 6px 20px rgba(0,0,0,0.15);
}

.comment-toggle-btn:active {
  transform: translateY(-1px) scale(1.05);
}

.comment-toggle-btn i {
  font-size: 20px;
}

/* 评论数量角标 */
.comment-toggle-btn .comment-count {
  position: absolute;
  top: -2px;
  right: -2px;
  background: #ff4757;
  color: white;
  padding: 2px 6px;
  border-radius: 10px;
  font-size: 11px;
  font-weight: 600;
  min-width: 18px;
  height: 18px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 2px 5px rgba(255,71,87,0.3);
}

.comment-toggle-btn .comment-count:empty,
.comment-toggle-btn .comment-count[style*="display: none"] {
  display: none !important;
}

/* 隐藏按钮文字，只显示图标 */
.comment-toggle-btn .btn-text {
  display: none;
}

/* 移动端适配 */
@media (max-width: 767px) {
  .sidebar-actions {
    right: 15px;
    bottom: 95px;
    gap: 10px;
  }

  .comment-toggle-btn {
    width: 44px;
    height: 44px;
    font-size: 18px;
  }

  .comment-toggle-btn i {
    font-size: 18px;
  }

  .comment-toggle-btn .comment-count {
    font-size: 10px;
    min-width: 16px;
    height: 16px;
    padding: 1px 4px;
  }

  /* 移动端按钮位置调整 */
  .back-to-top {
    width: 44px;
    height: 44px;
    right: 15px;
    bottom: 25px;
    font-size: 18px;
  }

  .dark-mode-toggle {
    width: 44px;
    height: 44px;
    right: 15px;
    bottom: 60px;
    font-size: 18px;
  }
}

/* 平板适配 */
@media (min-width: 768px) and (max-width: 991px) {
  .sidebar-actions {
    right: 20px;
    bottom: 105px;
  }

  .dark-mode-toggle {
    bottom: 70px;
    right: 20px;
  }

  .back-to-top {
    right: 20px;
    bottom: 25px;
  }
}


/* 手动暗色模式适配 */
[data-theme="dark"] .comment-toggle-btn {
  background: #2d2d2d;
  color: #aaa;
  box-shadow: 0 4px 15px rgba(0,0,0,0.3);
}

[data-theme="dark"] .comment-toggle-btn:hover {
  background: #3a3a3a;
  color: #fff;
  box-shadow: 0 6px 20px rgba(0,0,0,0.4);
}

/* 加载状态 */
.giscus-loading {
  text-align: center;
  padding: 2rem;
  color: var(--text-color-secondary);
}

.giscus-loading .spinner {
  display: inline-block;
  width: 20px;
  height: 20px;
  border: 3px solid rgba(0,0,0,0.1);
  border-radius: 50%;
  border-top-color: var(--btn-bg);
  animation: spin 1s ease-in-out infinite;
  margin-right: 10px;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}
</style>

<!-- 右侧悬浮操作按钮 -->
<div class="sidebar-actions" id="sidebarActions">
  <button class="comment-toggle-btn" id="commentToggleBtn" title="发表评论">
    <i class="fas fa-comment"></i>
    <span class="comment-count"></span>
  </button>
</div>

<!-- 评论容器（放在文章末尾） -->
<div class="comment-section" id="commentSection" style="display: none;">
  <div class="giscus-container" id="giscusContainer">
    <div class="giscus-loading" id="giscusLoading">
      <div class="spinner"></div>
      正在加载评论...
    </div>
    <div class="giscus-wrapper">
      <script src="https://giscus.app/client.js"
              data-repo="hongmuyu/muyblog"
              data-repo-id="R_kgDOSGJEzw"
              data-category="Announcements"
              data-category-id="DIC_kwDOSGJEz84C7JYY"
              data-mapping="pathname"
              data-strict="0"
              data-reactions-enabled="1"
              data-emit-metadata="0"
              data-input-position="bottom"
              data-theme="preferred_color_scheme"
              data-lang="zh-CN"
              crossorigin="anonymous"
              async>
      </script>
    </div>
  </div>
</div>

{# 评论系统交互脚本 #}
<script>
document.addEventListener('DOMContentLoaded', function() {
  const commentBtn = document.getElementById('commentToggleBtn');
  const commentSection = document.getElementById('commentSection');
  const sidebarActions = document.getElementById('sidebarActions');
  const giscusContainer = document.getElementById('giscusContainer');
  const giscusLoading = document.getElementById('giscusLoading');
  const commentCount = commentBtn.querySelector('.comment-count');

  // 检查Giscus是否已加载
  let giscusLoaded = false;
  let commentObserver = null;
  let isCommentVisible = false;

  // 检查是否是博客文章页面
  function isBlogPostPage() {
    return document.querySelector('.post, .post-block, .article, [itemtype="http://schema.org/Article"]') !== null;
  }

  // 如果不是文章页面，隐藏评论按钮
  if (!isBlogPostPage()) {
    sidebarActions.style.display = 'none';
    console.log('非博客文章页面，隐藏评论按钮');
    return;
  }

  // 将评论容器移动到文章末尾
  function moveCommentContainer() {
    // 查找文章主体或页面主体
    const postBody = document.querySelector('.post-body, .post-content, .article-content, main .content');
    const postBlock = document.querySelector('.post-block, .post, article');

    if (postBody && postBody.parentNode) {
      // 插入到文章主体之后
      postBody.parentNode.insertBefore(commentSection, postBody.nextSibling);
      commentSection.style.display = 'block';
      console.log('评论容器已插入到文章主体之后');
    } else if (postBlock && postBlock.parentNode) {
      // 备用：插入到文章块之后
      postBlock.parentNode.insertBefore(commentSection, postBlock.nextSibling);
      commentSection.style.display = 'block';
      console.log('评论容器已插入到文章块之后');
    } else {
      // 如果找不到合适位置，显示在原位置
      commentSection.style.display = 'block';
      console.log('使用默认位置显示评论容器');
    }
  }

  // 点击按钮切换评论显示
  commentBtn.addEventListener('click', function() {
    isCommentVisible = !isCommentVisible;

    if (isCommentVisible) {
      // 展开状态
      giscusContainer.classList.add('active');
      commentBtn.innerHTML = '<i class="fas fa-chevron-down"></i><span class="comment-count">' + (commentCount.textContent || '') + '</span>';

      // 滚动到评论区域（平滑滚动）
      setTimeout(() => {
        giscusContainer.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }, 100);

      // 如果Giscus已加载，更新评论计数
      if (giscusLoaded) {
        updateCommentCount();
      }
    } else {
      // 收起状态
      giscusContainer.classList.remove('active');
      commentBtn.innerHTML = '<i class="fas fa-comment"></i><span class="comment-count">' + (commentCount.textContent || '') + '</span>';
    }
  });

  // 监听Giscus加载完成
  function checkGiscusLoaded() {
    const giscusFrame = document.querySelector('.giscus-frame');
    if (giscusFrame && giscusFrame.contentDocument) {
      // Giscus iframe已加载
      giscusLoaded = true;
      giscusLoading.style.display = 'none';

      // 更新评论计数
      updateCommentCount();

      // 监听评论数量变化
      setupCommentObserver(giscusFrame);
    } else {
      // 继续检查
      setTimeout(checkGiscusLoaded, 500);
    }
  }

  // 设置评论数量观察器
  function setupCommentObserver(giscusFrame) {
    try {
      commentObserver = new MutationObserver(function(mutations) {
        updateCommentCount();
      });

      // 观察评论数量的变化
      const targetNode = giscusFrame.contentDocument.body;
      if (targetNode) {
        commentObserver.observe(targetNode, {
          childList: true,
          subtree: true
        });
      }
    } catch (e) {
      console.log('Giscus评论观察器设置失败:', e);
    }
  }

  // 更新评论计数
  function updateCommentCount() {
    try {
      const giscusFrame = document.querySelector('.giscus-frame');
      if (!giscusFrame || !giscusFrame.contentDocument) return;

      const commentElements = giscusFrame.contentDocument.querySelectorAll(
        '.comment, .giscus-comment, [class*="comment-"], [data-discussion-id]'
      );

      // 查找评论计数元素
      const countElements = giscusFrame.contentDocument.querySelectorAll(
        '.giscus-comments-count, [class*="count"], [data-comment-count]'
      );

      let count = 0;

      // 方法1：从计数元素获取
      if (countElements.length > 0) {
        countElements.forEach(el => {
          const text = el.textContent.trim();
          const num = parseInt(text);
          if (!isNaN(num) && num > count) {
            count = num;
          }
        });
      }

      // 方法2：从评论元素数量获取
      if (count === 0 && commentElements.length > 0) {
        count = commentElements.length;
      }

      // 更新按钮显示
      if (count > 0) {
        commentCount.textContent = count;
        commentCount.style.display = 'inline-block';
      } else {
        commentCount.style.display = 'none';
      }
    } catch (e) {
      // 跨域限制，无法访问iframe内容
      console.log('无法获取评论数量:', e);
      commentCount.style.display = 'none';
    }
  }

  // 初始化：移动评论容器到文章末尾
  setTimeout(moveCommentContainer, 100);

  // 开始检查Giscus加载状态
  setTimeout(checkGiscusLoaded, 1000);

  // 快捷键支持：按C键快速跳转到评论
  document.addEventListener('keydown', function(e) {
    if (e.key === 'c' && e.ctrlKey) {
      e.preventDefault();
      commentBtn.click();
    }
  });
});

// 处理Giscus的message事件
window.addEventListener('message', function(event) {
  if (event.origin !== 'https://giscus.app') return;

  const message = event.data;
  if (message.type === 'giscus-ready') {
    // Giscus准备就绪
    const loadingEl = document.getElementById('giscusLoading');
    if (loadingEl) loadingEl.style.display = 'none';
  }

  if (message.type === 'giscus-comment-count') {
    // 更新评论计数
    const countEl = document.querySelector('.comment-count');
    if (countEl && message.count) {
      countEl.textContent = message.count;
      countEl.style.display = 'inline-block';
    }
  }
});
</script>

{# 快捷键支持：Ctrl+K 或 / 键触发搜索 #}
<script>
document.addEventListener('keydown', function(e) {
  // Ctrl + K 或 / 键触发搜索
  if ((e.ctrlKey && e.key === 'k') || e.key === '/') {
    e.preventDefault();
    const searchBtn = document.querySelector('.search-popup-btn');
    if (searchBtn) searchBtn.click();
  }
});
</script>

{# 搜索体验优化 #}
<script>
document.addEventListener('DOMContentLoaded', function() {
  // 等待搜索框加载
  setTimeout(function() {
    const searchInput = document.querySelector('.search-input');
    const searchPopup = document.querySelector('.search-popup');

    if (!searchInput || !searchPopup) return;

    // 1. 搜索历史功能
    const HISTORY_KEY = 'hexo_search_history';
    const MAX_HISTORY = 10;

    // 获取搜索历史
    function getSearchHistory() {
      try {
        const history = localStorage.getItem(HISTORY_KEY);
        return history ? JSON.parse(history) : [];
      } catch (e) {
        console.error('读取搜索历史失败:', e);
        return [];
      }
    }

    // 保存搜索历史
    function saveSearchHistory(query) {
      if (!query.trim()) return;

      try {
        let history = getSearchHistory();

        // 移除重复项
        history = history.filter(item => item !== query);

        // 添加到开头
        history.unshift(query);

        // 限制数量
        if (history.length > MAX_HISTORY) {
          history = history.slice(0, MAX_HISTORY);
        }

        localStorage.setItem(HISTORY_KEY, JSON.stringify(history));
      } catch (e) {
        console.error('保存搜索历史失败:', e);
      }
    }

    // 显示搜索历史
    function showSearchHistory() {
      const history = getSearchHistory();
      if (history.length === 0) return;

      // 创建历史容器
      let historyContainer = document.querySelector('.search-history');
      if (!historyContainer) {
        historyContainer = document.createElement('div');
        historyContainer.className = 'search-history';
        historyContainer.innerHTML = '<div class="search-history-header">最近搜索</div>';

        // 插入到搜索输入框后面
        const inputContainer = searchInput.closest('.search-input-container');
        if (inputContainer) {
          inputContainer.parentNode.insertBefore(historyContainer, inputContainer.nextSibling);
        }
      }

      // 更新历史列表
      const historyList = historyContainer.querySelector('.search-history-list') ||
                          document.createElement('div');
      historyList.className = 'search-history-list';

      historyList.innerHTML = history.map(item => `
        <div class="search-history-item" data-query="${item}">
          <span class="search-history-text">${item}</span>
          <button class="search-history-remove" title="删除">×</button>
        </div>
      `).join('');

      if (!historyContainer.querySelector('.search-history-list')) {
        historyContainer.appendChild(historyList);
      }

      // 添加点击事件
      historyList.querySelectorAll('.search-history-item').forEach(item => {
        item.addEventListener('click', function(e) {
          if (!e.target.classList.contains('search-history-remove')) {
            const query = this.dataset.query;
            searchInput.value = query;
            searchInput.focus();

            // 触发搜索
            const event = new Event('input', { bubbles: true });
            searchInput.dispatchEvent(event);
          }
        });

        const removeBtn = item.querySelector('.search-history-remove');
        if (removeBtn) {
          removeBtn.addEventListener('click', function(e) {
            e.stopPropagation();
            const query = item.dataset.query;
            removeFromHistory(query);
            item.remove();
          });
        }
      });
    }

    // 从历史中移除
    function removeFromHistory(query) {
      try {
        let history = getSearchHistory();
        history = history.filter(item => item !== query);
        localStorage.setItem(HISTORY_KEY, JSON.stringify(history));
      } catch (e) {
        console.error('删除搜索历史失败:', e);
      }
    }

    // 2. 搜索建议（基于标题）
    function showSearchSuggestions(query) {
      if (!query.trim()) return;

      // 获取所有文章标题（从搜索结果中）
      const resultItems = document.querySelectorAll('.search-result-item');
      const titles = Array.from(resultItems).map(item => {
        const titleEl = item.querySelector('.search-result-title');
        return titleEl ? titleEl.textContent : '';
      }).filter(title => title.toLowerCase().includes(query.toLowerCase()));

      // 显示建议（简单实现）
      if (titles.length > 0) {
        // 可以在这里实现更复杂的建议逻辑
      }
    }

    // 3. 搜索结果高亮优化
    function highlightSearchResults() {
      const results = document.querySelectorAll('.search-result-list li');
      results.forEach((result, index) => {
        // 添加交替行背景色
        if (index % 2 === 0) {
          result.style.backgroundColor = 'rgba(0,0,0,0.02)';
        }

        // 添加悬停效果
        result.addEventListener('mouseenter', function() {
          this.style.backgroundColor = 'rgba(102, 126, 234, 0.08)';
        });

        result.addEventListener('mouseleave', function() {
          this.style.backgroundColor = index % 2 === 0 ? 'rgba(0,0,0,0.02)' : 'transparent';
        });
      });
    }

    // 监听搜索输入
    searchInput.addEventListener('input', function() {
      const query = this.value;

      // 显示搜索历史（当输入框为空时）
      if (!query.trim()) {
        showSearchHistory();
      } else {
        // 隐藏历史
        const historyContainer = document.querySelector('.search-history');
        if (historyContainer) {
          historyContainer.style.display = 'none';
        }

        // 显示建议
        showSearchSuggestions(query);
      }
    });

    // 监听搜索提交
    searchInput.addEventListener('keydown', function(e) {
      if (e.key === 'Enter') {
        const query = this.value.trim();
        if (query) {
          saveSearchHistory(query);
        }
      }
    });

    // 监听搜索框打开
    const observer = new MutationObserver(function(mutations) {
      mutations.forEach(function(mutation) {
        if (mutation.attributeName === 'class') {
          const isActive = searchPopup.classList.contains('search-active');
          if (isActive) {
            // 搜索框打开时显示历史
            if (!searchInput.value.trim()) {
              showSearchHistory();
            }

            // 应用高亮
            setTimeout(highlightSearchResults, 100);
          } else {
            // 搜索框关闭时隐藏历史
            const historyContainer = document.querySelector('.search-history');
            if (historyContainer) {
              historyContainer.style.display = 'none';
            }
          }
        }
      });
    });

    observer.observe(searchPopup, { attributes: true });

    // 4. 搜索统计显示
    function updateSearchStats() {
      const resultList = document.querySelector('.search-result-list');
      if (!resultList) return;

      const count = resultList.querySelectorAll('li').length;
      let statsEl = document.querySelector('.search-stats');

      if (!statsEl) {
        statsEl = document.createElement('div');
        statsEl.className = 'search-stats';

        const inputWrapper = searchInput.closest('.search-input-wrapper');
        if (inputWrapper) {
          inputWrapper.parentNode.insertBefore(statsEl, inputWrapper.nextSibling);
        }
      }

      if (count > 0) {
        statsEl.textContent = `找到 ${count} 个结果`;
        statsEl.style.display = 'block';
      } else {
        statsEl.style.display = 'none';
      }
    }

    // 监听搜索结果变化
    const resultsObserver = new MutationObserver(updateSearchStats);
    const resultContainer = document.querySelector('.search-result-list');
    if (resultContainer) {
      resultsObserver.observe(resultContainer, { childList: true, subtree: true });
    }

  }, 1000); // 等待1秒确保搜索组件加载完成
});
</script>

<style>
/* 搜索历史样式 */
.search-history {
  background: white;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
  margin-top: 10px;
  max-height: 300px;
  overflow-y: auto;
  z-index: 1000;
}

.search-history-header {
  padding: 12px 16px;
  font-weight: 600;
  color: #666;
  border-bottom: 1px solid #eee;
  font-size: 14px;
}

.search-history-list {
  padding: 8px 0;
}

.search-history-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 10px 16px;
  cursor: pointer;
  transition: background-color 0.2s;
}

.search-history-item:hover {
  background-color: #f5f5f5;
}

.search-history-text {
  flex: 1;
  color: #333;
  font-size: 14px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.search-history-remove {
  background: none;
  border: none;
  color: #999;
  cursor: pointer;
  font-size: 18px;
  padding: 0 4px;
  margin-left: 8px;
}

.search-history-remove:hover {
  color: #ff4757;
}

/* 搜索统计 */
.search-stats {
  padding: 12px 16px;
  color: #666;
  font-size: 14px;
  border-top: 1px solid #eee;
  background: #f9f9f9;
  border-radius: 0 0 8px 8px;
}

/* 搜索结果高亮优化 */
.search-result-list li {
  transition: background-color 0.2s;
}

.search-result-title {
  color: #0366d6;
  font-weight: 600;
}

.search-result-content {
  color: #586069;
  font-size: 14px;
  line-height: 1.5;
}

/* 暗色模式适配 */
@media (prefers-color-scheme: dark) {
  .search-history {
    background: #2d2d2d;
    border-color: #444;
  }

  .search-history-header {
    color: #aaa;
    border-color: #444;
  }

  .search-history-item {
    color: #ddd;
  }

  .search-history-item:hover {
    background-color: #3a3a3a;
  }

  .search-history-text {
    color: #ddd;
  }

  .search-stats {
    background: #2d2d2d;
    color: #aaa;
    border-color: #444;
  }

  .search-result-title {
    color: #58a6ff;
  }

  .search-result-content {
    color: #8b949e;
  }
}
</style>

{# 平滑滚动支持 #}
<style>
html {
  scroll-behavior: smooth;
}

@media (prefers-reduced-motion: reduce) {
  html {
    scroll-behavior: auto;
  }
}
</style>

{# ============================================ #}
{# 操作流畅度优化 #}
{# ============================================ #}

{# instant.page 预加载（简化版） #}
<script>
// 链接预加载
document.addEventListener('mouseover', function(e) {
  const link = e.target.closest('a');
  if (!link || !link.href) return;

  // 检查是否为内部链接
  const url = new URL(link.href, window.location.origin);
  if (url.origin !== window.location.origin) return;

  // 预加载
  const prefetchLink = document.createElement('link');
  prefetchLink.rel = 'prefetch';
  prefetchLink.href = link.href;
  document.head.appendChild(prefetchLink);

  // 1秒后移除，避免堆积
  setTimeout(() => {
    if (prefetchLink.parentNode) {
      prefetchLink.parentNode.removeChild(prefetchLink);
    }
  }, 1000);
}, { passive: true });
</script>

{# 返回顶部按钮 - 如果 NexT 已提供则隐藏此自定义按钮 #}
{%- if not theme.back2top.enable %}
<button class="back-to-top" id="backToTopCustom" aria-label="返回顶部">
  <i class="fas fa-arrow-up"></i>
</button>
{%- endif %}

<script>
// 返回顶部按钮功能
document.addEventListener('DOMContentLoaded', function() {
  const backToTopBtn = document.getElementById('backToTopCustom') || document.getElementById('backToTop');
  if (!backToTopBtn) return;

  // 显示/隐藏按钮
  function toggleBackToTop() {
    if (window.scrollY > 300) {
      backToTopBtn.classList.add('visible');
    } else {
      backToTopBtn.classList.remove('visible');
    }
  }

  // 点击滚动到顶部
  backToTopBtn.addEventListener('click', function() {
    window.scrollTo({
      top: 0,
      behavior: 'smooth'
    });
  });

  // 监听滚动
  window.addEventListener('scroll', toggleBackToTop);
  toggleBackToTop(); // 初始检查
});
</script>

{# 阅读进度条 #}
<div class="reading-progress" id="readingProgress"></div>

<script>
// 阅读进度条
document.addEventListener('DOMContentLoaded', function() {
  const progressBar = document.getElementById('readingProgress');
  if (!progressBar) return;

  function updateReadingProgress() {
    const scrollTop = window.scrollY;
    const docHeight = document.documentElement.scrollHeight - window.innerHeight;
    const scrollPercent = docHeight > 0 ? (scrollTop / docHeight) * 100 : 0;

    progressBar.style.width = scrollPercent + '%';

    // 更改颜色基于进度
    if (scrollPercent > 90) {
      progressBar.style.background = 'linear-gradient(90deg, #4CAF50, #8BC34A)';
    } else if (scrollPercent > 50) {
      progressBar.style.background = 'linear-gradient(90deg, #2196F3, #03A9F4)';
    } else {
      progressBar.style.background = 'linear-gradient(90deg, #667eea, #764ba2)';
    }
  }

  window.addEventListener('scroll', updateReadingProgress);
  updateReadingProgress();
});
</script>

{# 代码复制按钮 #}
<script>
// 为所有代码块添加复制按钮
document.addEventListener('DOMContentLoaded', function() {
  // 查找所有代码块
  const codeBlocks = document.querySelectorAll('pre code, .highlight, .gist-highlight');

  codeBlocks.forEach(function(codeBlock) {
    // 创建包装器
    const wrapper = document.createElement('div');
    wrapper.className = 'code-block-wrapper';

    // 如果已经有父元素是pre，则包装pre
    let preElement = codeBlock;
    while (preElement && preElement.tagName !== 'PRE') {
      preElement = preElement.parentElement;
    }

    const targetElement = preElement || codeBlock;

    // 包装元素
    targetElement.parentNode.insertBefore(wrapper, targetElement);
    wrapper.appendChild(targetElement);

    // 创建复制按钮
    const copyButton = document.createElement('button');
    copyButton.className = 'copy-button';
    copyButton.innerHTML = '<i class="fas fa-copy"></i> 复制';
    copyButton.title = '复制代码';

    wrapper.appendChild(copyButton);

    // 复制功能
    copyButton.addEventListener('click', function() {
      const code = targetElement.textContent;
      navigator.clipboard.writeText(code).then(function() {
        // 显示成功反馈
        const originalText = copyButton.innerHTML;
        copyButton.innerHTML = '<i class="fas fa-check"></i> 已复制';
        copyButton.style.backgroundColor = '#4CAF50';

        setTimeout(function() {
          copyButton.innerHTML = originalText;
          copyButton.style.backgroundColor = '';
        }, 2000);
      }).catch(function(err) {
        console.error('复制失败:', err);
        copyButton.innerHTML = '<i class="fas fa-times"></i> 失败';
        copyButton.style.backgroundColor = '#f44336';

        setTimeout(function() {
          copyButton.innerHTML = '<i class="fas fa-copy"></i> 复制';
          copyButton.style.backgroundColor = '';
        }, 2000);
      });
    });
  });
});
</script>

{# 夜间模式切换 #}
<button class="dark-mode-toggle" id="darkModeToggle" aria-label="切换夜间模式">
  <i class="fas fa-moon" id="darkModeIcon"></i>
</button>

<script>
// 夜间模式切换
document.addEventListener('DOMContentLoaded', function() {
  const darkModeToggle = document.getElementById('darkModeToggle');
  const darkModeIcon = document.getElementById('darkModeIcon');
  const THEME_KEY = 'hexo_theme';
  const DARK_THEME = 'dark';
  const LIGHT_THEME = 'light';

  if (!darkModeToggle || !darkModeIcon) return;

  // 获取当前主题
  function getCurrentTheme() {
    const savedTheme = localStorage.getItem(THEME_KEY);
    const systemPrefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;

    return savedTheme || (systemPrefersDark ? DARK_THEME : LIGHT_THEME);
  }

  // 应用主题
  function applyTheme(theme) {
    const html = document.documentElement;

    if (theme === DARK_THEME) {
      html.setAttribute('data-theme', DARK_THEME);
      darkModeIcon.className = 'fas fa-sun';
      darkModeToggle.title = '切换日间模式';
    } else {
      html.removeAttribute('data-theme');
      darkModeIcon.className = 'fas fa-moon';
      darkModeToggle.title = '切换夜间模式';
    }

    localStorage.setItem(THEME_KEY, theme);
  }

  // 切换主题
  function toggleTheme() {
    const currentTheme = getCurrentTheme();
    const newTheme = currentTheme === DARK_THEME ? LIGHT_THEME : DARK_THEME;
    applyTheme(newTheme);
  }

  // 初始化主题
  applyTheme(getCurrentTheme());

  // 监听系统主题变化
  window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', function(e) {
    if (!localStorage.getItem(THEME_KEY)) {
      applyTheme(e.matches ? DARK_THEME : LIGHT_THEME);
    }
  });

  // 绑定点击事件
  darkModeToggle.addEventListener('click', toggleTheme);
});
</script>

{# 图片懒加载增强 #}
<script>
// 图片懒加载增强（补充head.swig中的功能）
document.addEventListener('DOMContentLoaded', function() {
  // 如果浏览器支持loading="lazy"，使用原生懒加载
  if ('loading' in HTMLImageElement.prototype) {
    const images = document.querySelectorAll('img:not([loading])');
    images.forEach(img => {
      // 如果不是关键图片（首屏内），添加懒加载
      if (!img.classList.contains('critical-image')) {
        img.loading = 'lazy';
      }
    });
  }

  // 监听图片加载完成
  document.querySelectorAll('img').forEach(img => {
    if (img.complete) {
      img.classList.add('loaded');
    } else {
      img.addEventListener('load', function() {
        this.classList.add('loaded');
      });

      img.addEventListener('error', function() {
        console.warn('图片加载失败:', this.src);
        // 可以添加错误处理，比如显示占位符
      });
    }
  });
});
</script>

{# 页面加载动画 #}
<style>
/* 页面切换动画 */
.page-transition {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: white;
  z-index: 9999;
  opacity: 0;
  pointer-events: none;
  transition: opacity 0.3s ease;
}

.page-transition.active {
  opacity: 1;
}

/* 暗色模式适配 */
[data-theme="dark"] .page-transition {
  background: #1a1a1a;
}

/* 阅读进度条样式补充 */
.reading-progress {
  position: fixed;
  top: 0;
  left: 0;
  width: 0%;
  height: 3px;
  z-index: 10000;
  transition: width 0.1s ease;
}

/* 返回顶部按钮样式补充 - 与评论按钮统一 */
.back-to-top {
  position: fixed;
  bottom: 30px;
  right: 30px;
  width: 50px;
  height: 50px;
  border-radius: 50%;
  background: #fff;
  color: #666;
  border: none;
  cursor: pointer;
  opacity: 0;
  transform: translateY(20px);
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  z-index: 1000;
  box-shadow: 0 4px 15px rgba(0,0,0,0.12);
}

.back-to-top.visible {
  opacity: 1;
  transform: translateY(0);
}

.back-to-top:hover {
  background: #f5f5f5;
  color: #333;
  transform: translateY(-3px) scale(1.1);
  box-shadow: 0 6px 20px rgba(0,0,0,0.15);
}

.back-to-top:active {
  transform: translateY(-1px) scale(1.05);
}

/* 暗色模式适配 - 返回顶部按钮 */
@media (prefers-color-scheme: dark) {
  .back-to-top {
    background: #2d2d2d;
    color: #aaa;
    box-shadow: 0 4px 15px rgba(0,0,0,0.3);
  }

  .back-to-top:hover {
    background: #3a3a3a;
    color: #fff;
    box-shadow: 0 6px 20px rgba(0,0,0,0.4);
  }
}

[data-theme="dark"] .back-to-top {
  background: #2d2d2d;
  color: #aaa;
  box-shadow: 0 4px 15px rgba(0,0,0,0.3);
}

[data-theme="dark"] .back-to-top:hover {
  background: #3a3a3a;
  color: #fff;
  box-shadow: 0 6px 20px rgba(0,0,0,0.4);
}

/* 夜间模式切换按钮样式补充 - 移入右侧按钮组 */
.dark-mode-toggle {
  position: fixed;
  bottom: 75px;
  right: 30px;
  width: 50px;
  height: 50px;
  border-radius: 50%;
  background: #fff;
  color: #666;
  border: none;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  z-index: 1000;
  box-shadow: 0 4px 15px rgba(0,0,0,0.12);
  transition: all 0.3s ease;
}

.dark-mode-toggle:hover {
  background: #f5f5f5;
  color: #333;
  transform: translateY(-3px) scale(1.1);
  box-shadow: 0 6px 20px rgba(0,0,0,0.15);
}

.dark-mode-toggle:active {
  transform: translateY(-1px) scale(1.05);
}

/* 暗色模式适配 */
@media (prefers-color-scheme: dark) {
  .dark-mode-toggle {
    background: #2d2d2d;
    color: #aaa;
    box-shadow: 0 4px 15px rgba(0,0,0,0.3);
  }

  .dark-mode-toggle:hover {
    background: #3a3a3a;
    color: #fff;
    box-shadow: 0 6px 20px rgba(0,0,0,0.4);
  }
}

[data-theme="dark"] .dark-mode-toggle {
  background: #2d2d2d;
  color: #aaa;
  box-shadow: 0 4px 15px rgba(0,0,0,0.3);
}

[data-theme="dark"] .dark-mode-toggle:hover {
  background: #3a3a3a;
  color: #fff;
  box-shadow: 0 6px 20px rgba(0,0,0,0.4);
}
</style>