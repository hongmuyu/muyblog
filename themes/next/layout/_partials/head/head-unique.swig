{# 主题 D（P2-12）：文章/列表页的 seo_description 由 scripts/seo-description.js 生成；
   未设置时传 undefined，open_graph 自动回退到 page.description / excerpt / config.description #}
{{ open_graph({ description: page.seo_description }) }}

{{ canonical() }}

{# Exports some front-matter variables to Front-End #}
<script id="page-configurations">
  // https://hexo.io/docs/variables.html
  CONFIG.page = {
    sidebar: {{ page.sidebar | json }},
    isHome : {{ is_home() }},
    isPost : {{ is_post() }},
    lang   : '{{ page.lang }}'
  };
</script>
