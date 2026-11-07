{%- if theme.algolia_search.enable or theme.local_search.enable %}
  <div class="search-pop-overlay">
    {#- 主题 D（P2-11）：弹层声明为模态对话框；done 焦点循环、ESC 关闭与焦点返还均在 local-search.js 实现 #}
    <div class="popup search-popup" role="dialog" aria-modal="true" aria-label="{{ __('menu.search') }}">
      {%- if theme.algolia_search.enable %}
        {% include 'algolia-search.swig' %}
      {% elif theme.local_search.enable %}
        {% include 'localsearch.swig' %}
      {%- endif %}
    </div>
  </div>
{%- endif %}
