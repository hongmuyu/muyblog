<div class="search-header">
  <span class="search-icon">
    <i class="fa fa-search"></i>
  </span>
  <div class="search-input-container">
    <input autocomplete="off" autocapitalize="off"
           placeholder="{{ __('search.placeholder') }}" spellcheck="false"
           aria-label="搜索文章"
           type="search" class="search-input">
  </div>
  {#- 主题 D（P2-11）：关闭控件改为原生 button，可聚焦可键盘激活 #}
  <button type="button" class="popup-btn-close" aria-label="关闭搜索">
    <i class="fa fa-times-circle"></i>
  </button>
</div>
<div id="search-result">
  <div id="no-result">
    <i class="fa fa-spinner fa-pulse fa-5x fa-fw"></i>
  </div>
</div>
