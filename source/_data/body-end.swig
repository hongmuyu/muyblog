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

/* 评论按钮 - 固定在文章右下角，突出显示 */
.comment-toggle-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 12px 24px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 12px;
  cursor: pointer;
  font-size: 16px;
  font-weight: 600;
  transition: all 0.3s ease;
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
  position: fixed;
  bottom: 50px;
  right: 50px;
  z-index: 1000;
  opacity: 0.98;
  letter-spacing: 0.5px;
  text-shadow: 0 1px 2px rgba(0,0,0,0.2);
  min-width: 80px;
}

.comment-toggle-btn:hover {
  transform: translateY(-5px) scale(1.05);
  box-shadow: 0 12px 30px rgba(102, 126, 234, 0.6);
  background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
  opacity: 1;
}

.comment-toggle-btn:active {
  transform: translateY(-2px) scale(1.02);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.5);
}

.comment-toggle-btn i {
  margin-right: 8px;
  font-size: 18px;
  filter: drop-shadow(0 1px 2px rgba(0,0,0,0.2));
}

.comment-toggle-btn .comment-count {
  margin-left: 8px;
  background: rgba(255,255,255,0.3);
  padding: 3px 10px;
  border-radius: 15px;
  font-size: 14px;
  font-weight: 700;
  backdrop-filter: blur(4px);
  border: 1px solid rgba(255,255,255,0.2);
}

/* 移动端适配 */
@media (max-width: 767px) {
  .comment-toggle-btn {
    bottom: 30px;
    right: 20px;
    padding: 10px 18px;
    font-size: 15px;
    border-radius: 10px;
    min-width: 70px;
  }

  .comment-toggle-btn i {
    margin-right: 6px;
    font-size: 16px;
  }

  .comment-toggle-btn .comment-count {
    margin-left: 6px;
    padding: 2px 8px;
    font-size: 13px;
  }
}

/* 平板适配 */
@media (min-width: 768px) and (max-width: 991px) {
  .comment-toggle-btn {
    bottom: 40px;
    right: 30px;
  }
}

/* 暗色模式适配 */
@media (prefers-color-scheme: dark) {
  .comment-toggle-btn {
    background: linear-gradient(135deg, #8a2be2 0%, #4b0082 100%);
    box-shadow: 0 8px 25px rgba(138, 43, 226, 0.4);
  }

  .comment-toggle-btn:hover {
    background: linear-gradient(135deg, #4b0082 0%, #8a2be2 100%);
    box-shadow: 0 12px 30px rgba(138, 43, 226, 0.6);
  }
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

<!-- 评论按钮和容器 -->
<div class="comment-section">
  <button class="comment-toggle-btn" id="commentToggleBtn">
    <i class="fas fa-comments"></i>
    <span class="btn-text">评论</span>
    <span class="comment-count">0</span>
  </button>

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
  const commentSection = document.querySelector('.comment-section');
  const giscusContainer = document.getElementById('giscusContainer');
  const giscusLoading = document.getElementById('giscusLoading');
  const btnText = commentBtn.querySelector('.btn-text');
  const commentCount = commentBtn.querySelector('.comment-count');

  // 检查Giscus是否已加载
  let giscusLoaded = false;
  let commentObserver = null;

  // 尝试将评论按钮移动到文章内容区域内部
  function moveCommentButtonToPost() {
    // 尝试找到文章内容容器
    const postContainers = [
      '.post-body',
      '.post-content',
      '.post-block',
      '.post',
      '.post-body-inner',
      '.entry-content',
      '.article-content'
    ];

    let postContainer = null;
    for (const selector of postContainers) {
      const element = document.querySelector(selector);
      if (element) {
        postContainer = element;
        break;
      }
    }

    // 如果找到文章容器，将整个评论区域移动到文章末尾
    if (postContainer && commentSection) {
      // 将评论按钮和容器移到文章容器内部
      postContainer.appendChild(commentSection);

      // 修改按钮定位为绝对定位，相对于文章容器
      commentBtn.style.position = 'absolute';
      commentBtn.style.bottom = '30px';
      commentBtn.style.right = '30px';
      commentBtn.style.zIndex = '100';

      // 确保文章容器有相对定位
      if (window.getComputedStyle(postContainer).position === 'static') {
        postContainer.style.position = 'relative';
      }

      console.log('评论按钮已移动到文章容器内部');
    } else {
      // 如果没找到文章容器，保持原有fixed定位
      console.log('未找到文章容器，评论按钮保持fixed定位');
    }
  }

  // 点击按钮切换评论显示
  commentBtn.addEventListener('click', function() {
    giscusContainer.classList.toggle('active');

    if (giscusContainer.classList.contains('active')) {
      // 展开状态
      btnText.textContent = '收起';
      commentBtn.querySelector('i').className = 'fas fa-chevron-up';

      // 滚动到评论区域（平滑滚动）
      giscusContainer.scrollIntoView({ behavior: 'smooth', block: 'nearest' });

      // 如果Giscus已加载，更新评论计数
      if (giscusLoaded) {
        updateCommentCount();
      }
    } else {
      // 收起状态
      btnText.textContent = '评论';
      commentBtn.querySelector('i').className = 'fas fa-comments';
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

  // 初始化：移动按钮到文章容器
  setTimeout(moveCommentButtonToPost, 100);

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