<div class="site-brand-container">
  <div class="site-nav-toggle">
    {#- 主题 D 可访问性修复：aria-label 用于 div 需有有效 role（axe aria-prohibited-attr），补 button 语义与键盘聚焦 #}
    {#- 主题 D（P2-11）：补 aria-expanded / aria-controls 表达移动端菜单展开状态 #}
    <div class="toggle" role="button" tabindex="0" aria-expanded="false" aria-controls="site-nav" aria-label="{{ __('accessibility.nav_toggle') }}">
      <span class="toggle-line toggle-line-first"></span>
      <span class="toggle-line toggle-line-middle"></span>
      <span class="toggle-line toggle-line-last"></span>
    </div>
  </div>

  <div class="site-meta{%- if theme.custom_logo %} custom-logo{%- endif %}">
    {%- if theme.custom_logo and theme.scheme === 'Muse' %}
      <div class="site-meta-headline">
        <a>
          <img class="custom-logo-image" src="{{ theme.custom_logo }}" alt="{{ title }}">
        </a>
      </div>
    {%- endif %}

    <a href="{{ config.root }}" class="brand" rel="start">
      <span class="logo-line-before"><i></i></span>
      {#- 首页用 h1 承载站点标题；其它页面标题已有 h1，站点名降级为 div 避免重复 h1 #}
      {%- if page.__index %}
      <h1 class="site-title">{{ title }}</h1>
      {%- else %}
      <div class="site-title">{{ title }}</div>
      {%- endif %}
      <span class="logo-line-after"><i></i></span>
    </a>
    {%- if subtitle %}
      <p class="site-subtitle" itemprop="description">{{ subtitle }}</p>
    {%- endif %}
    {%- if theme.custom_logo and (theme.scheme === 'Gemini' or theme.scheme === 'Pisces') %}
      <a>
        <img class="custom-logo-image" src="{{ theme.custom_logo }}" alt="{{ title }}">
      </a>
    {%- endif %}
  </div>

  <div class="site-nav-right">
    {#- 主题 D（P2-11）：搜索触发器补 button 语义，可与键盘操作 #}
    <div class="toggle popup-trigger" role="button" tabindex="0" aria-label="{{ __('menu.search') }}">
      {%- if theme.algolia_search.enable or theme.local_search.enable %}
        <i class="fa fa-search fa-fw fa-lg"></i>
      {%- endif %}
    </div>
  </div>
</div>
