<script src="https://giscus.app/client.js"
        data-repo="[USERNAME]/[REPOSITORY]"
        data-repo-id="[REPO_ID]"
        data-category="[CATEGORY]"
        data-category-id="[CATEGORY_ID]"
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

<style>
.giscus, .giscus-frame {
  width: 100%;
  border: none;
  margin-top: 2rem;
  border-radius: 8px;
}
</style>

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